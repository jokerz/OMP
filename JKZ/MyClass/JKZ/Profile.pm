#******************************************************
# @desc        
# @desc        ここは会員処理を実行する
# @package    MyClass::JKZ::Profile
# @access    public
# @author    Iwahase Ryo
# @create    2010/06/11
# @update    
# @version    1.00
#******************************************************
package MyClass::JKZ::Profile;

use strict;
use warnings;
use 5.008005;
our $VERSION = '1.00';


use base qw(MyClass::JKZ);

use MyClass::WebUtil;
use MyClass::JKZSession;
use MyClass::JKZDB::Member;
use MyClass::JKZDB::UserRegistLog;
use MyClass::JKZDB::PointLog;
use MyClass::JKZDB::JISX0401;
use MyClass::JKZDB::ProfilePageSetting;
use MyClass::JKZDB::UserImage;

use JKZ::Mobile::Emoji;

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
# @desc      公開情報設定
# @param    
# @return    
#******************************************************
sub edit_profile_setting {
    my $self = shift;
    my $q = $self->query();

    my $sysid     = $self->user_guid();
    my $namespace = $self->waf_name_space() . 'memberdata';
    my $obj       = $self->getFromCache("$namespace:$sysid");
    if (!$obj) {
        $self->openMemberSession();
        $obj = $self->getFromCache("$namespace:$sysid");
    }

    my @open_status_flags;
    ## プロフィール公開設定ビット値を取得
    @open_status_flags = map { log($_) / log(2) } split(/,/, $obj->{profile_set});

    no strict ('subs');
    my @IfOpenFlag = (
        undef,
        IfPersonality,
        IfBloodType,
        IfOccupation,
        IfSex,
        IfAge,
        IfPrefecture,
        IfAreaNow,
    );
   
    foreach my $i (1..7) {
        $obj->{$IfOpenFlag[$i]} = 1 if grep(/$i/, @open_status_flags);
    }

    $obj->{selfintroduction}        = JKZ::Mobile::Emoji::hex2emoji($obj->{selfintroduction});
    $obj->{EscapedSelfIntroduction} = $q->escapeHTML($obj->{selfintroduction});
    $obj->{selfintroduction}        = MyClass::WebUtil::yenRyenN2br($obj->{selfintroduction});

    $obj->{skey}  = $self->owid_ciphered();

    return $obj;

}


#******************************************************
# @access    public
# @desc      公開情報更新
# @param    
# @return    
#******************************************************
sub modify_profile_setting {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    my $owid = $self->owid();

    unless ( $q->MethPost() || $q->param('s') ) {
        ## 正常処理続行不可
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG98');

        return $obj;
    }

    my $nickname         = $q->param('nickname');
    my $selfintroduction = $q->param('selfintroduction');


    ## 絵文字を10 進数表記に変換する（表示するとき16進数変換する）
    ## 絵文字を16進数変換 キャリア区別のために[docomo:xxxx] [softbank:xxxx] [kddi:xxxx]とかにする

    $selfintroduction = JKZ::Mobile::Emoji::emoji2hex($selfintroduction);

    my $profile_bit;
    map { $profile_bit += 2 ** $_ } $q->param('open_status');
    $self->_setProfileBit({ owid => $owid, nickname => $nickname, profile_bit => $profile_bit, selfintroduction => $selfintroduction } );

    my $sysid     = $self->user_guid();
    my $namespace = $self->waf_name_space() . 'memberdata';
    $self->initMemcachedFast()->delete("$namespace:$sysid");
    my $sess_ref = MyClass::JKZSession->open($sysid);
    $sess_ref->clear_session() if defined $sess_ref;

    $self->action('edit_profile_setting');
    return $self->edit_profile_setting();

}


