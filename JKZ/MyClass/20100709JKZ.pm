#******************************************************
# @desc       会員クラス
# @package    MyClass::JKZ
# @access     public
# @author     Iwahase Ryo
# @create     2010/01/18
# @version    1.00
# @update     
# パラメータ： a  = action
#              p  = product_id
#              c  = category_id
#              sc = subcategory_id
#******************************************************

package MyClass::JKZ;
use 5.008005;
our $VERSION = '1.00';
use strict;

use base qw(MyClass);

use MyClass::UsrWebDB;
use MyClass::WebUtil;
use MyClass::JKZDB::Product;
use MyClass::JKZDB::ProductImage;
use MyClass::JKZLogger;

use Data::Dumper;
use NKF;
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


#******************************************************
# @desc     
# @param    
# @return   
#******************************************************
sub run {
    my $self = shift;
    my $obj    = {};

    $self->setAccessUserData();
    $self->connectDB();
    $self->setMicrotime("t0");

    #my $method = $self->query->param('a');
    #my $method = defined($self->query->param('o')) ? $self->query->param('a') . '_' . $self->query->param('o') : $self->query->param('a');
    my $method = $self->action();

    if ( 'loginform' eq $method || 'logout' eq $method ) {
        $obj = $self->$method();
        $obj->{MEMBERMAINURL}       = $self->MEMBERMAINURL();
        $obj->{IfMemberNotLoggedIn} = 1; ## 会員は未ログイン
    }
    else {
       ## Modified 2010/07/09
        if ( $self->_is_loggedin() || $self->is_member_loggedin() ) {
            $method ||= $self->action('default');
            $obj = exists ($self->class_component_methods->{$method}) ? $self->call($method) : $self->can($method) ? $self->$method() : $self->printErrorPage("invalid method call");
            $obj->{IfMemberLoggedIn}    = 1; ## 会員はログイン済み
            $obj->{MEMBERMAINURL}       = $self->MEMBERMAINURL();
            $obj->{PROFILEURL}          = $self->PROFILEURL();
            $obj->{MESSAGEURL}          = $self->MESSAGEURL();
            $obj->{NEIGHBORURL}         = $self->NEIGHBORURL();
            $obj->{MYLINKURL}           = $self->MYLINKURL();
            $obj->{COMMUNITYURL}        = $self->COMMUNITYURL();
            $obj->{FRIENDURL}           = $self->FRIENDURL();
            $obj->{SITEPARAM}           = $self->__member_param();
        }
        else {
            $obj = $self->loginform();
            $obj->{MEMBERMAINURL}       = $self->MEMBERMAINURL();
            $obj->{IfMemberNotLoggedIn} = 1; ## 会員は未ログイン
        }
    }
    $obj->{MEMBER_MAIN_URL} = $self->MEMBER_MAIN_URL();
    #$obj->{orid}                          = $self->attrAccessUserData("_orid");
    $obj->{my_point}                      = $self->attrAccessUserData("point"); ## 会員の所持ﾎﾟｲﾝﾄ
    $obj->{MAINURL}                       = $self->MAINURL();
    $obj->{USERIMAGE_SCRIPTDATABASE_NAME} = $self->CONFIGURATION_VALUE('USERIMAGE_SCRIPTDATABASE_NAME');
    $obj->{SITEIMAGE_SCRIPTDATABASE_URL}  = $self->CONFIGURATION_VALUE('SITEIMAGE_SCRIPTDATABASE_NAME');
    $obj->{SITE_NAME}                     = MyClass::WebUtil::convertByNKF('-s', $self->cfg->param('SITE_NAME'));
    $obj->{PAGE_NAME}                     = nkf('-S', $self->cfg->param('SITE_NAME'));

#*********************************
# 下記は必要に応じて設定
#*********************************
    #$obj->{IMAGE_SCRIPTDATABASE_NAME}    = $self->CONFIGURATION_VALUE('IMAGE_SCRIPTDATABASE_NAME');
    #$obj->{CARTURL}                      = $self->CARTURL();
    #$obj->{FLASH_SCRIPT_URL}             = $self->CONFIGURATION_VALUE('FLASH_SCRIPTFILE_NAME');
    #$obj->{DECOTMPLT_SCRIPT_URL}         = $self->CONFIGURATION_VALUE('DECOTMPLT_SCRIPTFILE_NAME');
    #$obj->{DECOICON_SCRIPT_URL}          = $self->CONFIGURATION_VALUE('DECOICON_SCRIPTFILE_NAME');
    #$obj->{PTBKURL}                      = sprintf("/%s?guid=ON&", $self->cfg->param('POINT_BACK_ADVERTISEMENT_SCRIPT_NAME'));

   ## 会員用フッター処理 BEGIN
   my $footer_tags = {
       MAINURL             => undef,
       MEMBER_MAIN_URL     => undef,
       MEMBERMAINURL       => undef,
       PROFILEURL          => undef,
       MESSAGEURL          => undef,
       MYLINKURL           => undef,
       FRIENDURL           => undef,
       COMMUNITYURL        => undef,
       IfMemberLoggedIn    => undef,
       IfMemberNotLoggedIn => undef,
       ACCOUNTURL          => undef,
       SITEPARAM           => undef,
   };
    map { exists($obj->{$_}) ? $footer_tags->{$_} = $obj->{$_} : delete $footer_tags->{$_} } keys %{ $footer_tags };

    my $tmpobj          = $self->_getDBTmpltFileByName('footer_html');
    my $footer_obj      = MyClass::JKZHtml->new({}, $tmpobj, 1, 0);
    $obj->{FOOTER_HTML} = $footer_obj->convertHtmlTags( $footer_tags );

   ## 会員用フッター処理 END

    #**************************************
    # Modified ここでアクセスログ.ページログをとる
    #**************************************
    # aパラメータ名がテンプレート名となる。
=pod
    my $tmplt_name = $self->action();
    my $logger     = MyClass::JKZLogger->new({
        carrier    => $self->attrAccessUserData("carriercode"),
        guid       => $self->user_guid,
        tmplt_name => $tmplt_name,
    });

    ## access logging method がdefaultの場合にアクセスログを取得
    $logger->saveAccessLog() if 'default' eq $self->action();
    ## pv logging
    $logger->savePageViewLog();
    $logger->closeLogger();
=cut
    $self->processHtml($obj);

    $self->disconnectDB();
}


