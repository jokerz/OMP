#******************************************************
# @desc       非会員ページサイトクラス
# @package    MyClass::JKZWebPage
# @access     public
# @author     Iwahase Ryo
# @create     2010/06/11
# @version    1.00
# @update     
# パラメータ： a  = action
#              p  = product_id
#              c  = category_id
#              sbc = subcategory_id
#              smc = smallcategory_id
#******************************************************

package MyClass::JKZWebPage;
use 5.008005;
our $VERSION = '1.00';
use strict;

use base qw(MyClass);

use MyClass::UsrWebDB;
use MyClass::WebUtil;
use MyClass::JKZLogger;
use MyClass::JKZHtml;

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


#******************************************************
# @desc     
# @param    
# @return   
#******************************************************
sub run {
    my $self = shift;
    my $obj    = {};

    $self->setAccessUserData();
    #$self->connectDB();
    $self->setMicrotime("t0");

    my $method = $self->action() || $self->action('default');
    $obj = $self->can($method) ? $self->$method() : $self->printErrorPage("invalid method call");

    $obj->{MAINURL}                       = $self->MAINURL();
    $obj->{MEMBERMAINURL}                 = sprintf("%s?guid=ON", $self->MEMBER_MAIN_URL());
    $obj->{SITEIMAGE_SCRIPTDATABASE_URL}  = $self->CONFIGURATION_VALUE('SITEIMAGE_SCRIPTDATABASE_NAME');
    $obj->{SITE_NAME}                     = MyClass::WebUtil::convertByNKF('-s', $self->cfg->param('SITE_NAME'));
    $obj->{PAGE_NAME}                     = nkf('-S', $self->cfg->param('SITE_NAME'));
    $obj->{ENCRYPTGUID}                   = MyClass::WebUtil::encryptBlowFish($self->attrAccessUserData("_sysid"));

    ## 会員は未ログイン
    $obj->{IfMemberNotLoggedIn} = 1;

  #************************
  # キャリア判定
  #************************
    1 == $self->user_carriercode ? $obj->{IfDoCoMo}      = 1 :
    2 == $self->user_carriercode ? $obj->{IfSoftBank}    = 1 :
    3 == $self->user_carriercode ? $obj->{IfAu}          = 1 :
                                   $obj->{IfIsNonMobile} = 1 ;


  #************************
  ## フッター処理
  #************************
    my $footer_tags = {
        MAINURL                     => undef,
        MEMBERMAINURL               => undef,
        IfMemberLoggedIn            => undef,
        IfMemberNotLoggedIn         => undef,
        IfDoCoMo                    => undef,
        IfSoftBank                  => undef,
        IfAu                        => undef,
        IfIsNonMobile               => undef,
    };

    map { exists($obj->{$_}) ? $footer_tags->{$_} = $obj->{$_} : delete $footer_tags->{$_} } keys %{ $footer_tags };

    ## [ 0 : File system ] [ 1 : DB by ID] [2 : DB by Name ]
    my $tmpobj = 
        ( 1 == $self->cfg->param('DBTMPLT') ) ? $self->_getDBTmpltFile()                    :
        ( 2 == $self->cfg->param('DBTMPLT') ) ? $self->_getDBTmpltFileByName('footer_html') :
                                                $self->_getTmpltFile('footer_html')         ;


    my $databaseflg = (0 < $self->cfg->param('DBTMPLT')) ? 1 : 0;
    my $footer_obj  = MyClass::JKZHtml->new({}, $tmpobj, $databaseflg, 0);
    $footer_obj->setfile() unless 0 < $databaseflg;
    $obj->{FOOTER_HTML} = $footer_obj->convertHtmlTags( $footer_tags );

    my $opt         = {
        charset => 'shift_jis',
        #cookie  => $self->{cookie},
        
    };
    $self->processHtml($obj, $opt);

    $self->dbh->disconnect();


## フッター処理 BEGIN
    #my $tmpobj          = $self->_getDBTmpltFileByName('footer_html');
    #my $footer_obj      = MyClass::JKZHtml->new({}, $tmpobj, 1, 0);
    #$obj->{FOOTER_HTML} = $footer_obj->convertHtmlTags( {
    #                                                     MAINURL             => $obj->{MAINURL},
    #                                                     MEMBERMAINURL       => $obj->{MEMBERMAINURL},
    #                                                     IfMemberNotLoggedIn => $obj->{IfMemberNotLoggedIn},
    #                                                  } );

## フッター処理 END

    #**************************************
    # Modified ここでアクセスログ.ページログをとる 2010/01/26
    #**************************************
    # 2010/02/26 aパラメータ名がテンプレート名となる。
=pod
    my $tmplt_name = $self->action();
    my $logger = MyClass::JKZLogger->new({
        carrier    => $self->attrAccessUserData("carriercode"),
        guid       => $self->user_guid,
        acd        => $self->attrAccessUserData("acd"),
        tmplt_name => $tmplt_name,
    });

    ## access logging method がdefaultの場合にアクセスログを取得
    $logger->saveAccessLog() if 'default' eq $self->action();
    ## pv logging
    $logger->savePageViewLog();
    $logger->closeLogger();
=cut

    #$self->processHtml($obj);
    #$self->disconnectDB();

}


#******************************************************
# @desc     非会員用ページ（トップ）
# @param    view_site
# @return   
#******************************************************
sub default {
    my $self = shift;

    $self->action('view_site');
    #$self->action('login');
    return;
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



1;

__END__
