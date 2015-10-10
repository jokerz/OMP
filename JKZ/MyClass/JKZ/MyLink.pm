#******************************************************
# @desc        
# @desc      マイリンク処理
# @package   MyClass::JKZ::MyLink
# @access    public
# @author    Iwahase Ryo
# @create    2010/07/02
# @update    
# @version    1.00
#******************************************************
package MyClass::JKZ::MyLink;

use strict;
use warnings;
use 5.008005;
our $VERSION = '1.00';

use base qw(MyClass::JKZ);

use MyClass::WebUtil;
use MyClass::JKZDB::MyLinkList;

use Data::Dumper;

#******************************************************
# @access    public
# @desc        コンストラクタ
# @param    
# @return    
#******************************************************
sub new {
    my ($class, $cfg) = @_;

    return $class->SUPER::new($cfg);
}


sub run {
    my $self = shift;

    $self->SUPER::run();
}


#******************************************************
# @access    public
# @desc      マイリンクリスト
# @param    
# @return    
#******************************************************
sub viewlist_mylink {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = $self->_mylinklist();

    return $obj;
}


#******************************************************
# @access    public
# @desc      マイリンクリストにリンクを追加
# @param    
# @return    
#******************************************************
sub add_mylinklist {
    my $self = shift;
    my $q    = $self->query();
    my $obj;

    my $owid              = $self->owid();
    my $toid              = $q->param('toid');
    my $neighbor_nickname = $q->unescape($q->param('escape_neighbor_nickname'));
    my $dbh               = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $mylinklist        = MyClass::JKZDB::MyLinkList->new($dbh);
    $mylinklist->executeUpdate(
        {
          owid              => $owid,
          toid              => $toid,
          neighbor_nickname => $neighbor_nickname,
        },
        -1
    );

 ## データ更新ためキャッシュを削除
    my $namespace = sprintf("%s%s:%s", $self->waf_name_space(), 'mylinklist', $owid);
    $self->initMemcachedFast()->delete("$namespace");
    $obj = $self->_mylinklist();
    $obj->{IfSuccess} = 1;

    return $obj;
}


#******************************************************
# @access    public
# @desc      マイリンクリストからリンクを削除
# @param    
# @return    
#******************************************************
sub remove_mylinklist {
    my $self = shift;
    my $q    = $self->query();
    my $obj;

    my $owid       = $self->owid();
    my $toid       = $q->param('toid');
    my $dbh        = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $mylinklist = MyClass::JKZDB::MyLinkList->new($dbh);
    
    $mylinklist->remove_link( { owid => $owid, toid => $toid } );

 ## データ更新ためキャッシュを削除
    my $namespace = sprintf("%s%s:%s", $self->waf_name_space(), 'mylinklist', $owid);
    $self->initMemcachedFast()->delete("$namespace");
    $obj = $self->_mylinklist();
    $obj->{IfSuccess} = 1;

    return $obj;
}


#******************************************************
# @access   private
# @desc     マイリンクリストの取得
# @param    
# @return   hash obj
#******************************************************
sub _mylinklist {
    my $self = shift;

    my $namespace = $self->waf_name_space() . 'mylinklist';
    my $memcached = $self->initMemcachedFast();
    my $owid      = $self->owid();
    my $obj       = $memcached->get("$namespace:$owid");
    if (!$obj) {
        my $dbh        = $self->getDBConnection();
        $self->setDBCharset("sjis");
        my $mylinklist = MyClass::JKZDB::MyLinkList->new($dbh);
        $mylinklist->executeSelectList( {
            whereSQL    => 'owid=?',
            placeholder => [$owid],
        } );
        $obj->{LoopMyLinkList} = $mylinklist->countRecSQL();
        if ( 0 <= $mylinklist->countRecSQL() ) {
            $obj->{IfExistsMyLink} = 1;

            for (my $i = 0; $i <= $obj->{LoopMyLinkList}; $i++) {
                map { $obj->{$_}->[$i] = $mylinklist->{columnslist}->{$_}->[$i] } keys %{ $mylinklist->{columnslist} };
                ( 0 != $i % 2 ) ? $obj->{IfEven}->[$i] = 1 : $obj->{IfOdd}->[$i] = 1 ;
                $obj->{LINKNEIGHBORURL}->[$i]          = $self->NEIGHBORURL();
            }
        }
        else {
            $obj->{IfNotExistsMyLink} = 1;
        }

        $memcached->add("$namespace:$owid", $obj);
    }

    return $obj;
}



1;
__END__