#******************************************************
# @desc        ユーザー個人情報
# @param    
# @param    
# @return    
#******************************************************
sub view_profile {
    my $self = shift;

    my $sysid     = $self->attrAccessUserData("_sysid");
    my $namespace = $self->waf_name_space() . 'memberdata';
    my $obj       = $self->getFromCache("$namespace:$sysid");
    if (!$obj) {
        $self->openMemberSession();
        $obj = $self->getFromCache("$namespace:$sysid");
    }

    ## SoftBankはメールアドレスに<>でくくられているため
    $obj->{mobilemailaddress}      =~ s/[\<|\>]//g;

    $obj->{personalityDescription} = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('PERSONALITY', (log($obj->{personality}) / log(2))));
    $obj->{occupationDescription}  = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('OCCUPATION', (log($obj->{occupation}) / log(2))));
    $obj->{prefectureDescription}  = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('PREFECTURE', (log($obj->{prefecture}) / log(2))));


    ( 2 == $obj->{sex} )      ? $obj->{IfMale}    = 1 :
    ( 4 == $obj->{sex} )      ? $obj->{IfFemale}  = 1 :
                            $obj->{IfSexUnKnown}  = 1;

    ( 2  == $obj->{bloodtype} ) ? $obj->{IfTypeA}  = 1 :
    ( 4  == $obj->{bloodtype} ) ? $obj->{IfTypeAB} = 1 :
    ( 8  == $obj->{bloodtype} ) ? $obj->{IfTypeB}  = 1 :
    ( 16 == $obj->{bloodtype} ) ? $obj->{IfTypeO}  = 1 :
                            $obj->{IfTypeUnKnown}  = 1;

    $obj->{intr_url}         = sprintf(
                                 "%s/%s?guid=ON&fintr_id=%s",
                                 $self->cfg->param('MEMBER_MAIN_URL'),
                                 $self->cfg->param('INTRODUCE_FRIEND_ACCESS_SCRIPT_NAME'),
                                 $obj->{intr_id}
                               );
    $obj->{escaped_intr_url} = $self->query->escape($obj->{intr_url});

    return $obj;
}


#******************************************************
# @desc        ユーザー個人情報編集
# @param    
# @param    
# @return    
#******************************************************
sub edit_profile {
    my $self = shift;
    my $obj  = {};

    $obj = $self->view_profile();
    my $prefecturelist;
   #***********************************
   # 郵便番号検索時はview_profileからの住所データを上書きする
   #***********************************
    if ($self->query->param('opt')) {
        my $method = $self->query->param('opt');
        my $searchobj = $self->can($method) ? $self->$method : undef;

        map { $obj->{$_} = $searchobj->{$_} } keys %{ $searchobj };
       ## 都道府県のコードは通常値
        $prefecturelist = $self->fetchValuesFromConf("PREFECTURE", $obj->{prefecture});
    }
    else {
       ## view_profileからの都道府県コードはbit値
        $prefecturelist = $self->fetchValuesFromConf("PREFECTURE", (log($obj->{prefecture}) / log(2)));
    }

    my $personalitylist = $self->fetchValuesFromConf("PERSONALITY", (log($obj->{personality}) / log(2)));
    my $occupationlist  = $self->fetchValuesFromConf("OCCUPATION", (log($obj->{occupation}) / log(2)));

    map { $obj->{$_} = $prefecturelist->{$_}  } %{ $prefecturelist };
    map { $obj->{$_} = $personalitylist->{$_} } %{ $personalitylist };
    map { $obj->{$_} = $occupationlist->{$_}  } %{ $occupationlist };

    $obj->{ENCRYPTGUID} = MyClass::WebUtil::encryptBlowFish($self->attrAccessUserData("_sysid"));


    my @open_status_flags;
    ## プロフィール公開設定ビット値を取得
    my @profile_bit = split(/,/, $self->_setProfileBit());
    @open_status_flags = map { log($_) / log(2) } @profile_bit;

    no strict ('subs');
    my @IfOpenFlag = (
        undef,
        IfPersonality,
        IfBloodType,
        IfOccupation,
        IfSex,
        IfAge,
        IfPrefecture,
    );
    foreach my $i (1..6) {
        $obj->{$IfOpenFlag[$i]} = 1 if grep(/$i/, @open_status_flags);
    }


    return $obj;
}


sub modify_profile {
    my $self = shift;

    $self->_modifyProfile();
}






