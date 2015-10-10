#******************************************************
# @desc       会員コンテンツ配信クラス
# @desc       会員自身の処理
# @package    MyClass::JKZ::MemberContents
# @access     public
# @author     Iwahase Ryo
# @create     2010/00/10
# @version    1.00
# @update     
# パラメータ： a  = action
#              p  = product_id
#              c  = category_id
#              sc = subcategory_id
#******************************************************
package MyClass::JKZ::MemberContents;

use strict;
use warnings;
no warnings 'redefine';
use 5.008005;
our $VERSION = '1.00';

use base qw(MyClass::JKZ);

use MyClass::UsrWebDB;
use MyClass::WebUtil;
use MyClass::JKZHtml;
use MyClass::JKZLogger;

use MyClass::JKZDB::MessageInBox;
use MyClass::JKZDB::ProfilePageSetting;
use MyClass::JKZDB::MyMessageBoard;

use JKZ::Mobile::Emoji;



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
# @desc      デフォルト
#            会員情報のうち位置関連のhashは下記の通り
#            distance        iArea_code        iArea_areaid      iArea_sub_areaid,
#            iArea_region    iArea_name        iArea_prefecture
#            startpoint_ido  startpoint_keido
#            endpoint_ido    endpoint_keido
# @param    
# @return    
#******************************************************

sub default {
    my $self      = shift;
    #my $sysid     = $self->attrAccessUserData("_sysid");
    my $user_guid = $self->user_guid();
    my $namespace = $self->waf_name_space() . 'memberdata';
    my $obj       = $self->getFromCache("$namespace:$user_guid");
    if (!$obj) {
        $self->openMemberSession();
        $obj = $self->getFromCache("$namespace:$user_guid");
    }

    ## プロフィール公開設定ビット値を取得
    my @open_status_flags = map { log($_) / log(2) } split(/,/, $obj->{profile_set});

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
   my @IfCloseFlag = (
       undef,
       IfNoPersonality,
       IfNoBloodType,
       IfNoOccupation,
       IfNoSex,
       IfNoAge,
       IfNoPrefecture,
       IfNoAreaNow,
   );
    foreach my $i (1..7) {
        $obj->{$IfOpenFlag[$i]} = 1 if grep(/$i/, @open_status_flags);
        grep(/$i/, @open_status_flags) ? $obj->{$IfOpenFlag[$i]} = 1 : $obj->{$IfCloseFlag[$i]} = 1;
    }

   ## 自分自身の絵文字なのでキャリア変換は不要
    $obj->{selfintroduction} =~ s/\[.*?\:(f.{3})]/pack("H4", $1)/eg;
    # 表示用に改行コードを<br />に変換
    $obj->{selfintroduction} = MyClass::WebUtil::yenRyenN2br($obj->{selfintroduction});

    if ( $self->checkNULLStatusMessage() ) {
        $obj->{IfExistsNewMessage} = 1;
    }

    $obj->{IfImageDataNotExists} = 1;

    my $bbs = $self->message_of_messageboard({owid => $self->owid, record_limit => 2 });
    map { $obj->{$_} = $bbs->{$_} } keys %{ $bbs };


    return $obj;
}



#******************************************************
# @access    
# @desc        位置登録情報
# @return    
#******************************************************
sub ichi {
    my $self      = shift;
    my $sysid     = $self->user_guid();#$self->attrAccessUserData("_sysid");
    my $namespace = $self->waf_name_space() . 'memberdata';
    my $obj       = $self->getFromCache("$namespace:$sysid");
    if (!$obj) {
        $self->openMemberSession();
        $obj = $self->getFromCache("$namespace:$sysid");
    }

  return $obj;

}


#******************************************************
# @access    
# @desc        会員の未読メッセージ取得
# @return    1の場合通常のメッセ 2は画像付
#******************************************************
sub checkNULLStatusMessage {
    my $self = shift;
    my $owid = $self->owid();

    my $memcached = MyClass::UsrWebDB::MemcacheInit();
    my $namespace = $self->waf_name_space() . 'nullstatusmessage';
    my $status    = $memcached->get("$namespace:$owid");
    if (!$status) {
        my $dbh = $self->getDBConnection();
        my $myMessageInBox = MyClass::JKZDB::MessageInBox->new($dbh);
        $status = $myMessageInBox->checkNULLStatusMessage($owid);
#        $memcached->add ("nullstatusmessage:$owid", 0, 120) && return if !$true;

        $memcached->add("nullstatusmessage:$owid", $status, 120);
    }
    return $status;
}


