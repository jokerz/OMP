#******************************************************
# @desc        
# @desc        ここは会員処理を実行する
# @package    MyClass::JKZRegistration
# @access    public
# @author    Iwahase Ryo
# @create    2010/01/07
# @update    2010/01/26  友達紹介登録
# @update    2010/01/26  アフィリエイト経由登録…成果反映処理
# @update    2010/01/26  会員DB tMemberMにデータ格納時の処理追加 アフィリの場合・友達紹介の場合etc と関連テーブル処理
# @update    2010/02/02  友達紹介処理追加 
# @update    2010/07/01  公開設定情報用レコード生成追加
# @version    1.00
#******************************************************
package MyClass::JKZRegistration;

use strict;
use warnings;
use 5.008005;
our $VERSION = '1.00';

use base qw(MyClass);

use MyClass::WebUtil;
use MyClass::JKZSession;
use MyClass::JKZHtml;
use MyClass::JKZDB::Member;
use MyClass::JKZDB::ProfilePageSetting;
use MyClass::JKZDB::UserRegistLog;
use MyClass::JKZDB::AffiliateAccessLog;
use MyClass::JKZDB::FriendIntroAccessLog;
use MyClass::JKZDB::AdminPointConf;
use MyClass::JKZDB::PointLog;

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
# @access    public
# @desc        会員情報登録処理
#
# @param    s  セッションID
# @param    t  メールの処理タイプ(tMailSettingMとのID) 1 = regist 3 = modify
# @param    メール本文リンクからの遷移は tとs パラメータ Webではaパラメータがある
# @param    
# @return    
#******************************************************
sub run {
    my $self = shift;
    my $obj    = {};

    $self->setAccessUserData();
    $self->setMicrotime("t0");
    $self->connectDB();

    my $q = $self->query;

    ## tが無い場合はNGもしくはアクションパラメータaが無い
    if (!$q->param('t') && !$q->param('a')) {
        my $msg = $self->ERROR_MSG("ERR_MSG18");
        $obj    = $self->printErrorPage($msg);
    }
    else {
        my $method;

        if ($q->param('a') && "" ne $q->param('a')) {
            $method = $self->action();
        }
        elsif ($q->param('t') && "" ne $q->param('t')) {
            my @methods = (
                'registration_form',
                '',
                'modify_mobilemailaddress',
            );

            my $t   = int($q->param('t'));
            $method = $methods[$t-1];
            $self->action($method);
        }

        $obj = $self->can($method) ? $self->$method() : $self->printErrorPage("invalid method called");
    }

    $obj->{MAINURL}                      = $self->MAINURL();
    $obj->{MEMBERMAINURL}                = sprintf("%s?guid=ON", $self->MEMBER_MAIN_URL());
    $obj->{SITEIMAGE_SCRIPTDATABASE_URL} = $self->CONFIGURATION_VALUE('SITEIMAGE_SCRIPTDATABASE_NAME');
   ## テストのために会員を１
    ## 会員はログインしていない。もしくは非会員
    $obj->{IfNotMemberLoggedIn} = 1;

    #$obj->{IfMemberLoggedIn} = 1;

   ## 会員用フッター処理 BEGIN
    my $tmpobj          = $self->_getDBTmpltFileByName('footer_html');
    my $footer_obj      = MyClass::JKZHtml->new({}, $tmpobj, 1, 0);
    $obj->{FOOTER_HTML} = $footer_obj->convertHtmlTags({ MAINURL => $obj->{MAINURL}, MEMBERMAINURL => $obj->{MEMBERMAINURL} });

    $self->processHtml($obj);

    $self->disconnectDB();

}


