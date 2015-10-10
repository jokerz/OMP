#******************************************************
# @desc       フレームワークの基底クラス
#             サイト基本処理を実行
#             run.mpl→MyClass   account.mpl→MyClass::JKZAccount rg.mpl→MyClass::JKZRegistMember
# @package    MyClass
# @access     public
# @author     Iwahase Ryo
# @create     2009/11/02
# @version    1.00
# @update     2009/10/29 プラグイン機構導入
#                        mk_accesssor追加
#                        アクセッサメソッド削除
#                        getCgiQuery getAction
#                        bootstrapメソッド追加 
#             2009/11/05 メソッドnewをinitialize変更()
#                        run bootstrap dispatchの処理をプログラム実行コードに移行(Plugin機構の動作の問題)
# @update     2009/12/21 connectDBメソッド時のデバッグモード自動読み込み処理追加
# @update     2009/12/21 インデントのタブ停止。スペース4つに変更
# @update     2010/01/07 WebUtil→MyClass::WebUtil
# @update     2010/01/20 action_objを追加→やっぱやめ
# @update     2010/02/02 newにてmemcachedをイニシャライズ。initMemcachedFastはたんなるアクセッサに変更
# @update     2010/03/04 デバッグ用にテンプレートファイルを明示的に選択できるように修正
# @update     2010/06/10 waf_name_space追加
#******************************************************
package MyClass;
use 5.008005;
our $VERSION = '1.00';

use strict;

#******************************************************
# MyClass::Plugin  機構部分
# このクラスでuse Class::Componentしているから、PluginはMyClass::Pluginに設置する
#******************************************************
use Class::Component;
use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors( qw( cfg config query dbh ) ); ## bless するhashのキー
__PACKAGE__->load_components(qw/ Autocall::Autoload /);
__PACKAGE__->class_component_reinitialize( reload_plugin => 1 );

use CGI;

use MyClass::UsrWebDB;
use MyClass::JKZHtml;
use MyClass::WebUtil;
use MyClass::JKZSession;
use MyClass::JKZMobile;
use MyClass::JKZLogger;
use MyClass::JKZDB::Member;
use MyClass::JKZDB::TmpltFile;

use Data::Dumper;

use YAML;


#******************************************************
# @access	public
# @desc		コンストラクタ
# @param	
# @return	
#******************************************************
sub new {
    my ($class, $cfg) = @_;

    my $config  = $class->setup_configuration($cfg->param('PLUGIN_CONF'));
    my $q       = CGI->new();

    my $action  = defined($q->param('o')) ? $q->param('a') . '_' . $q->param('o') : $q->param('a');

    my $dbh     = MyClass::UsrWebDB::connect({ dbaccount => $cfg->param('DATABASE_USER'), dbpasswd => $cfg->param('DATABASE_PASSWORD'), dbname => $cfg->param('DATABASE_NAME'), });
    my $self    = $class->SUPER::new(
        {
            config     => delete $config->{plugin_config},
            cfg        => $cfg,
            query      => $q,
            action     => $action,
            memcached  => undef,
            dbh        => $dbh,
        }
    );

    $self->config($config);
    $self->setup_plugins();

    return $self;
}


#******************************************************
# do nothing
#******************************************************
sub run {
}


#******************************************************
# @access    public
# @desc      memcacheなどに利用。複数のフレームがインストールされている場合に必要
# @param     データベース名と統一しておく
# @return    
#******************************************************
sub waf_name_space {
    my $self = shift;
    $self->{waf_name_space} = $self->cfg->param('WAF_NAME_SPACE');
    return $self->{waf_name_space};
}