#******************************************************
# @desc     会員のデフォルトページ
# @param    
# @return   
#******************************************************
sub default {
    my $self = shift;
}


#******************************************************
# @access    public
# @desc        サイト内説明・そのた事務的なページ用
# @param    str queryのpgの値をテンプレートに設定
#           パラメータ値が無い場合はエラーページ処理
#******************************************************
sub view_help {
    my $self = shift;
    my $obj  = {};

    my $tmplt_name = $self->query->param('pg') || 'error';
    $obj->{ENCRYPTGUID} = MyClass::WebUtil::encryptBlowFish($self->attrAccessUserData("_sysid"));

    $self->action($tmplt_name);

    return $obj;
}


#******************************************************
# @access    public
# @desc        loginformの表示
# @param
# @return    
#******************************************************
sub loginform {
    my $self = shift;
    my $obj = {};

    $self->action('loginform');

    return $obj;
}


#******************************************************
# @access    public
# @desc      会員セッションの破棄
# @param
# @return    
#******************************************************
sub logout {
    my $self      = shift;
    my $sysid     = $self->user_guid();
    my $namespace = $self->waf_name_space() . 'memberdata';
    ## キャッシュをクリア
    $self->deleteFromCache("$namespace:$sysid");
    ## session情報をクリアして、最新情報を取得する
    my $sess_ref = MyClass::JKZSession->open($sysid);
    $sess_ref->clear_session() if defined $sess_ref;

    return $self->loginform();
}


#******************************************************
# @desc     パラメータのsがある場合の認証軽量化のための処理
# @param    またこの認証がOKの場合はキャッシュに会員データがあることが必須
# @return   boolean 1 undef
#******************************************************
sub _is_loggedin {
    my $self = shift;

    unless($self->query->param('s')) {
        return undef;
    }

    my ($owid, $ciphered) = split(/::/, $self->query->param('s'));
    my $namespace         = $self->waf_name_space() . 'memberdata';
    my $sysid             = $self->user_guid();#$self->attrAccessUserData("_sysid");
    my $cacheObj          = $self->getFromCache("$namespace:$sysid");

    if (!$cacheObj) {
        return undef;
    }

    map { $self->attrAccessUserData($_, $cacheObj->{$_}) } keys %{ $cacheObj };

#my $owid = $self->attrAccessUserData("owid");

    #return ( MyClass::WebUtil::decipher( split(/::/, $self->query->param('s')) ) ? 1 : undef );
  ## attrAccessUserData("owid")の値とパラメータのcipheredでチェック attraAccessUserData("owid")に値がない場合はNG。
warn __LINE__, " : CHECKING IF MEMBER IS LOGGED IN  \n CHECK THE VALUES : [ owid:", $self->attrAccessUserData("owid"), " / ciphered:", $ciphered, " ] \n",  MyClass::WebUtil::decipher( $self->attrAccessUserData("owid"), $ciphered ) ? "[ LOGGED IN OK ] \n" : "[ LOGGED IN NG going to check member DATABASE ] \n";
    return ( MyClass::WebUtil::decipher( $self->attrAccessUserData("owid"), $ciphered ) ? 1 : undef );
}