#******************************************************
# @access    public
# @desc        本登録フォームの表示と空メール登録の確認処理
# @param    
# @return    
#******************************************************
sub registration_form {
    my $self = shift;
    my $obj  = {};
    my $session_id = $self->query->param('s');

    ## テスト・PCでの確認用
    my $DEBUG_FLAG = 0;
    unless ($DEBUG_FLAG) {

        if (!$session_id) {
            $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG19");
            $obj->{IfError}   = 1;
            return $obj;
        }

        my ($sguid, $screated_time) = MyClass::WebUtil::decodeMD5($session_id);
        ## MailAddressLogFのステータス更新時に必要 要変更
        $obj->{maillog_session_id} = $session_id;

        my $dbh = $self->getDBConnection();
        #*******************************
        # step 1) セッションの有効期限確認
        #*******************************
        my $sql;
        $sql = sprintf("SELECT IF(TIME_FORMAT(TIMEDIFF(NOW(), %s), '%H') < 24, 1, -1)", $screated_time);
        if( 0 > $dbh->selectrow_array($sql) ) {
            $obj->{ERROR_MSG} =  $self->ERROR_MSG("ERR_MSG19");
            $obj->{IfError}   = 1;
            return $obj;
        }

        $sql = sprintf("SELECT guid, new_mobilemailaddress, IFNULL(former_mobilemailaddress, -1) FROM %s.tMailAddressLogF WHERE session_id=? AND status_flag=1", $self->waf_name_space());
        my ($guid, $new_mobilemailaddress, $former_mobilemailaddress) = $dbh->selectrow_array($sql, undef, $session_id);

        if(!$guid) {
            $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG6");
            $obj->{IfError}   = 1;
            return $obj;
        }

    ## 偽装などが内容にセッションデータと登録ﾒｰﾙアドレスを暗号化して、DBに本登録前に比較してから完了とするため
    #$obj->{encryptid} = MyClass::WebUtil::encodeMD5($new_mobilemailaddress, $guid);

        $obj->{encryptid} = MyClass::WebUtil::createHash($guid, 32);
    }

    my $prefecturelist    = $self->fetchValuesFromConf("PREFECTURE");
    my $personalitylist   = $self->fetchValuesFromConf("PERSONALITY");
    my $occupationlist    = $self->fetchValuesFromConf("OCCUPATION");
    map { $obj->{$_} = $prefecturelist->{$_}  } %{ $prefecturelist };
    map { $obj->{$_} = $personalitylist->{$_} } %{ $personalitylist };
    map { $obj->{$_} = $occupationlist->{$_}  } %{ $occupationlist };

    $obj->{IfNoError} = 1;

    return $obj;
}