#******************************************************
# @desc     掲示板に書き込み
# @param    
# @param    
# @return   
#******************************************************
sub write_message_board {
    my $self = shift;
    my $q    = $self->query();
    my $obj;
    my $toid              = $q->param('toid');
    my $owid              = $self->owid();#$q->param('owid');
    my $neighbor_nickname = $q->unescape($q->param('escape_neighbor_nickname'));
    my $nickname          = $self->attrAccessUserData("nickname");
    my $private_flag      = $q->param('private_flag') || 1;
    my $message           = $q->param('message');
    $message              = JKZ::Mobile::Emoji::emoji2hex($message);


    my $insertData = {
            msg_id            => -1,
            toid              => $toid,
            owid              => $owid,
            private_flag      => $private_flag,
            neighbor_nickname => $neighbor_nickname,
            nickname          => $nickname,
            message           => $message,
    };

    my $dbh            = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $MyMessageBoard = MyClass::JKZDB::MyMessageBoard->new($dbh);

    if (!$MyMessageBoard->executeUpdate($insertData)) {
        $obj->{IfFail} = 1;
    }
    else {
        $obj->{IfSuccess} = 1;
    }
    map { $obj->{$_} = $insertData->{$_} } qw(toid owid neighbor_nickname nickname);

    return $obj;
}


#******************************************************
# @desc     掲示板のメッセージ（自分の掲示板と他人の掲示板）
# @param    hash {データベースのwhere条件}
# @param    { record_limit, offset } 
# @return   
#******************************************************
sub message_of_messageboard {
    my $self = shift;
    my $ref  = shift;
    my $obj;

    my $record_limit    = $ref->{record_limit} || 20;
    my $offset          = $ref->{'off'} || 0;
    my $condition_limit = $record_limit+1;

    # Modified 2010/12/9
=pod
    my $condition;
    $condition->{whereSQL} = 'toid=? OR owid=?';
   ## 他人の掲示板を閲覧はtoid
   ## 自分の掲示板を閲覧はowid なにもない場合も自分とする
    @{ $condition->{placeholder} } = 
        exists($ref->{toid}) ? ( $ref->{toid},$ref->{toid} ) :
        exists($ref->{owid}) ? ( $self->owid, $self->owid )  :
                               ( $self->owid, $self->owid )  ;
=cut
   ## 他のユーザー掲示板を閲覧FLAG
   ## ０で自分データ 1で他のユーザー
    my $neighbor_flag   = exists($ref->{toid}) ? 1 : 0;
    my $condition;
    $condition->{whereSQL} = 'toid=? OR owid=?';
   ## 他人の掲示板を閲覧はtoid
   ## 自分の掲示板を閲覧はowid なにもない場合も自分とする
    @{ $condition->{placeholder} } =  $neighbor_flag ? ( $ref->{toid}, $ref->{toid} ) : ( $self->owid, $self->owid );

    $condition->{orderbySQL} = 'registration_date DESC';
    $condition->{limitSQL}   = "$offset, $condition_limit";

    my $dbh            = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $myMessageBoard = MyClass::JKZDB::MyMessageBoard->new($dbh);

    my $maxrec         = $myMessageBoard->getCountSQL(
                           {
                              columns     => "owid",
                              whereSQL    => $condition->{whereSQL},
                              orderbySQL  => $condition->{orderbySQL},
                              limitSQL    => $condition->{limitSQL},
                              placeholder => [@{ $condition->{placeholder} }],
                            }
                         );
    undef $myMessageBoard;

    my @navilink;
    ## レコード数が1ページ上限数より多い場合
    if ($maxrec > $record_limit) {
	    my $url = sprintf("%s&a=viewlist&msg_of_board", $self->MEMBERMAINURL());

        ## 前へリンクの生成
        if (0 != $offset) { ## 最初のページじゃない場合（2ページ目以降の場合）
            $obj->{IfExistsPreviousPage} = 1;
            $obj->{PreviousPageUrl} = sprintf("%s&off=%s", $url, ($offset - $record_limit));
        }
        ## 次へリンクの生成
        if (($offset + $record_limit) < $maxrec) {
            $obj->{IfExistsNextPage} = 1;
            $obj->{NextPageUrl} = sprintf("%s&off=%s", $url, ($offset + $record_limit));
        }
        ## ページ番号生成
        for (my $i = 0; $i < $maxrec; $i += $record_limit) {

            my $pageno = int ($i / $record_limit) + 1;

            if ($i == $offset) { ###現在表示してるﾍﾟｰｼﾞ分
                push (@navilink, $pageno);
            } else {
                my $pagenate_url = sprintf("%s&off=%s", $url, $i);
                push (@navilink, $self->query->a({-href=>$pagenate_url}, $pageno));
            }
        }
        @navilink = map{ "$_\n" } @navilink;

        $obj->{pagenavi} = join(' ', @navilink);
    }

    $obj->{totalrecord} = $maxrec;

    $myMessageBoard = MyClass::JKZDB::MyMessageBoard->new($dbh);
    $myMessageBoard->executeSelectList($condition);
    $obj->{DUMP} = Dumper($myMessageBoard);

no strict('refs');
    $obj->{LoopMyMessageList} = ( $record_limit == $myMessageBoard->countRecSQL() ) ? $record_limit-1 : $myMessageBoard->countRecSQL();
    if (0 <= $myMessageBoard->countRecSQL()) {
        $obj->{IfExistsMyMessageList} = 1;
        map {
            my $i = $_;
            foreach my $key (keys %{ $myMessageBoard->{columnslist} }) {
                $obj->{'msg_' . $key}->[$i] = $myMessageBoard->{columnslist}->{$key}->[$i];
            }

            # Modified 2010/12/09 BEGIN
            if ($neighbor_flag) { # 他のユーザーの掲示板の場合
                $obj->{msg_owid}->[$i] == $ref->{toid} ? $obj->{IfMsgTo}->[$i]  = 1 : $obj->{IfMsgFrom}->[$i] = 1;
            }
            else { # 自分の掲示板の場合
                $obj->{msg_toid}->[$i] == $self->owid ? $obj->{IfMsgFrom}->[$i] = 1 : $obj->{IfMsgTo}->[$i] = 1;
            }

=pod
            if ( $obj->{msg_toid}->[$i] == $self->owid ) {
                $obj->{IfMsgFrom}->[$i] = 1;
            }

            if ( $obj->{msg_owid}->[$i] == $self->owid ) {
                $obj->{IfMsgTo}->[$i]   = 1;
            }
=cut
            # Modified 2010/12/09 END

            $obj->{msg_message}->[$i] = JKZ::Mobile::Emoji::hex2emoji($obj->{msg_message}->[$i]);
            $obj->{msg_message}->[$i] = MyClass::WebUtil::yenRyenN2br($obj->{msg_message}->[$i]);

            $obj->{msg_registration_date}->[$i] = substr($obj->{msg_registration_date}->[$i], 5, 11);
            $obj->{msg_registration_date}->[$i] =~ s!-!/!g;
            $obj->{LNEIGHBORULR}->[$i]          = $self->NEIGHBORURL();

            ( 0 == $i % 2 ) ? $obj->{IfOdd}->[$i] = 1 : $obj->{IfEven}->[$i] = 1;

        } 0..$obj->{LoopMyMessageList};

        if ($record_limit == $obj->{LoopMyMessageList}) {
            $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
            $obj->{IfNextData}   = 1;
        }
        if ($record_limit <= $offset) {
            $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
            $obj->{IfPreviousData}   = 1;
        }
    }
    else {
        $obj->{IfNotExistsMyMessageList} = 1;
    }

    return $obj;
}