#******************************************************
# @access    public
# @desc        携帯・環境変数セット
# @param
# @return    
#******************************************************
sub setAccessUserData {
    my $self  = shift;
    my $agent = MyClass::JKZMobile->new();
    $self->attrAccessUserData("carriercode", $agent->getCarrierCode());
    $self->attrAccessUserData("_sysid", $agent->getDCMGUID());
    $self->attrAccessUserData("subno", $agent->getSubscribeNumber());
    my $xhtmlflag = 1;
    0 < $xhtmlflag ? $self->attrAccessUserData("xhtml", $agent->xhtmlCapable()) : $self->attrAccessUserData("xhtml", undef);

    my $acd = $self->query->param('acd') || '1';
    $self->attrAccessUserData("acd", $acd);
}


#******************************************************
# guid (docom softbank only)
#******************************************************
sub user_guid {
    my $self = shift;
    $self->{guid} = $self->attrAccessUserData("_sysid");
    return ($self->{guid});
}


#******************************************************
# subscriber id
#******************************************************
sub user_subno {
    my $self = shift;
    $self->{subno} = $self->attrAccessUserData("subno");

    return ($self->{subno});
}


#******************************************************
# アクセスしてる端末のキャリアコード 1 docomo 2 softbank 3 au
#******************************************************
sub user_carriercode {
    my $self = shift;
    $self->{carriercode} = $self->attrAccessUserData("carriercode");
    return ($self->{carriercode});
}


#******************************************************
# @access	
# @desc		アクセッサ 引数があれば値をセット
#
#******************************************************
sub action {
	my $self = shift;

	$self->{action} = $_[0] if @_ > 0;

	return $self->{action};
}


#******************************************************
# @desc		get tmplt_id from query or default is 1
# @param	
# @return	
#******************************************************
sub getTmpltID {
    my $self = shift;
    $self->{t} = $self->query->param('t') || 1;

    return $self->{t};
}


#******************************************************
# @desc		set tmplt_id to query
# @param	
# @return	
#******************************************************
sub setTmpltID {
    my ($self, $id) = @_;
    # Modified 2010/11/29
    #(1 > $id) ? $id = 24 : $id;
    $id ||= 24;

    $self->query->param(-name=>"t",-value=>$id);

    return $self->query->param('t');
}


#******************************************************
# @access  
# @desc    hook処理を追加
# @param   hash obj
# @param   hash obj { charset, cookie }
# @return  
#******************************************************
sub processHtml {
    my $self = shift;
    my $obj  = shift;
    my $opt  = shift; # 2011/11/21 追加
    my $q    = $self->query();

    ## 暫定処理 [ 0 : File system ] [ 1 : DB by ID] [2 : DB by Name ]
    my $TMPLT_BY_DATABASE = $self->cfg->param('DBTMPLT');
    #my $TMPLT_BY_DATABASE = 2;

    my $tmplt = 
        ( 1 == $TMPLT_BY_DATABASE ) ? $self->_getDBTmpltFile()       :
        ( 2 == $TMPLT_BY_DATABASE ) ? $self->_getDBTmpltFileByName() :
                                      $self->_getTmpltFile()         ;

    my $databaseflg = (0 < $TMPLT_BY_DATABASE) ? 1 : 0;

    my $myHtml = MyClass::JKZHtml->new($q, $tmplt, $databaseflg, 0);
    $myHtml->setfile() unless 0 < $databaseflg;

## PLUGIN HOOK 処理 BEGIN
    my @hooks = keys %{ $self->class_component_hooks };
    my $hook_regex = qr/If./;

    if ($databaseflg) {
        foreach my $hook (@hooks) {
            if ($tmplt =~ /__(?:$hook_regex$hook)__/) {
                my $tmpobj = $self->run_hook($hook);
                map { $obj->{$_} = $tmpobj->[0]->{$_} } keys %{ $tmpobj->[0] };
            }
        }
    } else {
        my $source_code = $myHtml->load_source_code();
        foreach my $hook (@hooks) {
            if ($source_code =~ /__(?:$hook_regex$hook)__/) {
                my $tmpobj = $self->run_hook($hook);
                map { $obj->{$_} = $tmpobj->[0]->{$_} } keys %{ $tmpobj->[0] };
            }
        }
    }
## PLUGIN HOOK 処理 END

    my $benchref = {
        t0 => $self->{t0},
        t1 => $self->setMicrotime("t1"),
    };

    $obj->{BENCHTIME} = MyClass::WebUtil::benchmarkMicrotime(2, $benchref);

    $myHtml->convertHtmlTags($obj);
    $myHtml->doPrintTags($opt);
}


