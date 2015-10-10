#******************************************************
# @desc        
# @desc      相手表示処理
# @package   MyClass::JKZ::Neighbor-
# @access    public
# @author    Iwahase Ryo
# @create    2010/07/02
# @update    
# @version    1.00
#******************************************************
package MyClass::JKZ::Neighbor;

use strict;
use warnings;
use 5.008005;
our $VERSION = '1.00';

use base qw(MyClass::JKZ::MemberContents);

use MyClass::WebUtil;
use MyClass::JKZDB::ProfilePageSetting;
use MyClass::JKZDB::MyLinkList;
use MyClass::JKZDB::MyMessageBoard;

use JKZ::Mobile::Emoji;

#use MyClass::JKZSession;
#use MyClass::JKZDB::Member;
#use MyClass::JKZDB::UserImage;

use NKF;

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
# @desc      近所さんメイン
# @param    
# @return    
#******************************************************
sub neighbor_main {
    my $self = shift;

    my $q    = $self->query();
    my $obj  = {};

  ## 自分のｴﾘｱID
   #my $iArea_areaid = $self->attrAccessUserData("iArea_areaid");
   my $iArea_areaid = $self->iArea_areaid();

   ## 相手のID
    my $to_owid = $q->param('toid');

    my $namespace = $self->waf_name_space() . 'neighbordata';
    my $memcached = $self->initMemcachedFast();
    $obj          = $memcached->get("$namespace:$to_owid");
    if (!$obj) {
        my $sql = sprintf("SELECT pr.owid, pr.nickname, MAKE_SET(pr.profile_bit, 1, 2, 4, 8, 16, 32, 64, 128, 512) AS profile_set, pr.tuserimagef_id, pr.selfintroduction,
 i.iArea_code,i.iArea_areaid,i.iArea_sub_areaid, i.iArea_region
 FROM %s.tProfilePageSettingM pr LEFT JOIN %s.tMyIchi i ON pr.owid=i.owid
 WHERE pr.owid=?;", $self->waf_name_space(), $self->waf_name_space());

        my $dbh = $self->getDBConnection();
        $self->setDBCharset("sjis");
        my $sth = $dbh->prepare($sql);
        $sth->execute($to_owid);
        (
          $obj->{neighbor_owid},
          $obj->{neighbor_nickname},
          $obj->{neighbor_profile_bit},
          $obj->{neighbor_tuserimagef_id},
          $obj->{neighbor_selfintroduction},
          $obj->{neighbor_iArea_code},
          $obj->{neighbor_iArea_areaid},
          $obj->{neighbor_iArea_sub_areaid},
          $obj->{neighbor_iArea_region}
        ) = $sth->fetchrow_array();
        $sth->finish();

        $obj->{toid} = $obj->{neighbor_owid};
        $obj->{escape_neighbor_nickname} = $q->escape($obj->{neighbor_nickname});

      ## ﾘﾝｸ済みかチェック
        my $mylinklist = MyClass::JKZDB::MyLinkList->new($dbh);
        $self->setDBCharset("sjis");
        $mylinklist->is_in_mylinklist( { owid => $self->owid(), toid => $obj->{toid} } ) ? $obj->{IfMyLink} =  1 : $obj->{IfNotMyLink} = 1;

       ## 絵文字変換テスト
        ## 10進数絵文字を16進数に変換
        $obj->{neighbor_selfintroduction} = JKZ::Mobile::Emoji::hex2emoji($obj->{neighbor_selfintroduction});

        $obj->{neighbor_selfintroduction} = MyClass::WebUtil::yenRyenN2br($obj->{neighbor_selfintroduction});
        $memcached->add("$namespace:$to_owid", $obj);
    }

    unless ($iArea_areaid == $obj->{neighbor_iArea_areaid}) {
       $obj->{IfNeighborError} = 1;
    }
    else {
       $obj->{IfNeighbor} = 1;
    }

   ## 掲示板内容取得
    my $bbs = $self->message_of_messageboard({ toid => $obj->{toid}, record_limit => 2 });
    map { $obj->{$_} = $bbs->{$_} } keys %{ $bbs };

    $obj->{s} = $self->owid_ciphered();

    return $obj;
}


#******************************************************
# @desc     掲示板
# @param    
# @param    
# @return   
#******************************************************
sub viewlist_message_board {
    my $self         = shift;
    my $q            = $self->query();
   ## 相手のID
    my $to_owid      = $q->param('toid');
    my $offset       = $q->param('off') || 0;
    my $record_limit = 20;
    #my $condition_limit = $record_limit+1;
    my $obj;

    my $bbs = $self->message_of_messageboard({ toid => $to_owid, offset => $offset, record_limit => $record_limit });
    map { $obj->{$_} = $bbs->{$_} } keys %{ $bbs };

    return $obj;
}


#******************************************************
# @desc     掲示板に書き込み
# @param    
# @param    
# @return   
#******************************************************
#sub write_message_board {
#
#
#
#}



1;
__END__