#******************************************************
# @access    private
# @desc        会員情報の更新実行
# @param    
# @return    error message
#******************************************************
sub _modifyProfile {
    my $self  = shift;
    my $q     = $self->query();
    my $sysid = $self->attrAccessUserData("_sysid");
    my $obj   = {};

    $obj->{nickname}         = $q->param('nickname');
#    $obj->{family_name}      = $q->param('family_name');
#    $obj->{first_name}       = $q->param('first_name');
#    $obj->{family_name_kana} = $q->param('family_name_kana');
#    $obj->{first_name_kana}  = $q->param('first_name_kana');
    ## 系統
    $obj->{personality}      = 2 ** $q->param('personality');
    ## 血液型
    $obj->{bloodtype}        = 2 ** $q->param('bloodtype');
    ## 職業
    $obj->{occupation}       = 2 ** $q->param('occupation');
    ## 性別
    $obj->{sex}              = 2 ** int($q->param('sex'));

    ## 生年月日を年齢計算 年齢がNGなら正常値が入力されなかったことになる
    if ($q->param('year_of_birth') ne "") {
        if ($q->param('month_of_birth') ne "" && 13 > $q->param('month_of_birth')) {
            if ($q->param('date_of_birth') ne "" && 32 > $q->param('date_of_birth')) {
                my $birthday = sprintf( "%04d-%02d-%02d",$q->param('year_of_birth'), $q->param('month_of_birth'), $q->param('date_of_birth') );
                $obj->{yourAge} = !($birthday = MyClass::WebUtil::calculateAge($birthday)) ? undef : $birthday;
                if (defined($obj->{yourAge})) {
                    $obj->{year_of_birth}  = sprintf( "%04d", $q->param('year_of_birth') );
                    $obj->{month_of_birth} = sprintf( "%02d", $q->param('month_of_birth') );
                    $obj->{date_of_birth}  = sprintf( "%02d", $q->param('date_of_birth') );
                } else {
                    $obj->{ERROR_MSG} .= $self->ERROR_MSG('ERR_MSG4');
                }
            }
        }
    }
    ## 都道府県
    $obj->{prefecture}  = 2 ** $q->param('prefecture');
#    $obj->{zip}         = $q->param('zip');
#    $obj->{city}        = $q->param('city');
#    $obj->{street}      = $q->param('street');
#    $obj->{address}     = $q->param('address');
#    $obj->{tel}         = $q->param('tel');


    my $updateData = {
        guid    => $sysid,
        columns => {
            nickname         => undef,
#            family_name      => undef,
#            first_name       => undef,
#            family_name_kana => undef,
#            first_name_kana  => undef,
            personality      => undef,
            bloodtype        => undef,
            occupation       => undef,
            sex              => undef,
            year_of_birth    => undef,
            month_of_birth   => undef,
            date_of_birth    => undef,
            prefecture       => undef,
#            zip              => undef,
#            city             => undef,
#            street           => undef,
#            address          => undef,
#            tel              => undef,
        },
    };

    map { $updateData->{columns}->{$_} = exists($obj->{$_}) ? $obj->{$_} : "" } keys %{ $updateData->{columns} };

    my $dbh = $self->getDBConnection();
    my $myMember = MyClass::JKZDB::Member->new($dbh);

    ## autocommit設定をoffにしてトランザクション開始
    my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);

    eval {
        $myMember->updateMemberDataByGUIDSQL($updateData);
        $dbh->commit();
    };
    ## 失敗のロールバック
    if ($@) {
        $dbh->rollback();
        ## トランザクションエラーのメッセージ
    } else {
        my $namespace = $self->waf_name_space() . 'memberdata';
        $self->initMemcachedFast()->delete("$namespace:$sysid");
        ## session情報をクリアして、最新情報を取得する
        my $sess_ref = MyClass::JKZSession->open($sysid);
        map { $sess_ref->attrData($_, $updateData->{columns}->{$_}) } keys %{ $updateData->{columns} };
        $sess_ref->save_close() if defined($sess_ref);

    }
    ## autocommit設定を元に戻す
    MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
    ## 会員ﾒﾆｭｰにリダイレクト
    $self->action('view_profile');
    return $self->view_profile();
}


#******************************************************
# @access    
# @desc        退会処理
# @param    
# @return    
#******************************************************
sub withdraw_member {
    my $self = shift;
    my $obj = {};

   ## Postメソッドでかつsubmitパラメータがある場合は処理実行
    if ( $self->query->MethPost() && $self->query->param('submit') ) {
        $obj = $self->_withdrawMemberDB();
    }
    else {
        $obj->{IfWithdrawForm} = 1;
    }

    return $obj;
}