#******************************************************
# @access    public
# @desc      会員owidと暗号化したowidを;で連結
# @param
# @return    
#******************************************************
sub owid_ciphered {
    my $self = shift;

    my $owid = $self->attrAccessUserData("owid");

    if(!$self->query->param('s')) {
        $self->{owid_ciphered} = join('::', $owid, MyClass::WebUtil::cipher($owid));
warn __LINE__, " : CREATING CIPHERED : [ owid :$owid ] \n";
    }
    else {
        my ($s_owid, $s_ciphered) = split(/::/, $self->query->param('s'));
        
        #$self->{owid_ciphered} = ( $owid == $s_owid && MyClass::WebUtil::decipher($s_owid, $s_ciphered) ) ? join('::', $s_owid, $s_ciphered) : join('::', $owid, MyClass::WebUtil::cipher($owid));
warn __LINE__, " :  CIPHERED : [ owid :$owid ] \n";
        $self->{owid_ciphered} = ( $owid == $s_owid && MyClass::WebUtil::decipher($s_owid, $s_ciphered) ) ? join('::', $owid, $s_ciphered) : join('::', $owid, MyClass::WebUtil::cipher($owid));
    }

    return $self->{owid_ciphered};
}


#******************************************************
# 会員パメラータ
#******************************************************
sub __member_param {
    my $self = shift;

    $self->{__member_param} = sprintf("guid=ON&s=%s", $self->owid_ciphered());
    return $self->{__member_param};
}


#******************************************************
# 会員ID (docom softbank only)
#******************************************************
sub owid {
    my $self = shift;
    $self->{owid} = $self->attrAccessUserData("owid");

    return $self->{owid};
}


#******************************************************
# @desc    位置登録情報
#******************************************************
sub region_now {
    my $self = shift;

    my $namespace = $self->waf_name_space() . 'memberdata';
    my $sysid     = $self->attrAccessUserData("_sysid");
    my $cacheObj  = $self->getFromCache("$namespace:$sysid");
    if (!$cacheObj) {
       my $sess_ref = MyClass::JKZSession->open($sysid, {expire => 3600});
       $self->{region_now} = $sess_ref->attrData("iArea_region");
#$sess_ref->attrData("iArea_name");

       $sess_ref->close();
    }
    else {
        $self->{region_now} = $cacheObj->{'iArea_region'};
    }
    #$self->{region_now} = $self->attrAccessUserData('iArea_region');

    return $self->{region_now};
}


sub area_name_now {
    my $self = shift;

    $self->{area_name_now} = $self->attrAccessUserData('iArea_name');

    return $self->{area_name_now};
}


#******************************************************
# @desc    必須パラメータが付与されている会員専用のURL
#******************************************************
sub MEMBERMAINURL {
    my $self = shift;

    $self->{MEMBERMAINURL} = sprintf("%s?%s", $self->MEMBER_MAIN_URL(), $self->__member_param());

    $self->{MEMBERMAINURL};
}


#******************************************************
# プロフのURL
#******************************************************
sub PROFILEURL {
   my $self = shift;

    $self->{PROFILEURL} = sprintf("%s/%s?%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('PROFILE_CONTROLER_NAME'), $self->__member_param());

    return $self->{PROFILEURL};
}


#******************************************************
# メッセージのURL
#******************************************************
sub MESSAGEURL {
    my $self = shift;

    $self->{MESSAGEURL} = sprintf("%s/%s?%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('MESSAGE_CONTROLER_NAME'), $self->__member_param());

    return $self->{MESSAGEURL};
}


#******************************************************
# 近所さんのURL
#******************************************************
sub NEIGHBORURL {
    my $self = shift;

    $self->{NEIGHBORURL} = sprintf("%s/%s?%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('NEIGHBOR_CONTROLER_NAME'), $self->__member_param());

    return $self->{NEIGHBORURL};
}


#******************************************************
# マイリンクのURL
#******************************************************
sub MYLINKURL {
    my $self = shift;

    $self->{MYLINKURL} = sprintf("%s/%s?%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('MYLINK_CONTROLER_NAME'), $self->__member_param());

    return $self->{MYLINKURL};
}


sub COMMUNITYURL {
    my $self = shift;

    $self->{COMMUNITYURL} = sprintf("%s/%s?%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('COMMUNITY_CONTROLER_NAME'), $self->__member_param());

    return $self->{COMMUNITYURL};
}



sub FRIENDURL {
    my $self = shift;

    $self->{FRIENDURL} = sprintf("%s/%s?%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('FRIEND_CONTROLER_NAME'), $self->__member_param());

    return $self->{FRIENDURL};
}



1;

__END__