#!/usr/bin/perl

#******************************************************
# @desc        Creates JKZ Framework
#            対話バージョン
#            サイト構成ディレクトリを生成して、設定ファイルenfconf.cfgを設置。
#            またサイト用と管理用のコントローラーの生成とインクルードパス
#            enfconf.cfgは下記データを設定する。
#            FRAMEWORK_BASE_D
#            MAIN_URL
#            CMS_URL
#            DOCUMENT_ROOT
#            CMSDOCUMENT_ROOT
#            CONF_DIR
#            MYLIB_DIR
#            TMPLT_DIR
#            CGI_DIR
#            MODPERL_DIR
#            UI_CONTROLER
#            APP_CONTROLER
#            SENDMAIL_PATH
# @access    public
# @author    Iwahase Ryo
# @create    2009/01/22
# @update    2009/02/18
# @update    2009/02/27    UIのhtdocs/mod-perl/ perl-cgiとプログラムその他のディレクトリファイルの自動設置を追加
# @update    2009/02/27    CMSのhtdocs/mod-perl/ css js image 、とプログラムその他のディレクトリファイルの自動設置を追加
# @update    2009/03/06    SERIALIZEDOBJDIR DL_CONTENTS_DIRを追加
# @update    2009/06/01    不要なものを削除Term::ANSIColor
# @update    2009/06/04    必要な定義および追加事項に伴う更新
# @update    2009/06/30    設定ファイルに項目追加などにより処理追加
# @update    2009/12/28  設定ファイルに項目追加などにより処理追加
# @update    2010/03/26  設定ファイルに項目追加などにより処理追加
# @update    2010/04/01  プログラムをutf8に変更と対応
# @update    2010/06/10  WAF_CONF追加
# @version    1.2
#******************************************************

$|=1;
use strict;

use Cwd;
use File::Path;
use Data::Dumper;
use NKF;

## 生成するファイルのベース
## PLUGINCONFのデフォルトは空ファイル（ファイルが存在が必要 記載方法はsample.config.yamlを参照）
use constant WAF_NAME                  => 'JKZ_WAF';
use constant CONFSKEL                  => './dist/envconf.cfg.dist';
use constant OFFICIALSITESKEL          => './dist/officalsite.cfg.dist';
use constant KDDIDEVICENAMELISTSKEL    => './dist/kddi_devicename_list.cfg.dist';
use constant PLUGINCONFSKEL            => './dist/config.yaml.dist';
#use constant UICONTROLERSKEL        => './dist/ui_controler.mpl.dist';
use constant UICONTROLERSKEL           => './dist/run.mpl.dist';
use constant MEMBERCONTROLERSKEL       => './dist/m_run.mpl.dist';
use constant REGISTMEMBERCONTROLERSKEL => './dist/rg.mpl.dist';
use constant ACCOUNTCONTROLERSKEL      => './dist/account.mpl.dist';
use constant APICONTROLERSKEL          => './dist/apiplug.mpl.dist';
use constant CARTCONTROLERSKEL         => './dist/cart.mpl.dist';
use constant CMSCONTROLERSKEL          => './dist/app.mpl.dist';
use constant UIHTDOCSSKEL              => './dist/site_htdocs.dist';
use constant CMSHTDOCSSKEL             => './dist/cms_htdocs.dist';
use constant CREATETABLESQL            => './dist/createSQLdist.sql';

## get current dir
my $pwd = Cwd::getcwd();
(my $base_path = $pwd) =~ s!JKZ$!!;

my $COUNTER = 0;
my $SUCCESS = 3;
my $FAIL = 0;

#*******************************
# OSの日本語文字コード
#*******************************
open PS, "/bin/echo \$LANG |" or die "$!";
my $PS = <PS>;
close (PS);

my $CHARSET_FLAG = $PS =~ /euc/i ? '-e' : '-w';




