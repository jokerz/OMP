#******************************************************
# @desc       会員クラス
# @package    MyClass::JKZ
# @access     public
# @author     Iwahase Ryo
# @create     2010/01/18
# @version    1.00
# @update     2010/07/09    認証に_is_loggedin
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
        if ( $self->_is_loggedin_cached() || $self->is_member_loggedin() ) {
            $method ||= $self->action('default');
            $obj =
                exists ($self->class_component_methods->{$method}) ? $self->call($method) :
                $self->can($method)                                ? $self->$method()     :
                                                                     $self->printErrorPage("invalid method call");
            $obj->{IfMemberLoggedIn}    = 1; ## 会員はログイン済み
            $obj->{MEMBERMAINURL}       = $self->MEMBERMAINURL();
            $obj->{PROFILEURL}          = $self->PROFILEURL();
            $obj->{MESSAGEURL}          = $self->MESSAGEURL();
            $obj->{NEIGHBORURL}         = $self->NEIGHBORURL();
            $obj->{MYLINKURL}           = $self->MYLINKURL();
            $obj->{COMMUNITYURL}        = $self->COMMUNITYURL();
            $obj->{FRIENDURL}           = $self->FRIENDURL();
            $obj->{BBSURL}              = $self->BBSURL();
            $obj->{SITEPARAM}           = $self->__member_param();

            $obj->{SKEY}                = $self->owid_ciphered();
            $obj->{nickname}            = $self->user_nickname;
            $obj->{my_point}            = $self->user_point; ## 会員の所持ﾎﾟｲﾝﾄ
          #************************
          # 各ログ収集
          #************************
=pod
            my $logger     = MyClass::JKZLogger->new({
                owid       => $self->owid(),
                guid       => $self->user_guid(),
                carrier    => $self->user_carriercode(),
                tmplt_name => $self->action(),
            });
            $logger->saveLoginLog      if 'member_default' eq $self->action(); ## 会員はmethod がmember_defaultの場合にログインログを取得
            $logger->savePageViewLog() if 'member_default' ne $self->action(); ## 会員はmethod がmember_defaultのではない場合にページビューログを取得
            $logger->closeLogger();
=cut
        }
        else {
            $obj = $self->loginform();
            $obj->{MEMBERMAINURL}       = $self->MEMBERMAINURL();
            $obj->{IfMemberNotLoggedIn} = 1; ## 会員は未ログイン
        }
    }

    $obj->{MEMBER_MAIN_URL}               = $self->MEMBER_MAIN_URL();
    $obj->{MAINURL}                       = $self->MAINURL();
    $obj->{USERIMAGE_SCRIPTDATABASE_NAME} = $self->CONFIGURATION_VALUE('USERIMAGE_SCRIPTDATABASE_NAME');
    $obj->{USERIMAGE_SCRIPTDATABASE_URL}  = $self->CONFIGURATION_VALUE('USERIMAGE_SCRIPTDATABASE_NAME');
    $obj->{SITEIMAGE_SCRIPTDATABASE_URL}  = $self->CONFIGURATION_VALUE('SITEIMAGE_SCRIPTDATABASE_NAME');
    $obj->{IMAGE_BANNER_SCRIPT_URL}       = $self->CONFIGURATION_VALUE('IMAGE_BANNER_SCRIPT_NAME');
    $obj->{SITE_NAME}                     = MyClass::WebUtil::convertByNKF('-s', $self->cfg->param('SITE_NAME'));
    $obj->{PAGE_NAME}                     = nkf('-S', $self->cfg->param('SITE_NAME'));

  #************************
  # キャリア判定
  #************************
    1 == $self->user_carriercode ? $obj->{IfDoCoMo}      = 1 :
    2 == $self->user_carriercode ? $obj->{IfSoftBank}    = 1 :
    3 == $self->user_carriercode ? $obj->{IfAu}          = 1 :
                                   $obj->{IfIsNonMobile} = 1 ;
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
sub _is_loggedin_cached {
    my $self = shift;

    unless($self->query->param('s')) {
        return undef;
    }

    my ($owid, $ciphered) = split(/::/, $self->query->param('s'));
    my $namespace         = $self->waf_name_space() . 'memberdata';
    my $sysid             = $self->user_guid();
    my $cacheObj          = $self->getFromCache("$namespace:$sysid");

    if (!$cacheObj) {
        return undef;
    }
    ## キャッシュのowidでチェックしてOKならattrAccessUserDataに値をセット
    if  ( MyClass::WebUtil::decipher( $cacheObj->{owid}, $ciphered ) ) {
        map { $self->attrAccessUserData($_, $cacheObj->{$_}) } keys %{ $cacheObj };
        return 1;
    }
    return;
}


