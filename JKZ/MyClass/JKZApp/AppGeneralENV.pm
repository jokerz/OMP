#******************************************************
# @desc    サイト基本設定「管理」
#          
# @package MyClass::JKZApp::AppGeneralENV
# @access  public
# @author  Iwahase Ryo
# @create  2009/08/27
# @version 1.00
#******************************************************
package MyClass::JKZApp::AppGeneralENV;

use 5.008005;
our $VERSION = '1.00';
use strict;

use base qw(MyClass::JKZApp);
use MyClass::JKZDB::MailSetting;
use MyClass::WebUtil;
use Data::Dumper;


#******************************************************
# @access    public
# @desc        コンストラクタ
# @param    
# @return    
#******************************************************
sub new {
    my ($class, $cfg) = @_;

    return $class->SUPER::new ($cfg);
}


#******************************************************
# @access    public
# @desc        親クラスのgetActionをオーバーライド。ここはサブクラスごとに設定
# @param    
#******************************************************
sub getAction {
    my $self = shift;

    return ("" eq $self->action() ? 'siteSettingTopMenu' : $self->action());
}


#******************************************************
# @access   publich
# @desc     accessor
# @param    
# @param    
# @return   
#******************************************************
sub publishdir {
    my $self = shift;
    return ($self->{publishdir});
}


#******************************************************
# @desc        実行するメソッドのチェックと決定
# @param    
# @param    
# @return    methodname || undef
#******************************************************
sub methodnameByAttr {
    my $self = shift;
    my $priv_methodname = sprintf("_%s", $self->query->param('of'));
    
    return ($self->can($priv_methodname) ? $priv_methodname : undef);
}


#******************************************************
# @access    public
# @desc        親クラスのメソッド
# @param    
#******************************************************
sub dispatch {
    my $self = shift;

    my $publishdir = $self->PUBLISH_DIR() . '/admin/GeneralConfigration';
    if (! -d $publishdir) {
        MyClass::WebUtil::createDir($publishdir);
    }
    $self->{publishdir} = $publishdir;

    $self->query->autoEscape(0);
    $self->SUPER::dispatch();
}


#******************************************************
# @access    public
# @desc        この管理画面ﾄｯﾌﾟメニュー
#******************************************************
sub siteSettingTopMenu {
    my $self = shift;

    return;
}



#******************************************************
# @access    
# @desc        設定情報閲覧
# @param    
# @param    
# @return    
#******************************************************
sub viewConfigration {
    my $self = shift;

    my $obj = {};
    my $method = $self->methodnameByAttr();
    $obj = defined $method ? $self->$method() : "";

    my $IfStructure = sprintf("If%s%s", $self->_myMethodName(), $method);
    ## プライベートメソッド名のアンダースコアと次にくるアルファベット1文字を大文字変換
    $IfStructure =~ s!_([a-z])!\u$1!;
    $obj->{$IfStructure} = 1;

    return $obj;
}


#******************************************************
# @access    
# @desc        設定を行う
# @param    
# @param    
# @return    
#******************************************************
sub configureComponent {
    my $self = shift;
    my $q = $self->query();
    my $id = $q->param('id') || undef;

    my $obj = {};
=pod
    if (!$id) {
        $obj->{IfError} = 1;
        return $obj;
    }
=cut

    my $method = $self->methodnameByAttr();

    my $IfStructure = sprintf("If%s%s", $self->_myMethodName(), $method);
        ## プライベートメソッド名のアンダースコアと次にくるアルファベット1文字を大文字変換
        $IfStructure =~ s!_([a-z])!\u$1!;
        $obj->{$IfStructure} = 1;

#=pod
    defined($q->param('md5key')) ? $obj->{IfConfirmConfiguration} = 1 : $obj->{IfEditConfiguration} = 1;

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);

    if ($obj->{IfConfirmConfiguration}) {
         map { $obj->{$_} = $q->param($_) } keys %{$q->Vars};

        my $publish = sprintf("%s/%s", $self->publishdir(), $q->param('md5key'));
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

    }
    elsif ($obj->{IfEditConfiguration}) {
        my $tmpobj = defined $method ? $self->$method($id) : "";
        map { $obj->{$_} = $tmpobj->{$_} } keys %{ $tmpobj };
    }
#=cut

    return $obj;

}


#******************************************************
# @access    
# @desc        
# @param    
# @param    
# @return    
#******************************************************
sub modifyConfiguration {





}


#******************************************************
# @access    private
# @desc        サーバーのバージョン情報等CGI Apache Perl ModPerl MySQL
# @param    
# @param    
# @return    
#******************************************************
sub _server {
    #my $self = shift;

    my $obj = {};
    map { $obj->{$_} = $ENV{$_} } keys %ENV;
    $obj->{PERL_VERSION} = $];

    $obj->{MYSQL_VERSION} = `/usr/local/mysql/bin/mysql -V`;
    $obj->{MYSQL_VERSION} = `/usr/bin/mysql -V` if !$obj->{MYSQL_VERSION};

    return $obj;

}


#******************************************************
# @access    private
# @desc        サイトで使用するメールアカウント関連（メアド・件名・本文・テンプレート)
# @param    
# @param    
# @return    
#******************************************************
sub _mails {
    my $self = shift;

    my $dbh = $self->getDBConnection();
    my $myMailSetting = MyClass::JKZDB::MailSetting->new($dbh);
    my $obj = {};

    ## 引数がある場合は詳細データ表示
    if ($_[0]) {
        my $id = shift;

        if (!$myMailSetting->executeSelect({
            whereSQL    => 'id=?',
            placeholder    => [$id],
         })) {
             $obj->{ERROR_MSG} = "";
             $obj->{IfError} = 1;
         } else {
             map { $obj->{$_} = $myMailSetting->{columns}->{$_} } keys %{ $myMailSetting->{columns} };
         }
     }
    else {

        $myMailSetting->executeSelectList( { columns => ['id', 'type', 'from_address', 'description'] } );
        $obj->{LoopMailConfigrationList} = $myMailSetting->countRecSQL();
        foreach my $i (0..$obj->{LoopMailConfigrationList}) {
            map { $obj->{$_}->[$i] = $myMailSetting->{columnslist}->{$_}->[$i] } keys %{ $myMailSetting->{columnslist} };
        }
    }

    return $obj;
}





1;

__END__