#**********************************************
# インストール開始
#**********************************************
while (1) {
    print nkf($CHARSET_FLAG, "\n フレームワークの構築を開始します。\n 環境・ディレクトリ・ライブラリパスの設定・設置・作成をします。");
    print nkf($CHARSET_FLAG, "\nまたMySQLサーバーが起動していることおよび、MySQLユーザーが設定されていることが前提となります。\nよろしいですか？ [y | n] ");

    my $choice = <STDIN>;
    chomp $choice;
    unless ('y' eq $choice) { last; }

    print nkf($CHARSET_FLAG, "\n 必須項目は", "(赤文字で表示)されます<-されない。\n");

    #***********************************************
    # サイトドメイン
    #***********************************************
$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) サイトのドメイン名を入力:");
    my $DOMAIN = <STDIN>;
    chomp $DOMAIN;
    unless ($DOMAIN =~ /[-_\.!\~*'\(\)a-zA-Z0-9\;\/?:@&=\+$,%#]+/) {
        print nkf($CHARSET_FLAG, "\n 正しいサイトドメイン名を入力してください。入力: ");
    }

    #***********************************************
    # 会員サイトドメインがある場合 2010/04/01
    #***********************************************
$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) 会員専用のドメイン名を入力(未入力の場合はサイトドメインとなります): ");
    my $MEMBERDOMAIN = <STDIN>;
    chomp $MEMBERDOMAIN;
    my $MEMBER_FLAG;
    if($MEMBERDOMAIN) {
        $MEMBER_FLAG = 1;
    }
    else {
        $MEMBER_FLAG  = 0;
        $MEMBERDOMAIN = $DOMAIN;
    }

    #***********************************************
    # 管理画面ドメイン
    #***********************************************
$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) 管理画面のドメイン名を入力(未入力の場合はサイトドメイン＋adminとなります): ");
    my $CMSDOMAIN = <STDIN>;
    chomp $CMSDOMAIN;

    #***********************************************
    # 実行ユーザー：グループ
    #***********************************************
$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) 実行ユーザーの指定があれば入力: ");
    my $USER = <STDIN>;
    chomp $USER;

$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) 実行グループの指定があれば入力: ");
    my $GROUP = <STDIN>;
    chomp $GROUP;

    my $user_group = ($USER and $GROUP) ? $USER . '.' . $GROUP : undef;

    #***********************************************
    # sendmailのパス
    #***********************************************
    my $sendmail_path = `/usr/bin/which sendmail`;
    chomp $sendmail_path;

$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) sendmailのパスは $sendmail_path でよろしいですか? [y | n] ");
    $choice = <STDIN>;
    chomp $choice;
    if ('y' ne $choice) {
        print nkf($CHARSET_FLAG, "\n sendmailのパスを入力: ");
        $sendmail_path = <STDIN>;
        chomp $sendmail_path;
    }

$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) SMTPサーバー名もしくはIPアドレスを入力 [localhost]: ");
    my $smtpserver = <STDIN>;
    chomp $smtpserver;
    $smtpserver ||= 'localhost';

    #***********************************************
    # DataBase関連
    #***********************************************
    print nkf($CHARSET_FLAG, "\n MySQLDataBaseの設定を開始します。");

$COUNTER++;
    my $MySQL = `/usr/bin/which mysql`;
    chomp $MySQL;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) MySQLプログラムは $MySQL でよろしいですか？[y | n] ");
    $choice = <STDIN>;
    chomp $choice;
    if ('y' ne $choice) {
        print nkf($CHARSET_FLAG, "\n sendmailのパスを入力: ");
        $MySQL = <STDIN>;
        chomp $MySQL;
    }


$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) データベースユーザー名を入力: ");
    my $databaseuser = <STDIN>;
    chomp $databaseuser;

$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) データベースパスワードを入力: ");
    my $databasepassword = <STDIN>;
    chomp $databasepassword;