#******************************************************
# @access    Modified 2010/02/02
# @desc      
#******************************************************
sub initMemcachedFast {
    my $self = shift;
#    $self->{memcachedfast} = MyClass::UsrWebDB::MemcacheInit();
    $self->{memcached} = MyClass::UsrWebDB::MemcacheInit();
    return $self->{memcached};
}


#******************************************************
# memcachedからキャッシュデータを取得
#******************************************************
sub getFromCache {
    my $self = shift;
    my $key  = shift || return (undef);
    my $memcached = $self->initMemcachedFast();
    my $obj = $memcached->get($key);
    return $obj;
}


#******************************************************
# memcahcedからキャッシュデータを削除
#******************************************************
sub deleteFromCache {
    my $self = shift;
    my $key  = shift || return (undef);
    my $memcached = $self->initMemcachedFast();
    $memcached->delete($key);
}


#******************************************************
# @access  
# @desc    エラーページの表示
#          エラーページテンプレートは決め打ち
#          tmplt_idの場合は：3 tmplt_nameの場合：error
# @param   
# @return  
#******************************************************
sub printErrorPage {
    my ($self, $msg) = @_;
    my $obj;
    $obj->{ERROR_MSG} = $msg;

    1 == $self->cfg->param('DBTMPLT') ? $self->setTmpltID("3") : $self->action('error');

    #$self->setTmpltID("24");
    #$self->action('error');

    return $obj;
}


sub USE_DBTMPLT {
    my $self = shift;
    return ($self->{DBTMPLT} = $self->cfg->param('DBTMPLT'));
}


sub ERROR_MSG {
    my $self = shift;
    if (@_) {
        my $constant_code = shift;
        return $self->cfg->param($constant_code);
    }

    return;
}


#******************************************************
# サイトのURL (ドメイン)
#******************************************************
sub MAIN_URL {
    my $self = shift;
    return ($self->{MAIN_URL} = $self->cfg->param('MAIN_URL'));
}