#******************************************************
# @access    public
# @desc        登録処理
# @desc        Sessionテーブルにsessionデータがあるかないかで処理の分岐
#             step1) queryから入力値を取得。入力値チェック 生年月日から年齢生成
#             step2) 入力値チェックがOKの場合Sessionを生成して、情報を格納し、確認ページ表示
#             step3) 内容確認がOKならutn,guid=ONで登録実行。
#            step4) 仮登録が完了していて、かつメールアドレスが一致するかチェック
#            step5) 携帯端末情報を取得
#             step6) Sessionを開き、登録データを取得し、#会員マスターにInsert
#  追加0701   stop6-2) ProfilePageSettingに会員IDだけを格納
#             step7-1) アフィリエイトのデータチェック(最後に成果報告プログラムの実行)
#             step7-2) 成果先URLのチェック
#             step7-3) 成果先URLが存在する場合はソケット通信で成果送信
#             
#             
#             
#             
#             
# @param    
# @return    
#******************************************************
sub confirm_registration {
    my $self = shift;

    my $q = $self->query();
    my $obj = {};

    #if ($q->param('debug') && 0 < $q->param('tf')) {
    #    $obj->{IfRegistrationSuccess} = 1;
    #    return $obj;
    #}

    ## Post以外は認めない。メッセージは「正常処理できません」を表示
    if (!$q->MethPost()) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG99");
        $obj->{IfRegistrationFailure} = 1;
        return $obj;
    }
    $obj->{encryptid} = $q->param('encrypt');

    my $dbh = $self->getDBConnection();
    $self->setDBCharset('SJIS');
    #***********************************
    ## 確認画面 属性fの値がある場合
    #***********************************
    if (defined($q->param('f'))) {
        $obj->{IfForm} = 1;

        $obj->{maillog_session_id} = $q->param('maillog_session_id');

        #***********************************
        # step1) 入力値確認
        #***********************************
        ## ﾆｯｸﾈｰﾑ
        $obj->{nickname}    = $q->param('nickname');
        ## 系統
        $obj->{personality} = $q->param('personality');
        ## 血液型
        $obj->{bloodtype}   = $q->param('bloodtype');
        ## 職業
        $obj->{occupation}  = $q->param('occupation');
        ## 性別
        $obj->{sex}         = int($q->param('sex'));
        ## 生年月日を年齢計算 年齢がNGなら正常値が入力されなかったことになる
        if ($q->param('year_of_birth') ne "") {
            if ($q->param('month_of_birth') ne "" && 13 > $q->param('month_of_birth')) {
                if ($q->param('date_of_birth') ne "" && 32 > $q->param('date_of_birth')) {
                    my $birthday = sprintf( "%04d-%02d-%02d",$q->param('year_of_birth'), $q->param('month_of_birth'), $q->param('date_of_birth') );
                    $obj->{yourAge} = !($birthday = MyClass::WebUtil::calculateAge($birthday)) ? undef : $birthday;
                    if (defined($obj->{yourAge})) {
                        $obj->{year_of_birth}    = sprintf( "%04d", $q->param('year_of_birth') );
                        $obj->{month_of_birth}   = sprintf( "%02d", $q->param('month_of_birth') );
                        $obj->{date_of_birth}    = sprintf( "%02d", $q->param('date_of_birth') );
                    } else {
                        $obj->{ERROR_MSG} .= $self->ERROR_MSG('ERR_MSG4');
                    }
                }
            }
        }
        ## 都道府県
        $obj->{prefecture}  = $q->param('prefecture');

        #***********************************
        # step2) 入力値チェックがOKの場合、複合化したsession_idをキーにSessionテーブルに情報を格納
        #***********************************
        ## 新規にデータを格納は属性fの値が０より小さい場合。０より大きい場合は情報の修正からの遷移になるため、データを更新
        my $sess_ref = (0 > $q->param('f')) ? MyClass::JKZSession->open($obj->{encryptid}, {flag => 1}) : MyClass::JKZSession->open($obj->{encryptid});

        if (defined($sess_ref)) {
            #pod ひとつづつではなくまとめてに変更
            map { $sess_ref->attrData($_, $obj->{$_}) } keys %{$obj};
            ## Sessionを保存して閉じる
            $sess_ref->save_close() if defined($sess_ref);
        }

        $obj->{personalityDescription} = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('PERSONALITY', $obj->{personality}));
        $obj->{occupationDescription}  = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('OCCUPATION', $obj->{occupation}));
        $obj->{prefectureDescription}  = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('PREFECTURE', $obj->{prefecture}));

        (1 == $obj->{sex})      ? $obj->{IfMale}    = 1 :
        (2 == $obj->{sex})      ? $obj->{IfFemale}  = 1 :
                               $obj->{IfSexUnKnown} = 1 ;

        (1 == $obj->{bloodtype}) ? $obj->{IfTypeA}  = 1 :
        (2 == $obj->{bloodtype}) ? $obj->{IfTypeAB} = 1 :
        (3 == $obj->{bloodtype}) ? $obj->{IfTypeB}  = 1 :
        (4 == $obj->{bloodtype}) ? $obj->{IfTypeO}  = 1 :
                              $obj->{IfTypeUnKnown} = 1 ;

        my $personalitylist   = $self->fetchValuesFromConf("PERSONALITY", $obj->{personality});
        my $occupationlist    = $self->fetchValuesFromConf("OCCUPATION", $obj->{occupation});
        my $prefecturelist    = $self->fetchValuesFromConf("PREFECTURE", $obj->{prefecture});
        map { $obj->{$_} = $personalitylist->{$_} } %{ $personalitylist };
        map { $obj->{$_} = $occupationlist->{$_}  } %{ $occupationlist };
        map { $obj->{$_} = $prefecturelist->{$_}  } %{ $prefecturelist };

        $obj->{IfReConfirm} = 1;#(1 == $obj->{IfInputError}) ? 0 : 1;
    } else {
    #***********************************
    ## 登録
    #***********************************

#******************************************************
# 1 2 4 16 はプラス 8 32 はマイナス
# 0 1 2 4           3 5
# 会員登録時付与 ポイント広告付与 友達紹介ポイントバック ポイント消費(商品交換) 管理ポイント付与 管理ポイント消費
#
#******************************************************
my $OPERATOR = [ 
    { operator => '+', type_of_point => 1  },
    { operator => '+', type_of_point => 2  },
    { operator => '+', type_of_point => 4  },
    { operator => '-', type_of_point => 8  },
    { operator => '+', type_of_point => 16 },
    { operator => '-', type_of_point => 32 },
];

        #***********************************
        # step4) 携帯端末情報を取得
        #     subno $mobileagent->serial_number()
        #     DoCoMo only FormaCardID
        #     SB x-jphone-uid DoCoMo dcmguid AU subno $mobileagent->getDCMGUID()
        #***********************************
        my $mobileagent     = MyClass::JKZMobile->new();
        $obj->{carriercode} = $mobileagent->getCarrierCode();
        $obj->{subno}       = $mobileagent->getSubscribeNumber();
        $obj->{guid}        = $mobileagent->getDCMGUID();

        #***********************************
        # step5) Sessionを開き、登録データを取得し、会員マスターにInsert
        #***********************************
        my $sess_ref;
        if (defined($sess_ref = MyClass::JKZSession->open($obj->{encryptid}, {expire => 3600}))) {

        #***********************************
        # step6) 仮登録の完了をチェック
        #***********************************
            my $maillog_session_id = $sess_ref->attrData("maillog_session_id");
            my $sql = sprintf("SELECT new_mobilemailaddress FROM %s.tMailAddressLogF WHERE session_id=? and status_flag=1;", $self->waf_name_space());
            my $mobilemailaddress = $dbh->selectrow_array($sql, undef, $maillog_session_id);
            if (!$mobilemailaddress) {
                $obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $self->ERROR_MSG("ERR_MSG6"));
                $obj->{IfRegistrationFailure} = 1;
                return $obj;
            }

            $mobilemailaddress =~ s/[\<|\>]//g;

            #*********************************************
            # Modified STEP 7-1)  アフィリエイト
            # 最後に成果報告プログラムの実行 2010/01/26
            #*********************************************
            my $myAffiliate = MyClass::JKZDB::AffiliateAccessLog->new($dbh);
            my $afref       = $myAffiliate->fetchAcdAfcdByDateTimeGuid($obj->{guid});
            my $acd         = $afref->{acd}  || undef;
            my $afcd        = $afref->{afcd} || undef;

            #*****************************
            # Modified  STEP 7-2 ) 成果先URLのチェック 2010/01/26
            #*****************************
            (my $return_url = $afref->{return_url}) =~ s{ %&(.*?)&% }{ exists( $afref->{$1} ) ? $afref->{$1} : "" }gex;
            ## 不正チェックフラグ

            ## 友達紹介フラグ
            my $FRIEND_FLAG = 0;

            ## 還元・付与ポイント用変数
            my ( $adminpoint, $adminintrpoint );

            ## 登録本人用変数
            my ( $myPoint, $myMember, $myProfilePageSetting, $myUserRegistLog, $myPointLog );

            ## 紹介元用変数
            my ( $friendMember, $friendPointLog );

            #***********************************
            # 初期ポイント付与処理 新規登録ポイントは 1 友達紹介ポイントバックは4
            #***********************************
            $myPoint        = MyClass::JKZDB::AdminPointConf->new($dbh);
            $adminpoint     = $myPoint->getOneValueSQL({
                                column      => 'adminpoint',
                                whereSQL    => 'type_of_point=? AND status_flag=?',
                                placeholder => [1, 2],
                              });

            #*********************************************
            # Modified STEP 7-1)  友達紹介確認
            #*********************************************
            my $myIntrID = MyClass::JKZDB::FriendIntroAccessLog->new($dbh); 
            my $friend_ref;
            if ( $friend_ref = $myIntrID->fetchFriendIntrIDOwIDGuIDByDateTimeGuid($obj->{guid}) ) {
                map { $obj->{$_} = $friend_ref->{$_} } qw(friend_intr_id friend_owid friend_guid);
              ## 紹介元intr_idがOKならフラグをたてる
                $FRIEND_FLAG = 1;

              ## 紹介元に還元するポイント
                $adminintrpoint  = $myPoint->getOneValueSQL({
                                       column      => 'adminpoint',
                                       whereSQL    => 'type_of_point=? AND status_flag=?',
                                       placeholder => [4, 2],
                                    });
            }

            #*********************************************
            # 会員マスター格納データ(tMemberM)会員登録本人データ処理準備
            # 初期ポイント処理・アフィリ等 intr_idはguidを32文字の暗号文字列に変換
            #*********************************************
            my $insertData = {
                owid                => -1,
                status_flag         => 2,
                subno               => $obj->{subno},
                guid                => $obj->{guid},
                carrier             => 2 ** $obj->{carriercode},
                memberstatus_flag   => 2,
                mailstatus_flag     => 2,
                mobilemailaddress   => $mobilemailaddress,
                sessid              => $obj->{encryptid},
                intr_id             => MyClass::WebUtil::createHash($obj->{guid}, 32),
                friend_intr_id      => $obj->{friend_intr_id},
                nickname            => $sess_ref->attrData("nickname"),
                personality         => 2 ** $sess_ref->attrData("personality"),
                bloodtype           => 2 ** $sess_ref->attrData("bloodtype"),
                occupation          => 2 ** $sess_ref->attrData("occupation"),
                sex                 => 2 ** $sess_ref->attrData("sex"),
                year_of_birth       => $sess_ref->attrData("year_of_birth"),
                month_of_birth      => $sess_ref->attrData("month_of_birth"),
                date_of_birth       => $sess_ref->attrData("date_of_birth"),
                prefecture          => 2 ** $sess_ref->attrData("prefecture"),
                adminpoint          => $adminpoint,
                point               => $adminpoint,
                adv_code            => $acd,
                afcd                => $afcd,
                useragent           => $ENV{'HTTP_USER_AGENT'},
            };

            ## registration/withdraw logdata
            my $insertLogData = {
                id          => -1,
                owid        => "",
                guid        => $obj->{guid},
                subno       => $obj->{subno},
                carrier     => 2 ** $obj->{carriercode},
                status_flag => 2,
                acd         => $acd,
                intr_id     => $obj->{friend_intr_id},
            };

            my $mailaddresssql = sprintf("UPDATE %s.tMailAddressLogF SET status_flag=? WHERE session_id=? AND status_flag=1", $self->waf_name_space());

            $myMember             = MyClass::JKZDB::Member->new($dbh);
            $myProfilePageSetting = MyClass::JKZDB::ProfilePageSetting->new($dbh);
            $myUserRegistLog      = MyClass::JKZDB::UserRegistLog->new($dbh);
            $myPointLog           = MyClass::JKZDB::PointLog->new($dbh);

            if ($FRIEND_FLAG) {
                $friendMember   = MyClass::JKZDB::Member->new($dbh);
                $friendPointLog = MyClass::JKZDB::PointLog->new($dbh);
            }

            ## autocommit設定をoffにしてトランザクション開始
            my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);

            eval {

            ## 会員データのインサートおよび会員IDの取得
                $myMember->executeUpdate($insertData);
                my $owid = $myMember->mysqlInsertIDSQL();
            ## 公開設定情報レコード作成
                $myProfilePageSetting->insertOWID($owid);
                ## 登録ログ
                $insertLogData->{owid} = $owid;
                $myUserRegistLog->executeUpdate($insertLogData);
                
                ## メールアドレス登録情報のステータス更新
                $dbh->do($mailaddresssql, undef, 2, $maillog_session_id);
                
                ## 登録時のサービスポイントの処理
                if (0 < $adminpoint) {
                        $myPointLog->executeUpdate({
                            id            => -1,
                            owid          => $owid,
                            guid          => $obj->{subno},
                            type_of_point => 1,
                            point         => $adminpoint,
                        });
                }

             #***********************************
             # 紹介元フラグがあれば友達にﾎﾟｲﾝﾄ付与処理
             #***********************************
                if ($FRIEND_FLAG) {
                    $friendMember->updatePointSQL({
                        owid     => $obj->{friend_owid},
                        point    => $adminintrpoint,
                        operator => $OPERATOR->[2]->{operator},
                     });

                    $friendPointLog->executeUpdate({
                        id            => -1,
                        owid          => $obj->{friend_owid},
                        guid          => $obj->{friend_guid},
                        type_of_point => $OPERATOR->[2]->{type_of_point},
                        point         => $adminintrpoint,
                    });
                }
             ## コミット
                $dbh->commit();
            };
            ## 失敗のロールバック
            if ($@) {
                $dbh->rollback();
                ## トランザクションエラーのメッセージ
                $obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $self->ERROR_MSG("ERR_MSG20"));
                $obj->{IfRegistrationFailure} = 1;
            } else {
                $obj->{IfRegistrationSuccess} = 1;
                ## ERR_MSG0は登録完了メッセージ
                $obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $self->ERROR_MSG("ERR_MSG0"));

            #*****************************
            # Modified STEP 7-3 ) 成果先URLが存在する場合はソケット通信で成果送信 2010/01/26
            #*****************************
                if ($return_url) {
                    my $afpl = $self->CONFIGURATION_VALUE("AFFILIATE_SOCKET_SCRIPT");
                    $return_url =~ s/&/\\&/g;
                    system("perl $afpl $return_url");
                }
            #*****************************
            # Modified STEP 7-3 ) 友達紹介でポイントを還元したらキャッシュをクリアする。orポイントデータが時間によって反映されてみえない
            #*****************************
                if ($FRIEND_FLAG) {
                    my $tmp       = $obj->{friend_guid};
                    my $namespace = $self->waf_name_space() . 'memberdata';
                    $self->deleteFromCache("$namespace:$tmp");
                }
            }
            ## Sessionテーブルの情報を掃除して、きちんと終了する。
            $sess_ref->clear_session() if defined($sess_ref);
            ## autocommit設定を元に戻す
            MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
        }
    }

    ## 会員登録完了後のﾛｸﾞｲﾝページへのリンク用
    $obj->{MEMBERMAINURL} = sprintf("%s?guid=ON", $self->MEMBER_MAIN_URL());

    return $obj;
}



1;

__END__