$COUNTER++;
    print nkf($CHARSET_FLAG, "\n$COUNTER\) データベース名を入力: ");
    my $databasename = <STDIN>;
    chomp $databasename;

    #***********************************************
    # Process Check MySQLが起動しているか
    #***********************************************
    open PS, "/bin/ps -eF |" or die "$!";
    my @PS = <PS>;
    close PS;
    #if (map{ $_ !~ /$MySQL/ } @PS) {
    if (!grep (/$MySQL/, @PS)) {
        print nkf($CHARSET_FLAG, "\n MySQLサーバーが起動してません。データベースおよびテーブルの生成が出来ません。");
        print nkf($CHARSET_FLAG, "\n MySQLサーバーを起動して、再度このプログラムを実行してください。");
        &take_a_rest();
        last;

    }

    my $MySQLCMD = $MySQL . " -p$databasepassword -u$databaseuser $databasename < " . CREATETABLESQL;
    print "\n", $MySQLCMD, "\n";

    #***********************************************
    # 確定情報を変数に代入
    #***********************************************
    ## URL
    my $mainurl   = 'http://' . $DOMAIN;
    my $memberurl = 'http://' . $MEMBERDOMAIN;
    my $cmsurl    = 'http://';
    $cmsurl .= $CMSDOMAIN ? $CMSDOMAIN : $DOMAIN . '/admin'; 

    ## set documentroot and documentroot for cms
    my $docroot                          = $base_path . $DOMAIN . '/htdocs';
    my $memberdocroot                    = $base_path . $MEMBERDOMAIN . '/htdocs';
    my $cmsdocroot                       = $CMSDOMAIN ? $base_path . $CMSDOMAIN . '/htdocs' : $docroot . '/admin';
    my $confdir                          = $pwd . '/conf';
    my $tmpltdir                         = $pwd . '/tmplt';
    my $dlcontentsdir                    = $pwd . '/dl_contents';
    my $tmpdir                           = $pwd . '/tmp';
    my $modulesdir                       = $pwd . '/modules';
    my $publishdir                       = $pwd . '/publish';
    my $plugindir                        = $pwd . '/MyClass/Plugin';
    my $graphimagedir                    = '';
    my $categorylistobj                  = $publishdir . '/common/categorylist.obj';
    my $subcategorylistobj               = $publishdir . '/common/subcategorylist.obj';
    my $smallcategorylistobj             = $publishdir . '/common/smallcategorylist.obj';
    my $subcategorylist_by_category      = $publishdir . '/common/subcategorylist_by_category.obj';
    my $smallcategorylist_by_subcategory = $publishdir . '/common/smallcategorylist_by_subcategory.obj';
    my $latestcontentsOnTop              = $publishdir . '/contents/latestContentsOnTop.obj';
    my $latestcontents                   = $publishdir . '/contents/latestContents.obj';
    my $recommendcontents                = $publishdir . '/contents/recommendContents.obj';
    my $top10rankingobj                  = $publishdir . '/rank/Top10Ranking.obj';
    my $newscontents                     = $publishdir . '/api_data/newsContents.obj';
    my $weathercontents                  = $publishdir . '/api_data/weatherContents.obj';
    my $horoscopecontents                = $publishdir . '/api_data/horoscopeContents.obj';
    my $mediaagentlist                   = $publishdir . '/common/mediaagentlist.obj';
    my $mediacategorylist                = $publishdir . '/common/mediacategorylist.obj';
    my $userpoint_ranking                = $publishdir . '/contents/userpoint_ranking';

    ## 置換処理
    my $CONFIGRATION = {
        WAF_NAME_SPACE                       => WAF_NAME,
        WAF_CONFIG                           => WAF_NAME . '_CONFIG',
        SITE_NAME                            => "",
        FRAMEWORK_BASE_DIR                   => $pwd,
        MAIN_URL                             => $mainurl,
        MEMBER_MAIN_URL                      => $memberurl,
        #POINT_KICKBACK_MAIN_URL              =>,
        CMS_URL                              => $cmsurl,
        DOCUMENT_ROOT                        => $docroot,
        MEMBER_DOCUMENT_ROOT                 => $memberdocroot,
        #POINTKICKBACK_DOCUMENT_ROOT          =>,
        CMSDOCUMENT_ROOT                     => $cmsdocroot,
        CONF_DIR                             => $confdir,
        MYLIB_DIR                            => $pwd,
        TMPLT_DIR                            => $tmpltdir,
        CGI_DIR                              => '/perl-cgi',
        MODPERL_DIR                          => '/mod-perl',
        DL_CONTENTS_DIR                      => $dlcontentsdir,
        SERIALIZEDOJB_DIR                    => $publishdir,
        TMP_DIR                              => $tmpdir,
        MODULE_DIR                           => $modulesdir,
        PLUGIN_DIR                           => $plugindir,
        GRAPTHIMAGE_DIR                      => $graphimagedir,
        #OFFICIALSITE_CONF #KDDI_DEVICENAME_LIST #PLUGIN_CONF
        UI_CONTROLER_NAME                    => 'run.mpl',
        MEMBER_CONTROLER_NAME                => 'm_run.mpl',
        ACCOUNT_CONTROLER_NAME               => 'account.mpl',
        APIPLUGIN_CONTROLER_NAME             => 'apiplug.mpl,
        REGISTMEMBER_CONTROLER_NAME          => 'rg.mpl',
        CART_CONTROLER_NAME                  => 'cart.mpl',
        APP_CONTROLER_NAME                   => 'app.mpl',
        AFFILIATE_ACCESS_SCRIPT_NAME         => 'af.mpl',
        POINT_BACK_ADVERTISEMENT_SCRIPT_NAME => 'ad_ptbk.mpl',
        INTRODUCE_FRIEND_ACCESS_SCRIPT_NAME  => 'intr.mpl',
        POINT_KICKBACK_SCRIPT_NAME           => 'ptbk.mpl',
        SITEIMAGE_SCRIPTDATABASE_NAME        => '/mod-perl/serveSiteImageDB.mpl',
        IMAGE_SCRIPTFILE_NAME                => '/mod-perl/serveImageFS.mpl',
        IMAGE_SCRIPTDATABASE_NAME            => '/mod-perl/serveImageDB.mpl',
        FLASH_SCRIPTFILE_NAME                => '/mod-perl/serveFlashDB.mpl',
        DECOTMPLT_SCRIPTFILE_NAME            => '/mod-perl/serveDecoTmpltDB.mpl',
        MODIFYMAILADDRESS_SCRIPT_NAME        => '/mod-perl/modifymailaddress.mpl',
        AFFILIATE_SOCKET_SCRIPT_NAME         => $pwd . '/extlib/common/affiliate_sock.pl',
        CATEGORYLIST_OBJ                     => $categorylistobj,
        SUBCATEGORYLIST_OBJ                  => $subcategorylistobj,
        SMALLCATEGORYLIST_OBJ                => $smallcategorylistobj,
        SUBCATEGORYLIST_BY_CATEGORY_OBJ      => $subcategorylist_by_category,
        SMALLCATEGORYLIST_BY_SUBCATEGORY_OBJ => $smallcategorylist_by_subcategory,
        LATEST_CONTENTS_ONTOP_OBJ            => $latestcontentsOnTop,
        LATEST_CONTENTS_OBJ                  => $latestcontents,
        RECOMMEND_CONTENTS_OBJ               => $recommendcontents,
        TOP10_RANKING_OBJ                    => $top10rankingobj,
        NEWS_CONTENTS_OBJ                    => $newscontents,
        WEATHER_CONTENTS_OBJ                 => $weathercontents,
        HOROSCOPE_CONTENTS_OBJ               => $horoscopecontents,
        MEDIAAGENTLIST_OBJ                   => $mediaagentlist,
        MEDIACATEGORYLIST_OBJ                => $mediacategorylist,
        USERPOINT_RANK_DIR                   => $userpoint_ranking,
        #SUBCATEGORYLIST_OBJ                  => $categorylistobj,
        #TOP10_RANKING_OBJ                    => $top10rankingobj,
        #LASTEST_CONTENTS_OBJ                 => $latestcontentsobj,
        SENDMAIL_PATH                        => $sendmail_path,
        SMTP_SERVER                          => $smtpserver,
        DATABASE_USER                        => $databaseuser,
        DATABASE_PASSWORD                    => $databasepassword,
        DATABASE_NAME                        => $databasename,
    };

    #&progress(10);
    print nkf($CHARSET_FLAG, "\n 下記内容でフレームワークの構築をします。");
    print "\n";
    printf (nkf($CHARSET_FLAG, "\n実行ユーザー %s \n実行グループ %s"), $USER, $GROUP) if defined $user_group;
    print "\n";
    print map { $_ . "\t" . $CONFIGRATION->{$_} . "\n" } keys %{$CONFIGRATION};


    #***********************************************
    # ディレクトリ作成開始
    #***********************************************
    ## Create web directories exit this program if any error occur

    my $uicopydir  = UIHTDOCSSKEL . '/*';  #*/
    my $cmscopydir = CMSHTDOCSSKEL . '/*'; #*/

    eval {
        mkpath([$docroot, $cmsdocroot], 1, 0755);
        system("cp -R $uicopydir $docroot ");
        system("cp -R $cmscopydir $cmsdocroot ");
        if ($MEMBER_FLAG) {
            mkpath([$memberdocroot], 1, 0755);
            system("cp -R $uicopydir $memberdocroot ");
        }
    };
    if ($@) {
        print nkf($CHARSET_FLAG, "\n Unable to Create ethier $docroot or $cmsdocroot : $@");
        print nkf($CHARSET_FLAG, "\n ディレクトリのパーミッション、実行者のパーミッションを確認して再度実行してください。");
        #print "\n このプログラムを終了します。";

        $FAIL++;
    }

    #***********************************************
    # 実行ユーザー：グループの変更
    #***********************************************
    system("/usr/bin/find $base_path -type d -exec chown $user_group {} \\;") if defined $user_group;

    #***********************************************
    # 各ファイル、プログラムの決定
    # 各ファイルの生成開始
    #***********************************************
    my $conf                   = $confdir . '/envconf.cfg';
    my $officialsite_conf      = $confdir . '/officialsite.cfg';
    my $kddi_devicename_list   = $confdir . '/kddi_devicename_list.cfg';
    my $plugin_conf            = $confdir . '/config.yaml';
    my $ui_controler           = $docroot . '/run.mpl';
    my $member_controler       = $docroot . '/m_run.mpl';
    my $registmember_controler = $docroot . '/rg.mpl';
    my $account_controler      = $docroot . '/account.mpl';
    my $apiplugin_controler    = $docroot . '/apiplug.mpl';
    my $cart_controler         = $docroot . '/cart.mpl';
    my $cms_controler          = $cmsdocroot . '/app.mpl';

    my @tmpptr = (
        [CONFSKEL, $conf],
        [OFFICIALSITESKEL, $officialsite_conf],
        [KDDIDEVICENAMELISTSKEL, $kddi_devicename_list],
        [PLUGINCONFSKEL, $plugin_conf],
        [UICONTROLERSKEL, $ui_controler],
        [MEMBERCONTROLERSKEL, $member_controler],
        [REGISTMEMBERCONTROLERSKEL, $registmember_controler],
        [ACCOUNTCONTROLERSKEL, $apiplugin_controler],
        [APICONTROLERSKEL, $account_controler],
        [CARTCONTROLERSKEL, $cart_controler],
        [CMSCONTROLERSKEL, $cms_controler],
    );

    foreach my $z (@tmpptr) {
        print $z->[0],"\n", $z->[1],"\n" if -e $z->[0];

        ## ベースデータを取得し、環境に合わせたデータに置き換える
        local $/;
        local *F;
        open (F, "<". $z->[0] . "\0") or $FAIL++;
        my $skelton = <F>;
        close (F);

        $skelton =~ s{ __(.*?)__ }{ exists ($CONFIGRATION->{$1}) ? $CONFIGRATION->{$1} : ""}gex;

        ## 情報をファイルに出力し、対応ディレクトリに設置
        open (W,">$z->[1]") or $FAIL++;
        print W $skelton;
        close (W);
    }

    system($MySQLCMD);

    print "\n DONE \n";
    print "\n", $FAIL , '/', $SUCCESS, nkf($CHARSET_FLAG, "項目の実行に失敗\n");
   last if 0 < $FAIL;

    #***********************************************
    # データベースの設定開始
    # ディレクトリ・ファイル生成・環境設定が成功のとき
    #***********************************************
}


sub take_a_rest {
    print "\n";
    sleep 1; print '...';
    sleep 1; print '...';
    sleep 1; print '...';
    print "\n";
}


sub progress {
    my $MAX = shift;
    require Term::ProgressBar;
    #use constant MAX => 20;
    my $prog = Term::ProgressBar->new($MAX);
    for (0..$MAX) {
        sleep 1;
        $prog->update($_);
    }
}

exit();

__END__
#system("/bin/chown -R $user_group $base_path") if defined $user_group;
=pod
my $cmd = "/bin/chown -R $user_group $base_path";
open CMD, "$cmd |";
my @result = <CMD>;
close CMD;
#my @result = `$cmd`  if defined $user_group;
#foreach (@result) {
#print $_,"\n---\n";
#};
=cut
#print "Unable to change user and group \n" if 256==$?;


sub callback {
    my ($data, $response, $protocol) = @_;
    $finaldata .= $data;
    print "$bars[$counter++]\b";
    $counter = 0 if $counter == scalar (@bars);
}