#******************************************************
# 会員サイトのURL
#******************************************************
sub MEMBER_MAIN_URL {
    my $self = shift;
    return ( $self->{MEMBER_MAIN_URL} = sprintf("%s/%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('MEMBER_CONTROLER_NAME')) );
}


#******************************************************
# サイトトップのURL
#******************************************************
sub MAINURL {
    my $self = shift;
    my $timenow = MyClass::WebUtil::GetTime(4);

    #$self->{MAINURL} = sprintf("%s/%s", $self->MAIN_URL(), $self->cfg->param('UI_CONTROLER_NAME'));
    $self->{MAINURL} = $self->cfg->param('UI_CONTROLER_NAME');

    $self->{MAINURL} .= 
            ( 1 == $self->attrAccessUserData("carriercode") ) ? '?guid=ON&'
            :
            ( 2 == $self->attrAccessUserData("carriercode") ) ? '?uid=1&'
            :
            ( 3 == $self->attrAccessUserData("carriercode") ) ? sprintf("?time=%s&", $timenow)
            :
            ""
           ;

    return $self->{MAINURL};
}


#******************************************************
# 外部API連携時の会員認証とサービス提供URL
#******************************************************
sub APIPLUGINURL {
   my $self = shift;

    $self->{APIPLUGINURL} = sprintf("%s/%s?guid=ON", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('API_CONTROLER_NAME'));

    return $self->{APIPLUGINURL};
}


#******************************************************
# カート処理・商品交換処理のURL
#******************************************************
sub CARTURL {
   my $self = shift;

    $self->{CARTURL} = sprintf("%s/%s", $self->cfg->param('MEMBER_MAIN_URL'), $self->cfg->param('CART_CONTROLER_NAME'));

    $self->{CARTURL} .= 
            ( 1 == $self->attrAccessUserData("carriercode") ) ? '?guid=ON&'
            :
            ( 2 == $self->attrAccessUserData("carriercode") ) ? '?uid=1&'
            :
            ( 3 == $self->attrAccessUserData("carriercode") ) ? '?'
            :
            ""
           ;

    return $self->{CARTURL};
}


#******************************************************
# キャッシュオブジェクト格納ディレクトリ
#******************************************************
sub PUBLISH_DIR {
    my $self = shift;

    $self->{PUBLISH_DIR} = $self->cfg->param('SERIALIZEDOJB_DIR');
    return ($self->{PUBLISH_DIR});
}


#******************************************************#******************************************************#******************************************************#******************************************************#******************************************************


#******************************************************
# @access    
# @desc      データベースを接続
#
#******************************************************
sub dbh {
    my $self = shift;
=pod
    $self->{dbh} = MyClass::UsrWebDB::connect(
        {
          dbaccount => $self->cfg->param('DATABASE_USER'),
          dbpasswd  => $self->cfg->param('DATABASE_PASSWORD'),
          dbname    => $self->cfg->param('DATABASE_NAME'),
        }
    );
=cut
    ## Modified 2009/12/21
    #$self->{dbh}->trace(2, $self->cfg->param('TMP_DIR') . '/DBITrace.log') if 1 == $self->cfg->param('DEBUGMODE');
    $self->{dbh}->trace(2, $self->cfg->param('TMP_DIR') . '/DBITrace.log');
    return $self->{dbh};

}


#******************************************************
# @access    
# @desc      データベースを接続のエイリアス 不要だけど以前のプログラムとの互換性のため
#
#******************************************************
sub connectDB {
    my $self = shift;
    return $self->dbh();
}


#******************************************************
# @modified  2011/11/17
# @desc      DB接続ハンドル 不要 $self->dbhでよい
# @return    database handle
#******************************************************
sub getDBConnection {
    my $self = shift;
    return $self->{dbh};
}


#******************************************************
# @modified  2011/11/17
# @desc      DB接続ハンドル 不要 $self->dbh->disconnectでよい
# @desc        disconnect Database
#******************************************************
sub disconnectDB {
    my $self = shift;
    $self->dbh->disconnect();
}


#******************************************************
# @access    
# @desc      Set charset fro dbaccess
#******************************************************
sub setDBCharset {
    my ($self, $charset) = @_;
    return ($self->dbh->do("set names $charset"));
}


sub setMicrotime {
    my $self = shift;
    $self->{$_[0]} = MyClass::WebUtil::benchmarkMicrotime(1) if @_;
    return ($self->{$_[0]});
}



#******************************************************
# @access    public
# @desc        envconf.cfgに値を取得して配列で返す
# @param    key
# @return    array
#******************************************************
sub fetchArrayValuesFromConf {
    my $self = shift;
    unless (@_) { return; }

    my $name = shift;
    my @values = split(/,/, $self->cfg->param($name));

    return (@values);
}


#******************************************************
# @access	
# @desc		envconfからCommonUse.xxxMに対応するデータを取得
#			envconfの定数からデータを取得
#			配列で格納されている 引数の値に対応する値を返す
# @param	$string		envconf内の定数名
# @param    $integer
# @return   $value
#******************************************************
sub fetchOneValueFromConf {
    my $self = shift;
    unless (@_) { return; }

    my ($name, $value) = @_;
    my $values = $self->{cfg}->param($name);
    my @tmplist = split(/,/, $values);

    return ($tmplist[$value]);
}


sub fetchValuesFromConf {
    my $self = shift;
    unless (@_) { return; }

    my ($name, $defaultvalue) = @_;
    my @values = split(/,/, $self->{cfg}->param($name));

    my $obj;
    no strict ('subs');
    $obj->{Loop . $name . List} = $#values;

    for  (my $i = 0; $i <= $#values; $i++) {
    $obj->{$name . Index}->[$i] = $i;
    $obj->{$name . Value}->[$i] = MyClass::WebUtil::convertByNKF('-s', $values[$i]);
    $obj->{$name . 'defaultvalue'}->[$i] = $defaultvalue == $i ? ' selected' : "";
    }

    return $obj;
}


#******************************************************
# @access    
# @desc        設定ファイルのキーを引数に対応した値を取得
#            キーが存在しない場合undefを返す
#
#            引数が複数の場合(リストコンテキスト)は配列で値を返す
#            引数が単一の場合(スカラコンテキスト)はスカラで値を返す
#
# @param    char    $configrationkey
# @return    char/undef    $configrationvalue
#******************************************************
sub CONFIGURATION_VALUE {
    my $self = shift;

    return undef if 1 > @_;

    my %CONFIGRATIONKEY = $self->cfg->vars();

    return (
        1 == @_
            ?
            ( $self->{CONFIGURATION_VALUE}->{$_[0]} = exists($CONFIGRATIONKEY{$_[0]}) ? $CONFIGRATIONKEY{$_[0]} : undef )
            :
            ( map { $self->{CONFIGURATION_VALUE}->{$_} = ( exists($CONFIGRATIONKEY{$_}) ) ? $CONFIGRATIONKEY{$_} : undef  } @_ )
    );
}



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 会員登録・認証関連 BEGIN @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#******************************************************
# @access    
# @desc      アクセッサー 会員データ
#******************************************************
sub attrAccessUserData {
    my $self = shift;

    return (undef) unless @_;
    $self->{$_[0]} = $_[1] if @_ > 1;
    return ($self->{$_[0]});
}


#******************************************************
# @access    public
# @desc        有効会員のチェック。それ以外の詳細詳細認証はopenSessinでおこなうtMemberMのguidカラムで行う。システムないは_sysidとする
# @param    guidが未登録の場合を想定して、subnoで認証を行いguidが未登録の場合ここで登録する。2010/01/07
# @return    
#******************************************************
sub can_login {
    my $self  = shift;

    my $sysid = $self->user_guid();
    my $sql   = sprintf("SELECT 1 FROM %s.tMemberM WHERE guid=? AND status_flag=?", $self->waf_name_space());
    my $dbh   = $self->getDBConnection();

    $self->setDBCharset('SJIS');
    if (!$dbh->selectrow_array($sql, undef, $sysid, 2)) {
        return undef;
    }

    return 1;
=pod
    my $subno = $self->user_subno();
    my $sql   = "SELECT IF(guid IS NULL, 9, 1) FROM JKZ_WAF.tMemberM WHERE subno=? AND status_flag=?";
    my $dbh   = $self->getDBConnection();
    my $rc    = $dbh->selectrow_array($sql, undef, $subno, 2);

	1 == $rc ? return 1              :
	9 == $rc ? $self->_regist_guid() :
	           return undef         ;
=cut
}


#******************************************************
# @desc   会員認証・チェック
# @param
# @return boolean
#******************************************************
sub is_member_loggedin {
    my $self = shift;

    my $namespace = $self->waf_name_space() . 'memberdata';
    my $sysid     = $self->user_guid();#$self->attrAccessUserData("_sysid");
    my $cacheObj  = $self->getFromCache("$namespace:$sysid");

    ## キャッシュが無い場合は認証. 認証OKであればセッション生成＋キャッシュ生成
    if (!$cacheObj) {
        unless ($self->can_login()) {
    	    return;
        }
        return ( $self->openMemberSession() ? 1 : undef );
    }
    else {
        map { $self->attrAccessUserData($_, $cacheObj->{$_}) } keys %{ $cacheObj };
        return 1;
    }
}


#******************************************************
# @access    public
# @desc        会員情報をチェックしてセッション情報にセット とcacheに格納
# @param    sysid(dcmguid, subno)
# @return    
# @author    
#******************************************************
sub openMemberSession {
    my $self  = shift;
    my $sysid = $self->user_guid();#$self->attrAccessUserData("_sysid");

    my $sess_ref;
    if (defined($sysid)) {
        ## 会員ＩＤを設定
        my ($mid, $tmp);
        ### 600秒を期限として会員データを更新
        if (defined ($sess_ref = MyClass::JKZSession->open($sysid, {expire => 3600}))) {
            if (1 == $sess_ref->session_is_valid()) {
                $tmp = $sess_ref->attrData();
                $mid = $sess_ref->attrData("owid");
                $sess_ref->close();
            } else {
                my $obj = $self->_getMemberBaseData();
                if (defined($obj)) {
                    map { $sess_ref->attrData($_, $obj->{$_}) } keys %{$obj};
                    ## データキャッシュ格納用
                    $tmp = $sess_ref->attrData();
                    $mid = $sess_ref->attrData("owid");

                    $sess_ref->save_close() if defined($sess_ref);
                }
            }
        } else {
            my $obj = $self->_getMemberBaseData();
            if (defined($obj)) {
                # Modified 2010/11/29
                #defined($sess_ref = MyClass::JKZSession->open($sysid, {flag => 1}));
                $sess_ref = MyClass::JKZSession->open($sysid, {flag => 1});
                map { $sess_ref->attrData($_, $obj->{$_}) } keys %{$obj};
                ## データキャッシュ格納用
                $tmp = $sess_ref->attrData();
                $mid = $sess_ref->attrData("owid");

               #**************************************
               # セッションを閉じる前に会員ログインのログ
               #**************************************
=pod 20100614 開発中は不要
                my $logger = MyClass::JKZLogger->new({
                    owid	=> $sess_ref->attrData("owid"),
                    guid	=> $sess_ref->attrData("guid"),
                });
                $logger->saveLoginLog();
                $logger->closeLogger();
=cut
                $sess_ref->save_close() if defined($sess_ref);
            }
            else {

                return undef;
            }
        }
        my $memcached = $self->initMemcachedFast();
        my $namespace = $self->waf_name_space() . 'memberdata';
        $memcached->add("$namespace:$sysid", $tmp, 600);

        map { $self->attrAccessUserData($_, $tmp->{$_}) } keys %{ $tmp };

        return 1;
    } else {

        return;
    }
}


#******************************************************
# @access    private
# @desc        会員の基本情報取得 公式用に変更
# @param
# @return    obj
#******************************************************
sub _getMemberBaseData {
    my $self  = shift;
    my $sysid = $self->user_guid();#$self->attrAccessUserData("_sysid");

    my $obj;
=pod 不要項目の取得をなくす 2010/07/09
    my $sql = "SELECT
 m.owid, m.status_flag, m.subno, m.guid, m.carrier, m.mobilemailaddress, m.intr_id, m.family_name, m.first_name, m.family_name_kana, m.first_name_kana,
 m.personality, m.bloodtype, m.occupation, m.sex, m.year_of_birth, m.month_of_birth,m.date_of_birth,
 m.prefecture, m.zip, m.city, m.street, m.address, m.tel,
 m.point, m.adminpoint, m.limitpoint, m.pluspoint,m.minuspoint, m.registration_date, m.withdraw_date,
 pr.nickname, MAKE_SET(pr.profile_bit, 1, 2, 4, 8, 16, 32, 64, 128, 512) AS profile_set, pr.tuserimagef_id, pr.selfintroduction,
 i.distance,i.iArea_code,i.iArea_areaid,i.iArea_sub_areaid,
 i.iArea_region,i.iArea_name,i.iArea_prefecture,
 i.startpoint_ido,i.startpoint_keido,i.endpoint_ido,i.endpoint_keido
  FROM tMemberM m
  LEFT JOIN
   tMyIchi i ON (m.owid=i.owid)
  LEFT JOIN 
   tProfilePageSettingM pr
  ON (m.owid=pr.owid)
  WHERE m.guid=?
";
=cut
    my $sql = "SELECT
 m.owid, m.status_flag, m.subno, m.guid, m.carrier, m.mobilemailaddress, m.intr_id, m.personality, m.bloodtype, m.occupation, m.sex,
 m.year_of_birth, m.month_of_birth,m.date_of_birth, m.prefecture, m.point,
 pr.nickname, MAKE_SET(pr.profile_bit, 1, 2, 4, 8, 16, 32, 64, 128, 512) AS profile_set, pr.tuserimagef_id, pr.selfintroduction,
 i.distance,i.iArea_code,i.iArea_areaid,i.iArea_sub_areaid,
 i.iArea_region,i.iArea_name,i.iArea_prefecture,
 i.startpoint_ido,i.startpoint_keido,i.endpoint_ido,i.endpoint_keido
  FROM tMemberM m
  LEFT JOIN
   tMyIchi i ON (m.owid=i.owid)
  LEFT JOIN 
   tProfilePageSettingM pr
  ON (m.owid=pr.owid)
  WHERE m.guid=?
";


    my $dbh   = $self->getDBConnection();

    $self->setDBCharset('SJIS');

    my $arrayref = $dbh->selectall_arrayref($sql, { Columns => {} }, $sysid);
    map { $obj->{$_} = $arrayref->[0]->{$_} } keys %{ $arrayref };

    ## 生年月日があるある場合は年齢を計算して格納
    my $birthday = sprintf("%04d-%02d-%02d", $obj->{year_of_birth}, $obj->{month_of_birth}, $obj->{date_of_birth});
    $obj->{age} = MyClass::WebUtil::calculateAge($birthday);

    return if !defined($obj);

    ## カート用一時ID割り振り
    #$obj->{_orid} = MyClass::WebUtil::generateOrderID();

    ## 会員種別
    #$obj->{member_status} = $self->fetchOneValueFromConf("MEMBER_STATUS", ((log($obj->{memberstatus_flag}) / log(2))-1));

    return $obj;
}

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 会員登録・認証関連 END @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


#******************************************************
# @access	private
# @desc		select template code from database table
# @param	
# @return	
#******************************************************
sub _getDBTmpltFile {
    my $self    = shift;
    my $tmpltid = $self->getTmpltID() || 1;

    my $dbh = $self->getDBConnection();
    $self->setDBCharset('SJIS');
    my $myTmpltFile = MyClass::JKZDB::TmpltFile->new($dbh);
    $self->{tmplt}  = $myTmpltFile->fetchTmpltCodeByTmpltID({
                              tmpltm_id => $tmpltid, carrier => $self->attrAccessUserData("carriercode")
                      });

    return $self->{tmplt};
}


#******************************************************
# @access	private
# @desc		select template code from database table by tmplt name
# @param	string $tmplt_name OR action
# @return	
#******************************************************
sub _getDBTmpltFileByName {
    my $self       = shift;
    my $tmplt_name = $_[0] || $self->action();

    my $dbh = $self->getDBConnection();
    $self->setDBCharset('SJIS');
    my $myTmpltFile = MyClass::JKZDB::TmpltFile->new( $dbh, 1 );

   ## デバッグ用に指定の子テンプレートを明示的に取得
    $self->{tmplt}  =
        ( defined ($self->_debugTMPLT()) )
        ?
        $myTmpltFile->fetchTmpltCodeByTmpltName({ tmplt_name => $tmplt_name, carrier => $self->attrAccessUserData("carriercode"), debug => 1, tmpltfile_id => $self->_tmpltfile_id() })
        :
        $myTmpltFile->fetchTmpltCodeByTmpltName({ tmplt_name => $tmplt_name, carrier => $self->attrAccessUserData("carriercode") })
        ;
    return $self->{tmplt};
}


#******************************************************
# @access	private
# @desc		select template from directory(tmplt code in a file)
# @param	
# @return	
#******************************************************
sub _getTmpltFile {
    my $self = shift;

    my @carrier = ('docomo', 'softbank', 'au');
    $self->{tmplt} = sprintf("%s/%s/%s", $self->cfg->param('TMPLT_DIR'), $carrier[$self->attrAccessUserData("carriercode")-1], $self->action);

    return $self->{tmplt};
}


#******************************************************
# 
#******************************************************
sub _debugTMPLT {
    my $self = shift;
    $self->{debugTMPLT} = $self->query->param('debug');
    return $self->{debugTMPLT};
}

#******************************************************
# テンプレートファイルのidを取得(デバッグ用)
#******************************************************
sub _tmpltfile_id {
    my $self = shift;
    $self->{tmpltfile_id} = $self->query->param('tf');

    return $self->{tmpltfile_id};
}


#******************************************************
# 実行中のメソッド名取得
#******************************************************
sub _myMethodName {
    my @stack = caller(1);
    my $methodname = $stack[3];
    $methodname =~ s{\A .* :: (\w+) \z}{$1}xms;
    return $methodname;
}


#******************************************************
# @desc      configuration fileから設定情報を取得
# @param    
# @return   
#******************************************************
sub setup_configuration {
    my ($class, $configfile) = @_;

    my $config = YAML::LoadFile($configfile);
    $class->class_component_reinitialize( reload_plugin => 1 );
    my $plugin_config = {};
    for my $plugin (@{ $config->{plugins} }) {
        $plugin_config->{$plugin->{module}} = $plugin->{config} || {};
    }
    $config->{plugin_config} = $plugin_config;

    $config;
}


#******************************************************
# @desc     __PACKAGE__->load_plugins(@plugins); をこのメソッド行う
# @param    
# @return   
#******************************************************
sub setup_plugins {
    my $self = shift;

    my @plugins;
    for my $plugin (@{ $self->config->{plugins} }) {
        push @plugins, $plugin->{module};
    }

    $self->load_plugins(@plugins);
    #$self->run_hook('plugin.fixup');
}



#******************************************************
# @ クラスメソッドではない
# @desc		check your session
# @return	boolean
#******************************************************
sub checklimit {
    my $check = shift;

    my ($secg,$ming,$hourg,$mdayg,$mong,$yearg,$wdayg,$ydayg,$isdstg) = gmtime(time - 24*60*60);
    my $limit = sprintf("%04d%02d%02d%02d%02d%02d",$yearg +1900,$mong +1,$mdayg,$hourg,$ming,$secg);

    return ($check < $limit ? 0 : 1);
}


#******************************************************
# @access	public
# @desc		オペコード情報 デバッグ：開発用
# @param	
# @return	
#******************************************************
sub b_terse {
    my $class = shift;
    $class->b_terse_largest();
}

sub b_terse_largest {
    my $package                  = shift;

   eval ("use B::TerseSize;"); die "[error] B::TerseSize IS NOT INSTALLED \n" if $@;

    my ($symbols, $count, $size) = B::TerseSize::package_size($package);
    my ($largest)                =
        sort { $symbols->{$b}{size} <=> $symbols->{$a}{size} }
        grep { exists $symbols->{$_}{count} }
        keys %$symbols;

    print " Total size for $package is $size in $count ops <br />";
    print " Reporting $largest <br />";
    B::TerseSize::CV_walk( 'root', $package . '::' . $largest );

}


1;

__END__