#******************************************************
# @desc     掲示板
# @param    
# @param    
# @return   
#******************************************************
sub viewlist_message_board {
    my $self            = shift;
    my $q               = $self->query();
    my $offset          = $q->param('off') || 0;
    my $record_limit    = 20;
    #my $condition_limit = $record_limit+1;
    my $obj;

    my $msg = $self->message_of_messageboard({ owid => $self->owid, offset => $offset, record_limit => $record_limit });
    map { $obj->{$_} = $msg->{$_} } keys %{ $msg };

    return $obj;
}

#************************************************************************************************************
#   コンテンツ→賞品・商品関連
#************************************************************************************************************



#***********************
# 今月の全星座占いデータ
#***********************
=pod
sub getHoroscopeThisMonth {
    my $self = shift;
    # 占い処理部分
    my $thismonth = MyClass::WebUtil::GetTime("6");
    $thismonth =~ s!-!/!;

    # キャッシュデータがあればキャッシュを利用する
    my $memcached = MyClass::UsrWebDB::MemcacheInit();
    my $obj = $memcached->get("horoscope:$thismonth");
    if (!$obj) {
        use WebService::JugemKey::Horoscope;
        my $horoscope = WebService::JugemKey::Horoscope->new({
                  api_key => '',
                  secret  => '',
              });
        $obj = $horoscope->fetch();
        $memcached->add("horoscope:$thismonth", $obj, 1000);
    }

    $self->{horoscope} = $obj;
    return $self->{horoscope};
}


sub getHoroscopeToday {
    my $self = shift;

    #****************************************
    # Modified ニックネーム未登録者強制登録
    #****************************************
    if (!$self->attrAccessUserData("nickname")) {
        my $return_obj;
        $return_obj->{IfNickNameIsEmpty} = 1;
        return $return_obj;
    }

    $self->getHoroscopeThisMonth();

    my $myBirthday = sprintf("%s/%s/%s", $self->attrAccessUserData("year_of_birth"), $self->attrAccessUserData("month_of_birth"), $self->attrAccessUserData("date_of_birth"));
    #my $tmpobj     = $obj->get_today( { birthday => $myBirthday } );
    my $return_obj = $self->{horoscope}->get_today( { birthday => $myBirthday } );

    return ($return_obj);
}


sub horoscope_detail {
    my $self       = shift;
    my $tmpobj     = $self->getHoroscopeToday();
    my $return_obj = {};

    map {
        #my $pic = '<img src="/image/' . $_ . '.gif" />&nbsp;';
        my $pic = '<img src="/mod-perl/serveImageFS.mpl?f=' . $_ . '.gif" />&nbsp;';
        $return_obj->{$_} = ($tmpobj->{$_} =~ /[0-9]/ && 'rank' ne $_) ? $pic x $tmpobj->{$_} : MyClass::WebUtil::convertByNKF('-s', $tmpobj->{$_})
    } keys %{ $tmpobj };

    return $return_obj;
}
=cut

1;
__END__