#******************************************************
# @access    public
# @desc      会員owidと暗号化したowidを;で連結
# @param
# @return    
#******************************************************
sub owid_ciphered {
    my $self = shift;

    #my $owid = $self->attrAccessUserData("owid");

    if(!$self->query->param('s')) {
        #$self->{owid_ciphered} = join('::', $owid, MyClass::WebUtil::cipher($owid));
        $self->{owid_ciphered} = join('::', $self->attrAccessUserData("owid"), MyClass::WebUtil::cipher($self->attrAccessUserData("owid")));
    }
    else {
        my ($owid, $ciphered) = split(/::/, $self->query->param('s'));
        $self->{owid_ciphered} =
            ( $self->attrAccessUserData("owid") == $owid && MyClass::WebUtil::decipher( $self->attrAccessUserData("owid"), $ciphered ) ) ? $self->query->param('s') : undef ;
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
# 会員ID こちの方がowidより新しいが会員のデータにはuser_+xxx 定義することにしたためowidをエイリアスに変更
#******************************************************
sub user_owid {
    my $self = shift;
    $self->{user_owid} = $self->attrAccessUserData("owid");

    return $self->{user_owid};
}


#******************************************************
# 会員ID アクセッサの変更のため以前のクラスに対応するためのエイリアス
#******************************************************
sub owid {
    return shift->user_owid;
}


#******************************************************
# 会員のニックネーム
#******************************************************
sub user_nickname {
    my $self = shift;
    $self->{user_nickname} = $self->attrAccessUserData("nickname");

    return $self->{user_nickname};
}



#******************************************************
# 会員のニックネーム
#******************************************************
sub user_point {
    my $self = shift;
    $self->{user_point} = $self->attrAccessUserData("point");

    return $self->{user_point};
}


#******************************************************
# @desc    位置登録情報 関連
#          method名はiArea_+xxxxとする
#******************************************************

sub iArea_region_now {
    my $self = shift;

    my $namespace = $self->waf_name_space() . 'memberdata';
    my $sysid     = $self->attrAccessUserData("_sysid");
    my $cacheObj  = $self->getFromCache("$namespace:$sysid");
    if (!$cacheObj) {
       my $sess_ref = MyClass::JKZSession->open($sysid, {expire => 3600});
       $self->{iArea_region_now} = $sess_ref->attrData("iArea_region");

       $sess_ref->close();
    }
    else {
        $self->{iArea_region_now} = $cacheObj->{'iArea_region'};
    }

    return $self->{iArea_region_now};
}


sub iArea_area_name_now {
    my $self = shift;

    $self->{iArea_area_name_now} = $self->attrAccessUserData('iArea_name');

    return $self->{iArea_area_name_now};
}


sub iArea_areaid {
    my $self = shift;
    $self->{iArea_areaid} = $self->attrAccessUserData("iArea_areaid");

    return $self->{iArea_areaid};
}



#******************************************************
# 以前のメソッド名・互換性を保つためのエイリアス
#******************************************************
sub region_now {
    my $self = shift;
    return $self->iArea_region_now();
}


sub area_name_now {
    my $self = shift;
    return $self->iArea_area_name_now();
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

sub BBSURL {
    my $self = shift;
    $self->{BBSURL} = sprintf("%s/%s?%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('BBS_CONTROLER_NAME'), $self->__member_param());

    return $self->{BBSURL};
}


1;

__END__