#******************************************************
# @access    private
# @desc        独自DB会員解約 解約ログ 会員入退会ログのフラグは会員DBと同じにする。２＝＞入会　４＝＞退会
# @param    
# @return    
#******************************************************
sub _withdrawMemberDB {
    my $self = shift;

    my $obj = {};

    my $sysid   = $self->attrAccessUserData("_sysid");
    my $subno   = $self->attrAccessUserData("subno");
    my $carrier = 2 ** $self->attrAccessUserData("carriercode");

    my $updateData = {
        guid    => $sysid,
        columns => {
            status_flag   => 4,
            withdraw_date => MyClass::WebUtil::GetTime("10"),
        }
    };

    my $insertLogData = {
        id          => -1,
        guid        => $sysid,
        subno       => $subno,
        carrier     => $carrier,
        status_flag => 4,
    };

    my $dbh = $self->getDBConnection();
    $self->setDBCharset('SJIS');

    my $myMember = MyClass::JKZDB::Member->new($dbh);
    my $myUserRegitsLog = MyClass::JKZDB::UserRegistLog->new($dbh);
    my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);

    eval {
        $myMember->updateMemberDataByGUIDSQL($updateData);
        $myUserRegitsLog->executeUpdate($insertLogData);
        $dbh->commit();
    };
    ## 失敗のロールバック
    if ($@) {
        $dbh->rollback();
        ## トランザクションエラーのメッセージ
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG20");
        $obj->{IfWithdrawFailure} = 1;
    } else {
        my $namespace = $self->waf_name_space() . 'memberdata';
        ## キャッシュをクリア
        $self->deleteFromCache("$namespace:$sysid");
        ## session情報をクリアして、最新情報を取得する
        my $sess_ref = MyClass::JKZSession->open($sysid);
        $sess_ref->clear_session() if defined $sess_ref;

        $obj->{IfWithdrawSuccess} = 1;
        ## ERR_MSG0は登録完了メッセージ←ばか！解約完了メッセージに変更
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG24");
        # 非会員用トップ
        $obj->{NONMEMBERMAINRUL} = sprintf("%s/%s", $self->MAIN_URL, $self->MAINURL);
    }
    ## autocommit設定を元に戻す
    MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);

    return $obj;
}



#******************************************************
# @access    private
# @desc        ﾌﾟﾛﾌｨｰﾙ公開項目設定
#            引数がある場合はデータ更新。無い場合はデータ取得
# @param    $obj $databasehandle
# @param    $integer 公開項目ビット値 / 無し
# @return    TRUE / profile_bit
#******************************************************
sub _setProfileBit {
    my $self = shift;
    my $dbh  = $self->getDBConnection();
    $self->setDBCharset('sjis');

    my $owid = $self->attrAccessUserData("owid");
    my $myProfilePageSetting = MyClass::JKZDB::ProfilePageSetting->new($dbh);

#**********************************
# cacheデータの更新をする処理
# を追加する必要あり2008/08/22
#**********************************
    ## 引数がある場合は公開項目レコード更新
    ## { owid => $owid, nickname=> $nickname, profile_bit => $profile_bit, selfintroduction => $selfintroduction }
    if (@_) {
        my $profile_bit = shift;
=pod
        $myProfilePageSetting->executeUpdate(
            {
                owid        => $owid,
                profile_bit => $profile_bit,
            }
        )
=cut
        $myProfilePageSetting->executeUpdate($profile_bit);

    }
    else {
        my $sets = $myProfilePageSetting->makeSet($owid);
        return ($sets);
    }
}


#******************************************************
# @access    public
# @desc        ﾌﾟﾛﾌｨｰﾙ画像を設定
# @return    
#******************************************************
sub set_ui {
    my ($self, $dbh) = @_;

    my $q = $self->query();
    my $tags = {};
    $tags->{c} = $self->_encryptParamC();
    $tags->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $tags->{c};

    my $owid = $self->_owid();
    my $tuserimagef_id = $q->param('tuserimagef_id');
    my $myProfilePageSetting = MyClass::JKZDB::ProfilePageSetting->new($dbh);
    if (!$myProfilePageSetting->executeUpdate({
        owid            => $owid,
        tuserimagef_id    => $tuserimagef_id,
    })) {
    
        $tags->{ERROR_MSG} = $self->_ERROR_MSG('ERR_MSG14');
        $self->_processHtml($tags);
    }
    else {
        $self->{action} = 'default';
        $self->default($dbh);
    }
}


#******************************************************
# @desc        郵便番号から住所検索
# @param    
# @param    
# @return    
#******************************************************
sub search_address_by_zipcode {
    my $self = shift;
    my $key_zipcode = $self->query->param('key_zipcode');

    return if $key_zipcode !~ /[0-9]{7}/;

    my $dbh      = $self->getDBConnection();
    $self->setDBCharset('sjis');
    my $jisx0401 = MyClass::JKZDB::JISX0401->new($dbh);

    my $ret = $jisx0401->fetchAddressByZipCode($key_zipcode);

    return $ret;
}


1;
__END__