#******************************************************
# @desc      コミュニティ機能を提供するクラス
#            JKZ::JKZHPEditのサブクラス
#            このクラスは会員認証OK以外は呼び出しでloginformを
#            出力
#            検索→キーワード・カテゴリ
#            登録→誰でも・管理人認証
#            ■新規登録→コミュニティ名・カテゴリ・参加レベル・
#                トピック作成権限・トピック説明
#            ■トップ→メンバー数・管理人ニックネーム
#                                └プロフィールページ
#                カテゴリ名・コミュニティ説明・コミュニティ画像・
#                メンバー一覧(リスト表示)・
#            ■コミュニティ退会・友達に教える・お気に入り追加・トピック検索
#            ■新着トピック書き込み(リスト表示)・新着イベント書き込み(リスト表示)
#            
# @package   MyClass::JKZ::Community
# @access    public
# @author    Iwahase Ryo
# @create    2008/08/25
# @update     2008/11/25 modified to perlstyle
# @update    2008/12/17 runメソッドを親クラスから継承に変更
# @version    1.00
#******************************************************
package MyClass::JKZ::Community;

use strict;
use warnings;
no warnings 'redefine';
use 5.008005;
our $VERSION = '1.00';

use base qw(MyClass::JKZ::MemberContents);

use MyClass::WebUtil;
use MyClass::JKZDB::Member;
use MyClass::JKZDB::CommunityCategory;
use MyClass::JKZDB::Community;
use MyClass::JKZDB::CommunityMember;
use MyClass::JKZDB::CommunityTopic;
use MyClass::JKZDB::CommunityTopicComment;
use MyClass::JKZDB::CommunityAdmission;

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
# @desc        マイコミュニティー
# @return    
#******************************************************
sub viewlist_mycommunity {
    my $self = shift;
    my $q    = $self->query();
    my $owid = $self->owid;
    my $obj  = {};


    my $record_limit = 10;
    my $offset = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $sql = sprintf("SELECT c.community_id, c.community_name, c.community_total_member FROM %s.tCommunityM c, %s.tCommunityMemberM m
 WHERE m.community_id=c.community_id
 AND m.community_member_owid=?
 AND c.status_flag=2
 AND m.status_flag=2
 LIMIT %s, %s 
 ;
", $self->waf_name_space,  $self->waf_name_space, $offset, $condition_limit);

    my $dbh  = $self->getDBConnection();
    $self->setDBCharset('sjis');

    my $aryref = $dbh->selectall_arrayref($sql, undef, $owid);
    $obj->{LoopMyCommunityList} = ($record_limit == $#{$aryref}) ? $record_limit-1 : $#{$aryref};
    if (0 <= $obj->{LoopMyCommunityList}) {
        $obj->{IfExistsMyCommunityData} = 1;
        $obj->{rangeBegin}              = ( $offset+1 );
        $obj->{rangeEnd}                = ( $obj->{rangeBegin}+$obj->{LoopMyCommunityList} );

        for (my $i = 0; $i <= $obj->{LoopMyCommunityList}; $i++) {
            $obj->{community_id}->[$i]           = $aryref->[$i]->[0];
            #$obj->{community_name}->[$i]         = WebUtil::escapeTags($aryref->[$i]->[1]);
            $obj->{community_name}->[$i]         = JKZ::Mobile::Emoji::hex2emoji($aryref->[$i]->[1]);
            $obj->{community_total_member}->[$i] = $aryref->[$i]->[2];

            #$obj->{HPCommunityPARAMs}->[$i] = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
            #$obj->{HPCommunityPARAMs}->[$i] .= '&action=view_community&m=cm&id=' . $obj->{community_id}->[$i];

            (0 == $i % 2) ? $obj->{IfOdd}->[$i] = 1 : $obj->{IfEven}->[$i] = 1;

            $obj->{LCOMMUNITYURL}->[$i]          = $self->COMMUNITYURL;
        }

        if ($record_limit == $#{$aryref}) {
            $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
            $obj->{IfNextData}   = 1;
        }
        if ($record_limit <= $offset) {
            $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
            $obj->{IfPreviousData}   = 1;
        }
    }
    else {
        $obj->{IfNotExistsMyCommunityData} = 1;
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        コミュニティーの追加
# @return    
#******************************************************
sub add_community {
    my $self = shift;
    my $q    = $self->query();
    $q->autoEscape(0);
    my $owid = $self->owid;
    my $obj  = {};

    $obj->{user_guid}   = $self->user_guid;

    # 作成初期画面
    unless ( 0 < $q->param('f') ) {
        if ( $q->param('f') == -1 ) {
            $obj->{community_name}                   = MyClass::WebUtil::escapeTags($q->unescape($q->param('community_name')));
            $obj->{community_description}            = MyClass::WebUtil::escapeTags($q->unescape($q->param('community_description')));
            #$obj->{community_name}                   = $q->unescape($q->param('community_name'));
            #$obj->{community_description}            = $q->unescape($q->param('community_description'));
            $obj->{IfCommunityMemberFlagtSelected}   = 1 if 4 == $q->param('community_member_flag');
            $obj->{IfCommunityMemberFlagNotSelected} = 1 if 2 == $q->param('community_member_flag');
            $obj->{IfCommunityTopicFlagSelected}     = 1 if 4 == $q->param('community_topic_flag');
            $obj->{IfCommunityTopicFlagNotSelected}  = 1 if 2 == $q->param('community_topic_flag');
        }
        my $selected_value = $q->param('community_category_id');
        my $communitycategorylist = $self->fetchValuesFromConf("COMMUNITYCATEGORY", $selected_value);
        map { $obj->{$_} = $communitycategorylist->{$_}  } %{ $communitycategorylist };

        $obj->{IfConfirm} = 1;
    }
    if (!$obj->{IfConfirm}) {
        # 作成実行画面
        if ("" eq $q->param('community_name') || "" eq $q->param('community_description')) {
            #$obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $self->ERROR_MSG('ERR_MSG99'));
            $obj->{IfEmptyError} = 1;
        } else {
            $obj->{IfAddCommunity} = 1;
        }

        $obj->{community_name}                   = $q->escape($q->param('community_name'));
        $obj->{community_description}            = $q->escape($q->param('community_description'));
        $obj->{community_category_id}            = $q->param('community_category_id');
        $obj->{community_member_flag}            = $q->param('community_member_flag');
        $obj->{community_topic_flag}             = $q->param('community_topic_flag');
        ## プレビュー用
        $obj->{community_categoryDescription}    = $self->fetchOneValueFromConf( 'COMMUNITYCATEGORY', ($q->param('community_category_id')-1) );
        ## コミュニティ参加条件 設定値の対数
        $obj->{community_member_flagDescription} = $self->fetchOneValueFromConf( 'COMMUNITYMEMBERFLAG', ((log ($q->param('community_member_flag')) /log (2)) - 1)) ;
        ## コミュニティトピック権限 設定値の対数
        $obj->{community_topic_flagDescription}  = $self->fetchOneValueFromConf( 'COMMUNITYTOPICFLAG', ((log ($q->param('community_topic_flag')) /log (2)) - 1) );

        $obj->{community_categoryDescription}    = MyClass::WebUtil::convertByNKF('-s', $obj->{community_categoryDescription});
        $obj->{community_member_flagDescription} = MyClass::WebUtil::convertByNKF('-s', $obj->{community_member_flagDescription});
        $obj->{community_topic_flagDescription}  = MyClass::WebUtil::convertByNKF('-s', $obj->{community_topic_flagDescription});
        $obj->{preview_community_name}           = MyClass::WebUtil::escapeTags($q->param('community_name'));
        $obj->{preview_community_description}    = MyClass::WebUtil::escapeTags($q->param('community_description'));
        $obj->{preview_community_description}    =~ s!\r\n!<br />!g;

        $obj->{IfReConfirm} = 1;
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        コミュニティーの新規作成
#            コミュニティーマスターとコミュニティーメンバーマスター
#            の2つのテーブル使用
#            ｺﾐｭﾆﾃｨ名とコミュニティーの説明には絵文字の使用をOKとする。
#           絵文字の取り扱い：
#            データをDB格納前に
#            絵文字を10 進数表記に変換する（表示するとき16進数変換する）
#            絵文字を16進数変換 キャリア区別のために[docomo:xxxx] [softbank:xxxx] [kddi:xxxx]とかにする
# @return    
#******************************************************
sub create_community {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    ## 不正防止
    unless ( $q->MethPost() ) {
        ## 正常処理続行不可
        $obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $self->ERROR_MSG('ERR_MSG98'));
    } else {
        my $community_name        = $q->unescape($q->param('community_name'));
        my $community_category_id = $q->param('community_category_id');
        my $community_member_flag = $q->param('community_member_flag');
        my $community_topic_flag  = $q->param('community_member_flag');
        my $community_description = $q->unescape($q->param('community_description'));

        # これはこのサイトでは使用しない。値が無いとDBの構成変更が必要のためダミーデータを使用(ホームページサイトのホームページURLに使用するID)
        my $community_member_id = 'HogeHoge';

     #**************************************
     # 絵文字を16進数変換 キャリア区別のために[docomo:xxxx] [softbank:xxxx] [kddi:xxxx]とかにする
     #**************************************
        $community_name        = JKZ::Mobile::Emoji::emoji2hex($community_name);
        $community_description = JKZ::Mobile::Emoji::emoji2hex($community_description);

        #**************************************
        # コミュニティーマスターデータ
        #**************************************
        my $InsertData = {
            community_id             => -1,
            status_flag              => 2,
            community_name           => $community_name,
            community_category_id    => $community_category_id,
            community_description    => $community_description,
            community_member_flag    => $community_member_flag,
            community_topic_flag     => $community_topic_flag,
            community_admin_owid     => $self->user_owid,
            community_admin_nickname => $self->user_nickname,
            community_admin_id       => $community_member_id,
            community_total_member   => 1,
        };

        my $dbh = $self->getDBConnection;
        $self->setDBCharset("sjis");

        my $myCommunity = MyClass::JKZDB::Community->new($dbh);
        
        if (!$myCommunity->executeUpdate($InsertData)) {
            $obj->{ERROR_MSG}             = MyClass::WebUitl::convertByNKF('-s', $self->ERROR_MSG('ERR_MSG8'));
            $obj->{IfSubmitCommunityFail} = 1;
        } else {
            ## 今格納されたレコードのID
            $obj->{community_id} = $myCommunity->mysqlInsertIDSQL();

            #**************************************
            # コミュニティーメンバーマスターデータ
            #**************************************
            $InsertData = {};
            $InsertData = {
                community_id              => $obj->{community_id},
                community_member_owid     => $self->user_owid,
                community_member_nickname => $self->user_nickname,
                community_member_id       => $community_member_id,
                status_flag               => 2,
                community_admin_flag      => 2,
            };
            my $myCommunityMember = MyClass::JKZDB::CommunityMember->new($dbh);
            my $attr_ref          = MyClass::UsrWebDB::TransactInit($dbh);
            eval {
                $myCommunityMember->executeUpdate($InsertData, -1);
                $dbh->commit();
            };
            if ($@) {
                $dbh->rollback();
                ## エラー処理実行
                $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG8');
                $obj->{ERROR_MSG} .= "コミュニティーメンバーマスター：トランザクションロールバック<br />"; 
                $obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $obj->{ERROR_MSG});
                $obj->{IfSubmitCommunityFail} = 1;
            } else {
                ## 成功処理実行
                $obj->{IfSubmitCommunitySuccess} = 1;
            }
            MyClass::UsrWebDB::TransactFin($dbh,$attr_ref,$@);
        }
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        コミュニティー詳細情報および登録はこちらから
# @param    $int param=f 存在するときは詳細表示
#            無いときは通常のページ
# @return    
#******************************************************
sub view_community {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};
    my $id   = $q->param('cmid');

    ## 他のテーブルからもデータを取得したときにカラム名が同じだとNGので専用パラメータ置き換え文字を生成
#    $obj->{thisCommunityTopParam};
    

    ## ｺﾐｭﾆﾃｨデータをキャッシュから取得
    $obj = $self->_getCommunityInfo($id);
    $obj->{id} = $id;


    if (!$obj) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG14');
    } else {
        #map { $obj->{$_} = $obj->{$_} } keys %{ $obj };

        if (defined ($q->param('f'))) {
            $obj->{IfViewCommunityDetail} = 1;
        } else {
            $obj->{IfViewCommunity} = 1;

        #**********************************
        # 新着トピックの取得
        #**********************************

            my $topiclist = $self->_getTopicListByCommunityID( { community_id => $obj->{community_id}, limit=>3 } );

            map { $obj->{$_} = $topiclist->{$_} } keys %{ $topiclist };

            my $memberList = $self->getCommunityMemberList( $id, {limit=>3} );
$obj->{DUMP} = Dumper($memberList);
            #$obj->{LoopCommunityMemberList} = $memberList->{reccnt};
            $obj->{LoopCommunityMemberList} = $memberList->countRecSQL;
            if (0 <= $obj->{LoopCommunityMemberList}) {
                for (my $i = 0; $i <= $obj->{LoopCommunityMemberList}; $i++) {
                    no strict ('refs');
                    map { $obj->{$_}->[$i] = $memberList->{columns}->{$_}->[$i] } keys %{ $memberList->{columns} };
                    ## ﾌﾟﾛﾌのページURLを生成
                    $obj->{LNEIGHBORULR}->[$i]          = $self->NEIGHBORURL();
                }
            }
        }

       #******************************
       # 16進数をキャリアの絵文字に変換
       #******************************
        $obj->{community_name}                   = JKZ::Mobile::Emoji::hex2emoji($obj->{community_name});
        $obj->{community_description}            = JKZ::Mobile::Emoji::hex2emoji($obj->{community_description});

       #******************************
       # タグのエスケープ
       #******************************
        $obj->{community_name}                   = MyClass::WebUtil::escapeTags($obj->{community_name});
        $obj->{community_description}            = MyClass::WebUtil::escapeTags($obj->{community_description});

        $obj->{community_description}            = substr(MyClass::WebUtil::escapeTags($obj->{community_description}), 0, 100) if !$q->param('f');
       ## \r\nを<br />に変換
        $obj->{community_description}            = MyClass::WebUtil::yenRyenN2br($obj->{community_description});

        $obj->{registration_date}                = substr($obj->{registration_date}, 0, 16);
        $obj->{registration_date}                =~ s!-!/!g;

        $obj->{community_categoryDescription}    = $self->fetchOneValueFromConf('COMMUNITYCATEGORY', ($obj->{community_category_id}-1));
       ## コミュニティ参加条件
        $obj->{community_member_flagDescription} = $self->fetchOneValueFromConf('COMMUNITYMEMBERFLAG', ((log ($obj->{community_member_flag})/log (2)) - 1));
       ## コミュニティトピック権限
        $obj->{community_topic_flagDescription}  = $self->fetchOneValueFromConf('COMMUNITYTOPICFLAG', ((log ($obj->{community_topic_flag})/log (2)) - 1));

        $obj->{community_categoryDescription}    = MyClass::WebUtil::convertByNKF('-s', $obj->{community_categoryDescription});
        $obj->{community_member_flagDescription} = MyClass::WebUtil::convertByNKF('-s', $obj->{community_member_flagDescription});
        $obj->{community_topic_flagDescription}  = MyClass::WebUtil::convertByNKF('-s', $obj->{community_topic_flagDescription});


#        $obj->{registration_date}                =~ s!-!/!g;

        ## ｺﾐｭﾆﾃｨｰの画像の有無
        if ($obj->{community_image_id} == 0) {
            $obj->{IfImageDataNotExists} = 1;
        } else {
            $obj->{IfImageDataExists} = 1;
        }

        #**************************************
        # 参加会員かのチェック
        #**************************************
        !defined ($self->_checkCommunityMemberStatus($id)) ? $obj->{IfNotCommunityMember} = 1 : $obj->{IfCommunityMember} = 1;
        if ($obj->{IfNotCommunityMember}) {
            $obj->{IfYouAreNotAdmin} = 1;
            # コミュニティー登録URL
            $obj->{HPRegistCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ()
                                  . '&action=entrycommunity&m=cm&id=' . $id;
            # 承認制コミュニティー登録URL
            $obj->{HPRegistCommunityPARAM} .= '&mfl=1' if 4 == $obj->{community_member_flag};
            # 承認制コミュニティー
            $obj->{IfCommunityMemberFlag} = 1 if 4 == $obj->{community_member_flag};
            # 通常コミュニティー
            $obj->{IfNotCommunityMemberFlag} = 1 if 2 == $obj->{community_member_flag};
        }
        elsif ($obj->{IfCommunityMember}) { ## コミュニティーメンバーの場合
            ## 管理者と非管理者の判別
            if (int ($self->{owid}) == int ($obj->{community_admin_owid})) {
                $obj->{IfYouAreAdmin} = 1;
                ## 参加承認待ちリストの取得
                $obj->{IfNewCommunityAdmission} = 1 if $self->_checkCommunityAdmission ($id);
                $obj->{HPCommunityAdmissionURL} = (1 == $obj->{IfNewCommunityAdmission}) ? $obj->{HPCommunityPARAM} . '&action=admissionlist&m=cm&id=' . $id : "";
                ## トピック作成権限 管理者はどちらにしても作成できる
                $obj->{IfCreateNewTopic} = 1;
            }
            else {
                $obj->{IfYouAreNotAdmin} = 1;
                ## トピック作成権限の判定
                $obj->{IfCreateNewTopic} = (2 == $obj->{community_topic_flag}) ? 1 : 0;
            }
        }
        $obj->{IfExistsCommunityMemberData} = 1;
#        $obj->{HPCommunityTopURL} = $obj->{HPCommunityPARAM} . '&action=view_community&m=cm&id=' . $id;


    #*****************************
    # バナーを生成 コミュの引数は3
    #*****************************
    #my $Banner = $self->createBanner($dbh, 3);
    #map { $obj->{$_} = $Banner->{$_} } keys %{$Banner};

    }

=pod
    ## 画像表示スクリプト

    $obj->{_IMAGE_SCRIPT_URL} = $self->_IMAGE_SCRIPT_URL ();
    $obj->{COMMUNITY_ADMIN_PROFILE_URL} = $self->{HP_URL} . '/';
    $obj->{COMMUNITY_ADMIN_PROFILE_URL} .=  $obj->{community_admin_id}
                                        . '/?prof'
                                          . '&c=' . $self->_encryptParamC ()
                                          ;
=cut
#$obj->{DUMP} = Dumper($obj);
    return $obj;
}


#******************************************************
# @access    privateblic
# @desc        コミュニティーの属性を取得
# @return    $obj
# @param    int community_id
#******************************************************
sub _getCommunityInfo {
    my ($self, $id) = @_;

    return unless $id;

    my $namespace = $self->waf_name_space() . 'communityinfo';
    my $memcached = $self->initMemcachedFast();
    my $obj       = $memcached->get("$namespace:$id");

    if (!$obj) {
        ## 取得する情報
        my %condition = (
            columns       => [
                'community_id', 'community_name', 'community_category_id', 'community_description', 'community_image_id', 'community_member_flag',
                'community_topic_flag', 'community_admin_owid', 'community_admin_nickname', 'community_admin_id', 'community_total_member',
                'registration_date',
            ],
            whereSQL    => 'community_id=? AND status_flag=?',
            placeholder => ["$id", "2"],
        );

        my $dbh = $self->getDBConnection();
        $self->setDBCharset("sjis");
        my $myCommunity = MyClass::JKZDB::Community->new($dbh);
        $obj            = $myCommunity->getSpecificValuesSQL(\%condition);
        $memcached->add("$namespace:$id", $obj);

    }
    return $obj;
}


#******************************************************
# @access    private
# @desc        コミュニティー会員状態及び権限チェック
#            memcachedを利用120秒
# @param    $string
# @return    
#******************************************************
sub _checkCommunityMemberStatus {
    my ($self, $id) = @_;
    my $owid = $self->owid;
    ## cacheデータを区別するための値はowid＋;＋id(ｺﾐｭﾆﾃｨの)
    my $key = int ($owid) . ';' . $id;

    my $namespace = $self->waf_name_space() . 'communitymember';
    my $memcached = $self->initMemcachedFast();
    my $true      = $memcached->get("$namespace:$key");

    if (!$true) {

        my $myCommunityMember = MyClass::JKZDB::CommunityMember->new($self->getDBConnection);
        $self->setDBCharset("sjis");
        if (!$myCommunityMember->checkMemberStatus($key)) {
            $memcached->add("$namespace:$key", 0, 120);
            return;
        }
        $true = 1;
        $memcached->add("$namespace:$key", 1, 120);
    }

    return ($true ? 1 : 0);
}


#******************************************************
# @access    private
# @desc        コミュニティーのトピック取得
# @param    $obj database handle
# @param    $obj SQL Condition community_id order limit offset
# @return    
#******************************************************
sub _getTopicListByCommunityID {
    my ($self, $condition) = @_;
    my $obj;
    my $community_id    = exists ($condition->{community_id}) ? int ($condition->{community_id}) : return;
    my $record_limit    = exists ($condition->{limit}) ? int ($condition->{limit}) : 5 ;
    my $offset          = exists ($condition->{offset}) ? int ($condition->{offset}) : 0;
    my $condition_limit = $record_limit+1;

    my $sql             = sprintf("SELECT t.community_topic_id, t.community_id, t.community_topic_title,
 CASE DATE(t.lastupdate_date) WHEN CURDATE() THEN DATE_FORMAT(t.lastupdate_date,'%H:%i')
 ELSE DATE_FORMAT(t.lastupdate_date, '%m/%d') END AS lastupdate_date,
 COUNT(c.community_comment_id) AS CNT
 FROM %s.tCommunityTopicF t LEFT JOIN
 %s.tCommunityTopicCommentF c
 ON c.community_topic_id=t.community_topic_id AND c.community_id=t.community_id
 WHERE t.community_id=? AND t.status_flag=?
 GROUP BY t.community_topic_id
 ORDER BY lastupdate_date DESC
 LIMIT %s, %s
", $self->waf_name_space, $self->waf_name_space, $offset, $condition_limit);

    my $dbh    = $self->getDBConnection;
    $self->setDBCharset("sjis");
    my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $community_id, 2);
    $obj->{LoopCommunityTopicList} = ($record_limit == $#{ $aryref }) ? $record_limit-1 : $#{ $aryref };
    if (0 <= $#{ $aryref }) {
        $obj->{IfExistsCommunityTopic} = 1;
        for (my $i = 0; $i <= $#{ $aryref }; $i++) {
            map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };

            $obj->{LCOMMUNITYTOPICURL}->[$i] = sprintf("%s&a=view&o=communitytopic&cmid=%s&cmtpid=%s", $self->COMMUNITYURL, $obj->{community_id}->[$i], $obj->{community_topic_id}->[$i]);

            ( 0 == $i % 2 ) ? $obj->{IfOddTopic}->[$i] = 1 : $obj->{IfEvenTopic}->[$i] = 1;

        }
        $obj->{rangeBeginCT} = ($offset+1);
        $obj->{rangeEndCT}    = ($obj->{rangeBeginCT}+$obj->{LoopCommunityTopicList});
        if ($record_limit == $#{$aryref}) {
            $obj->{offsetTOnextCT} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
            $obj->{IfNextDataCT} = 1;
        }
        if ($record_limit <= $offset) {
            $obj->{offsetTOpreviousCT} = ($offset - $condition_limit + 1);
            $obj->{IfPreviousDataCT} = 1;
        }
    }
    else {
        $obj->{IfNotExistsCommunityTopic} = 1;
    }

    return $obj;
}


#******************************************************
# @access    private
# @desc        参加承諾待ちの取得
#******************************************************
sub _checkCommunityAdmission {
    my ($self, $community_id) = @_;

    my $namespace = $self->waf_name_space() . 'communityadmissionlist';
    my $memcached = $self->initMemcachedFast();
    my $true      = $memcached->get("$namespace:$community_id");

    if (!$true) {
        my $dbh = $self->getDBConnection();
        $self->setDBCharset("sjis");
        my $myCommunityAdmission = MyClass::JKZDB::CommunityAdmission->new($dbh);
        if (!$myCommunityAdmission->checkCommunityAdmissionList($community_id)) {
            $memcached->add("$namespace:$community_id", 0, 120);
            return;
        }
        $true = 1;
        $memcached->add("$namespace:$community_id", 1, 120);
    }
    return ($true ? 1 : 0);
}


#******************************************************
# @access    private
# @desc        コミュニティー会員リスト取得
# @param    $int community_id
# @return    
#******************************************************
sub getCommunityMemberList {
    my ($self, $community_id, $condition) = @_;

    my $record_limit    = exists ($condition->{limit})  ? int ($condition->{limit})  : 5;
    my $offset          = exists ($condition->{offset}) ? int ($condition->{offset}) : 0;
    my $condition_limit = $record_limit+1;
    my %condition       = (
        whereSQL    => 'community_id=? AND status_flag=?',
        orderbySQL  => 'registration_date DESC',
        limitSQL    => "$offset, $condition_limit",
        placeholder => ["$community_id", "2"],
    );

    my $dbh = $self->getDBConnection;
    $self->setDBCharset("sjis");
    my $CommunityMemberList = MyClass::JKZDB::CommunityMember->new($dbh);
    $CommunityMemberList->executeSelectList(\%condition);

    return $CommunityMemberList;
}


1;
__END__

#******************************************************
# @access    public
# @desc        コミュニティの閉鎖
# @return    
#******************************************************
sub close_community {
    my ($self, $dbh) = @_;
    my $q = $self->query();
    ## コミュニティーのid
    my $id = $q->param('community_id');
    my $obj = {};
    $obj->{c} = $self->_encryptParamC();
    $obj->{HPeditURL} = $self->{HPeditURL};
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC();

    my $myCommunity = MyClass::JKZDB::Community->new($dbh);
    if (!$myCommunity->executeUpdate({
        community_id    => $id,
        status_flag        => 4,
    })) {
            $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG8');
            $obj->{IfCloseCommunityFail} = 1;
    }
    else {
        $obj->{IfCloseCommunitySuccess} = 1;
    }

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        コミュニティー情報編集
#            情報編集後はキャッシュも更新
#
# @return    
#******************************************************
sub set_community {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    ## コミュニティーのid
    my $id = $q->param('id');
    my $obj = {};
    $obj->{id} = $id;
    $obj->{c} = $self->_encryptParamC ();
    $obj->{HPeditURL} = $self->{HPeditURL};
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();

    ## 画像表示スクリプト
    $obj->{_IMAGE_SCRIPT_URL} = $self->_IMAGE_SCRIPT_URL ();

    ## ｺﾐｭﾆﾃｨデータをキャッシュから取得
    my $obj = $self->_getCommunityInfo ($dbh, $id);

    if (0<$q->param('f')) {
        my $community_id = $q->param('community_id');
        my $community_topic_flag = $q->param('community_topic_flag');
        my $community_member_flag = $q->param('community_member_flag');
        my $community_description = $q->param('community_description');
        my $myCommunity = MyClass::JKZDB::Community->new ($dbh);
        if (!$myCommunity->executeUpdate ({
            community_id            => $community_id,
            community_topic_flag    => $community_topic_flag,
            community_member_flag    => $community_member_flag,
            community_description    => $community_description,
        })) {

            $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG14');
            $obj->{IfSetCommunitFail} = 1;
        }
        else {
            $obj->{IfSetCommunitSuccess} = 1;
            ## キャッシュデータを更新
            my $obj = $self->_getCommunityInfo ($dbh, $community_id);
            #map { $obj->{$_} = $obj->{$_} } keys %{$obj};

            my $memcached = MyClass::UsrWebDB::MemcacheInit();
            $memcached->replace ("communityinfo:$community_id", {
                        community_id            => $community_id,
                        community_name            => $obj->{community_name},
                        community_category_id    => $obj->{community_category_id},
                        community_description    => $community_description,
                        community_image_id        => $obj->{community_image_id},
                        community_member_flag    => $community_member_flag,
                        community_topic_flag    => $community_topic_flag,
                        community_admin_owid    => $obj->{community_admin_owid},
                        community_admin_nickname=> $obj->{community_admin_nickname},
                        community_admin_id        => $obj->{community_admin_id},
                        community_total_member    => $obj->{community_total_member},
                        registration_date        => $obj->{registration_date},
            });

        }
        $obj->{IfSubmitCommunitySuccess} =1;
        $obj->{HPCommunityTopURL} = $obj->{HPCommunityPARAM} . '&action=view_community&id=' . $community_id;
        $self->{action} = "submit_community";
    }
    else {
        $obj->{HPCommunityTopURL} = $obj->{HPCommunityPARAM} . '&action=view_community&id=' . $q->param('id');
        if (!$obj) {
            $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG14');
        } else {
            map { $obj->{$_} = $obj->{$_} } keys %{$obj};
            $obj->{community_description} = WebUtil::escapeTags ($obj->{community_description});
            $obj->{IfCommunityMemberFlagtSelected} = 1 if 4 == $obj->{community_member_flag};
            $obj->{IfCommunityMemberFlagNotSelected} = 1 if 2 == $obj->{community_member_flag};
            $obj->{IfCommunityTopicFlagSelected} =1 if 4 == $obj->{community_topic_flag};
            $obj->{IfCommunityTopicFlagNotSelected} = 1 if 2 == $obj->{community_topic_flag};

            if ($obj->{community_image_id} == 0) {
                $obj->{IfImageDataNotExists} = 1;
            }
            else {
                $obj->{IfImageDataExists} = 1;
            }
            $obj->{HPCommunityTopURL} = $obj->{HPCommunityPARAM} . '&action=view_community&m=cm&id=' . $id
        }
    }

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        画像を設定
# @return    
#******************************************************
sub set_community_ui {
    my ($self, $dbh) = @_;

    my $q = $self->getCgiQuery ();
    my $obj = {};
    $obj->{c} = $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $obj->{c};
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{HPCommunityTopURL} = $obj->{HPCommunityPARAM} . '&action=view_community&id=' . $q->param('community_id');

    my $community_id = $q->param('community_id');
    my $community_image_id = $q->param('community_image_id');
    my $myCommunity = MyClass::JKZDB::Community->new ($dbh);
    if (!$myCommunity->executeUpdate ({
        community_id        => $community_id,
        community_image_id    => $community_image_id,
        })) {
        $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG14');
        $obj->{IfSetCommunitImageFail} = 1;
    }
    else {
        $obj->{IfSetCommunitImageSuccess} = 1;
        ## キャッシュデータを更新
        my $obj = $self->_getCommunityInfo ($dbh, $community_id);
        my $memcached = MyClass::UsrWebDB::MemcacheInit();
        $memcached->replace ("communityinfo:$community_id", {
                        community_id            => $community_id,
                        community_name            => $obj->{community_name},
                        community_category_id    => $obj->{community_category_id},
                        community_description    => $obj->{community_description},
                        community_image_id        => $community_image_id,
                        community_member_flag    => $obj->{community_member_flag},
                        community_topic_flag    => $obj->{community_topic_flag},
                        community_admin_owid    => $obj->{community_admin_owid},
                        community_admin_nickname=> $obj->{community_admin_nickname},
                        community_admin_id        => $obj->{community_admin_id},
                        community_total_member    => $obj->{community_total_member},
                        registration_date        => $obj->{registration_date},
            });
    }

    $self->_processHtml ($obj);
}





#******************************************************
# @access    public
# @desc        コメントの削除
# @return    
#******************************************************
sub delete_comment {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};
    my $community_id = $q->param('id');
    my $community_topic_id = $q->param('topic_id');
    my $community_comment_id = $q->param('community_comment_id');

    my $sql = " DELETE FROM tCommunityTopicCommentF WHERE"
            . " community_id=? AND community_topic_id=? AND community_comment_id=?"
            ;
    my $rv = $dbh->do ($sql, undef, $community_id, $community_topic_id, $community_comment_id);
    if ('0E0' eq $rv) {
        $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG16');
    }
    else { $obj->{IfDeleteCommentSuccess} = 1; }

    ## 他のテーブルからもデータを取得したときにカラム名が同じだとNGので専用パラメータ置き換え文字を生成
    $obj->{thisCommunityTopParam} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC (). '&id=' . $community_id;
    $obj->{thisTopicParam} = 'id=' . $q->param('id') . '&topic_id=' . $community_topic_id;

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        トピックの閲覧
# @return    
#******************************************************
sub view_topic {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};
    my $community_id = $q->param('id');
    my $community_topic_id = $q->param('topic_id');
    $obj->{topic_id} = $community_topic_id;

    ## 他のテーブルからもデータを取得したときにカラム名が同じだとNGので専用パラメータ置き換え文字を生成
    $obj->{thisCommunityTopParam} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC (). '&id=' . $q->param('id');
    $obj->{thisTopicParam} = 'id=' . $q->param('id') . '&topic_id=' . $q->param('topic_id');

    ## topicコメントのオフセット
    my $record_limit = 5;
    my $offset = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my %condition = (
        ## Modified 条件にstatus_flagを追加 2008/11/27
        wherestr    => 'community_id=? AND community_topic_id=? AND status_flag=?',
        placeholder => ["$community_id", "$community_topic_id", 2],
    );

    ## Modified 2008/10/09
    $obj->{IfOffsetisZero} = 1 if $offset==0;

    ## Modified 管理者がコメントを削除できるように修正 2008/10/09 BEGIN
    my $obj = $self->_getCommunityInfo ($dbh, $community_id);
    if (int ($self->{owid}) == int ($obj->{community_admin_owid})) {
        $obj->{IfYourAreAdmin} = 1;
    } else {
        $obj->{IfYourAreNotAdmin} = 1;
    }
    ## Modified 管理者がコメントを削除できるように修正 2008/10/09 END

    ## 複数ページが存在するときには都度トピックを取得しない
    if(1 > $offset) {
        my $CommunityTopic = MyClass::JKZDB::CommunityTopic->new ($dbh);

        if (!$CommunityTopic->executeSelect (\%condition)) {
            $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG14');
        } else {
            map { $obj->{$_} = $CommunityTopic->{columns}->{$_} } keys %{$CommunityTopic->{columns}};
            $obj->{community_topic_title} = WebUtil::escapeTags ($obj->{community_topic_title});
            $obj->{community_topic} = WebUtil::escapeHeaderTags ($obj->{community_topic});
            $obj->{community_topic} = WebUtil::yenRyenN2br ($obj->{community_topic});
            ## 日付を整える
            $obj->{registration_date}=~ s!-!/!g;
            $obj->{registration_date} = substr ($obj->{registration_date}, 0, 16);
        }
    }
    #/////////////////////////////
    # コメント取得
    #/////////////////////////////
    my $CommentList = $self->_fetchTopicCommentListBy ($dbh, $community_id, $community_topic_id, $offset, $condition_limit);
    $obj->{LoopCommentList} = ($record_limit == $CommentList->{reccnt}) ? $record_limit-1 : $CommentList->{reccnt};
    if (0 <= $obj->{LoopCommentList}) {
        for (my $i = 0; $i <= $obj->{LoopCommentList}; $i++) {
            no strict ('refs');
            map { $obj->{$_}->[$i] = $CommentList->{columns}->{$_}->[($obj->{LoopCommentList} - $i)] } keys %{$CommentList->{columns}};
            $obj->{community_comment_id}->[$i] = sprintf ("%03d", $obj->{community_comment_id}->[$i]);
            $obj->{community_comment}->[$i] = WebUtil::escapeTags ($obj->{community_comment}->[$i]);
            $obj->{community_comment}->[$i] = WebUtil::yenRyenN2br ($obj->{community_comment}->[$i]);
            $obj->{registration_date}->[$i] =~ s!-!/!g;
            $obj->{registration_date}->[$i] = substr ($obj->{registration_date}->[$i], 0 ,16);
            ## ﾌﾟﾛﾌのページURLを生成
            $obj->{Profile}->[$i] = $self->{HP_URL} . '/' . $obj->{commentater_id}->[$i] . '/?prof&c=' . $self->_encryptParamC ();
            ## Modified コメント削除パラメータ 2008/10/09
            $obj->{HPCommunitythisTopicCommentParam}->[$i] = $self->{HPeditURL} . '?mod=Community&c='
                                                            . $self->_encryptParamC ()
                                                            . '&action=delete_comment&id='
                                                            . $obj->{community_id}->[$i]
                                                            . '&topic_id='
                                                            . $obj->{community_topic_id}->[$i]
                                                            . '&community_comment_id='
                                                            . $obj->{community_comment_id}->[$i]
                                                            ;
        }
        $obj->{IfCommentExists} = 1;
        $obj->{CommentBegin} = $offset+1;
        $obj->{CommentEnd} = $record_limit > $CommentList->{reccnt} ? ($offset + ($CommentList->{reccnt} + 1)) : ($offset + $CommentList->{reccnt});
        #/////////////////////////////
        # 次ページと前ページ処理
        #/////////////////////////////
        if ($record_limit == $CommentList->{reccnt}) {
            $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
            $obj->{IfNextComment} = 1;
        }
        if ($record_limit <= $offset) {
            $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
            $obj->{IfPreviousComment} = 1;
        }

        ## 全コメント数を取得
        my $TopicComment = MyClass::JKZDB::CommunityTopicComment->new ($dbh);
        $obj->{CNT} = $TopicComment->getCount (\%condition);

    } else {
        $obj->{IfCommentNotExists} = 1;
    }

    ## コミュニティー会員かのステータスチェック
    $obj->{IfCommunityMember} = defined ($self->_checkCommunityMemberStatus ($dbh, $community_id)) ? 1 : 0;

    $obj->{c} = $self->_encryptParamC ();
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();
    $obj->{HP_URL} = $self->{HP_URL} . '/';

    #*****************************
    # バナーを生成 コミュの引数は3
    #*****************************
    my $Banner = $self->createBanner($dbh, 3);
    map { $obj->{$_} = $Banner->{$_} } keys %{$Banner};

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        トピックのリスト
# @return    
#******************************************************
sub view_topiclist {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};

    ## topicコメントのオフセット
    my $record_limit = 10;
    my $offset = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $topiclist;
    ## コミュニティー経由でコミュニティーのトピック一覧の場合
    if (defined ($q->param('id'))) {
        my $community_id = $q->param('id');
        ## 他のテーブルからもデータを取得したときにカラム名が同じだとNGので専用パラメータ置き換え文字を生成
        $obj->{thisCommunityTopParam} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC (). '&id=' . $q->param('id');
        $obj->{thisTopicParam} = 'id=' . $q->param('id') . '&topic_id=' . $q->param('topic_id');
        $topiclist = $self->_getTopicListByCommunityID ($dbh, {community_id=>$community_id, offset=>$offset, limit=>$record_limit});
    }
    else { ## 自分の管理ページ経由で参加してるコミュニティー一覧の場合
        $topiclist = $self->getTopicListByMemberID ($dbh, {limit=>5});
    }

    map { $obj->{$_} = $topiclist->{$_} } keys %{$topiclist};

    $obj->{c} = $self->_encryptParamC ();
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();
    $obj->{HP_URL} = $self->{HP_URL} . '/';

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        参加コミュニティーのトピック一覧
# @return    
#******************************************************
sub view_mytopiclist {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();

    my $obj = {};
    ## topicコメントのオフセット
    my $record_limit = 10;
    my $offset = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $mytopiclist = $self->getTopicListByMemberID ($dbh, {offset=>$offset, limit=>$record_limit});
    map { $obj->{$_} = $mytopiclist->{$_} } keys %{$mytopiclist};

    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();

    $self->_processHtml ($obj);
}

#******************************************************
# @access    public
# @desc        トピックの作成作成フォーム
# @return    
#******************************************************
sub topic_form {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};

    # 作成初期画面
    unless (0<$q->param('f')) {
        if ($q->param('f')==-1) {
            $obj->{community_topic_title} = WebUtil::escapeTags ($q->unescape($q->param('community_topic_title')));
            $obj->{community_topic} = WebUtil::escapeTags ($q->unescape($q->param('community_topic')));
        }
        $obj->{IfConfirm} = 1;
    }
    if (!$obj->{IfConfirm}) {
        # 確認画面
        if ("" eq $q->param('community_topic_title') || "" eq $q->param('community_topic')) {
            $obj->{ERROR_MSG} =$self->_ERROR_MSG ('ERR_MSG99');
            $obj->{IfEmptyError} = 1;
        } else {
            $obj->{IfSubmitTopic} = 1;
        }

        $obj->{community_topic_title} = $q->escape($q->param('community_topic_title'));
        $obj->{community_topic} = $q->escape($q->param('community_topic'));
        ## プレビュー用
        $obj->{preview_community_topic_title}= WebUtil::escapeTags ($q->param('community_topic_title'));
        $obj->{preview_community_topic} = WebUtil::escapeTags ($q->param('community_topic'));
        $obj->{preview_community_topic} = WebUtil::yenRyenN2br ($obj->{preview_community_topic});
        $obj->{IfReConfirm} = 1;
    }
    $obj->{community_id} = $q->param('id');
    $obj->{c} = $self->_encryptParamC ();
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();
    $obj->{HPeditURL} = $self->{HPeditURL};

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        トピックのコメント作成フォーム
# @return    
#******************************************************
sub topiccomment_form {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};
    $obj->{community_id} = $q->param('id');
    $obj->{community_topic_id} = $q->param('topic_id');

    # 作成初期画面
    unless (0<$q->param('f')) {
        if ($q->param('f') == -1) {
            $obj->{community_comment} = WebUtil::escapeTags ($q->unescape($q->param('community_comment')));
        }
        $obj->{IfConfirm} = 1;
    }
    if (!$obj->{IfConfirm}) {
        # 確認画面
        if ("" eq $q->param('community_comment')) {
            $obj->{ERROR_MSG} =$self->_ERROR_MSG ('ERR_MSG99');
            $obj->{IfEmptyError} = 1;
        } else {
            $obj->{IfSubmitComment} = 1;
        }
        $obj->{community_comment} = $q->escape($q->param('community_comment'));
        ## プレビュー用
        $obj->{preview_community_comment} = WebUtil::escapeTags ($q->param('community_comment'));
        $obj->{preview_community_comment} = WebUtil::yenRyenN2br ($obj->{preview_community_comment});
        $obj->{IfReConfirm} = 1;
    }
    $obj->{c} = $self->_encryptParamC ();
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();
    $obj->{HPeditURL} = $self->{HPeditURL};

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        トピックの作成
# @return    
#******************************************************
sub submit_topic {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};

    ## 不正防止
    unless ( $q->MethPost()) {
        ## 正常処理続行不可
        $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG98');
    } else {
        my $community_topic_title = $q->unescape ($q->param('community_topic_title'));
        my $community_topic = $q->unescape ($q->param('community_topic'));
        my $community_id = $q->param('id');

        my $InsertData = {
            community_topic_id        => -1,
            community_id            => $community_id,
            community_topic_title    => $community_topic_title,
            community_topic            => $community_topic,
            community_topicowner_owid     => $self->attrMember ("owid"),
            community_topicowner_nickname=> $self->attrMember ("nickname"),
            community_topicowner_id         => $self->attrMember ("id"),
        };

        my $myTopic = MyClass::JKZDB::CommunityTopic->new ($dbh);
        if (!$myTopic->executeUpdate ($InsertData)) {
            $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG8');
            $obj->{IfSubmitTopicFail} = 1;
        } else {
            ## 成功処理実行
            $obj->{IfSubmitTopicSuccess} = 1;
        }
    }
    $obj->{community_id} = $q->param('id');
    $obj->{c} = $self->_encryptParamC ();
    $obj->{HPeditURL} = $self->{HPeditURL};
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        コメントの作成
# @return    
#******************************************************
sub submit_comment {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};

    ## 不正防止
    unless ( $q->MethPost()) {
        ## 正常処理続行不可
        $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG5');
        $obj->{IfSubmitCommentFail} = 1;
    }
    elsif (!defined ($q->param('id')) || !defined ($q->param('topic_id'))) {
        $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG7');
        $obj->{IfSubmitCommentFail} = 1;
    } else {
        my $community_comment = $q->unescape ($q->param('community_comment'));

    #### 2009/01/28 端末ごとにデコード処理を追加中 試験中
#            use JKZ::JKZMobile;
#            my $mobile = JKZ::JKZMobile->new();
#            $mobile->decodeText($community_comment);
#            $mobile->encode2sjis($community_comment);
#use EscapeSJIS;
#EscapeSJIS::escape(\$community_comment);
    #### 2009/01/28 端末ごとにデコード処理を追加中 試験中


        my $community_id = $q->param('id');
        my $community_topic_id = $q->param('topic_id');

        my $InsertData = {
            community_comment_id=> -1,
            community_id        => $community_id,
            community_topic_id    => $community_topic_id,
            community_comment    => $community_comment,
            commentater_owid    => $self->attrMember ("owid"),
            commentater_nickname=> $self->attrMember ("nickname"),
            commentater_id        => $self->attrMember ("id"),
        };

        my $myComment = MyClass::JKZDB::CommunityTopicComment->new ($dbh);
        if (!$myComment->executeUpdate ($InsertData)) {
            $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG8');
            $obj->{IfSubmitTopicFail} = 1;
        } else {
            ## 成功処理実行
            $obj->{IfSubmitCommentSuccess} = 1;
        }
    }
    $obj->{community_id} = $q->param('id');
    $obj->{community_topic_id} = $q->param('topic_id');
    $obj->{c} = $self->_encryptParamC ();
    $obj->{HPeditURL} = $self->{HPeditURL};
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        コミュニティー会員登録
# @param    $string
# @return    
#******************************************************
sub entrycommunity {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $community_id = $q->param('id') || undef;
    my $obj = {};

    ## 登録画面
    unless (0 < $q->param('f')) {
        $obj->{HPeditURL}     = $self->{HPeditURL};
        $obj->{community_id}= $q->param('id');
        $obj->{c} = $self->_encryptParamC ();
        $obj->{IfEntryForm} = 1;
        $obj->{IfCommunityMemberFlag} = 1 if defined ($q->param('mfl'));
    }
    else { # 登録実行
        ## 不正防止
        unless ( $q->MethPost()) {
            ## 正常処理続行不可
            $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG98');
        } else {
            ## トランザクション開始
            my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);
            ## 承認が必要の場合
            if (defined ($q->param('mfl')) && 1 == $q->param('mfl')) {
                ## 挿入データ
                my $insertData = {
                    community_id => $community_id,
                    owid         => $self->attrMember ("owid"),
                    nickname     => $self->attrMember ("nickname"),
                    id             => $self->attrMember ("id"),
                };
                my $CommunityAdmission = MyClass::JKZDB::CommunityAdmission->new ($dbh);
                eval {
                    $CommunityAdmission->executeUpdate ($insertData, -1);
                    $dbh->commit ();
                };
            }
            elsif (!defined ($q->param('mfl'))) {
                ## 挿入データ
                my $insertData = {
                    community_id => $community_id,
                    community_member_owid     => $self->attrMember ("owid"),
                    community_member_nickname=> $self->attrMember ("nickname"),
                    community_member_id         => $self->attrMember ("id"),
                    status_flag => 2,
                };
                my $CommunityMember = MyClass::JKZDB::CommunityMember->new ($dbh);
                ## トランザクション開始
                my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);
                eval {
                    $CommunityMember->executeUpdate ($insertData, -1);
                    ## コミュニティーマスターの総会員数を更新
                    $dbh->do ("UPDATE tCommunityM SET community_total_member = (community_total_member+1) WHERE community_id=?",
                        undef, $community_id);

                    $dbh->commit ();
                };
            }
            ## 失敗のロールバック
            if ($@) {
                $dbh->rollback ();
                $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG8');
                $obj->{IfInsertDataFail} = 1;
            } else {
                $obj->{IfInsertDataOK} = 1;
            }

            MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
        }
    }
    $obj->{community_id} = $community_id;
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        コミュニティー退会
# @param    $string
# @return    
#******************************************************
sub withdraw_community {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $community_id = $q->param('id') || undef;
    my $obj = {};

    ## 登録画面
    unless (0 < $q->param('f')) {
        $obj->{HPeditURL} = $self->{HPeditURL};
        $obj->{community_id}= $q->param('id');
        $obj->{c} = $self->_encryptParamC ();
        $obj->{IfWithdrawForm} = 1;
    }
    else { # 登録実行
        ## 不正防止
        unless ( $q->MethPost()) {
            ## 正常処理続行不可
            $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG98');
        } else {
            ## トランザクション開始
            my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);
            eval {
                #$CommunityMember->executeUpdate ($updateData);
                $dbh->do ("DELETE FROM tCommunityMemberM WHERE community_id=? AND community_member_owid=? AND status_flag=2", undef, $community_id, $self->attrMember ("owid"));
                $dbh->do ("DELETE FROM tCommunityAdmissionF WHERE community_id=? AND owid=? AND status_flag=2", undef, $community_id, $self->attrMember ("owid"));
                ## コミュニティーマスターの総会員数を更新
                $dbh->do ("UPDATE tCommunityM SET community_total_member = (community_total_member-1) WHERE community_id=?",
                    undef, $community_id);
                    $dbh->commit ();
            };

            ## 失敗のロールバック
            if ($@) {
                $dbh->rollback ();
                $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG8');
                $obj->{IfUpdateDataFail} = 1;
            } else {
                $obj->{IfUpdateDataOK} = 1;
            }
            MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
        }
    }
    $obj->{community_id} = $community_id;
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        コミュニティー検索
#            パラメータ・name_onlyが無ければコミュニティー説明文の全文検索を実行する
# @param    $int パラメータ o はorder by
#             値は１==total_member もしくは２==registration_date
# @param    $string
# @return    
#******************************************************
sub search_community {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};
    ## カテゴリリストをDBから取得して
    my $communitycategorylist = $self->getCommunityCategoryList ($dbh, $q->param('community_category_id'));

    map { $obj->{$_} = $communitycategorylist->{$_} } %{$communitycategorylist};
    unless (defined ($q->param('f'))) {
        #/////////////////////////////
        # 1ページの表示件数の処理
        #/////////////////////////////
        my $record_limit = 20;
        my $offset = $q->param('off') || 0;
        my $condition_limit = $record_limit+1;

        ## 検索結果ソート順
        my @orderby = ('community_total_member', 'registration_date');
        ## 変な値を設定できなくする
        my $ordervalue = (1 == $q->param('o') || 2 == $q->param('o')) ? $q->param('o') : "1";
        #///////////////////////////////////
        # 検索条件生成
        #///////////////////////////////////
        my $sql = "SELECT community_id, community_name, community_description, community_category_id, community_total_member";
        $sql .= " FROM HP_general.tCommunityM";
        my (@placeholder, @condition_sql);

        if ($q->param('search_word') && "" ne $q->param('search_word')) {
            my $keytype = $q->param('name_only') || "0";
            ## マルチセクションの実装
            my @multisec = ('*W1,2 ', '*W1 ',);
            ## 検索文字のクエリ
            my $search_word = $multisec[$keytype] . $q->param('search_word');
            push (@condition_sql,"MATCH(community_name, community_description) AGAINST(? IN BOOLEAN MODE)");
            push (@placeholder, $search_word);

            $obj->{search_word} = $q->param('search_word');
        }
        if (99 > $q->param('community_category_id')) {
            push (@condition_sql, "community_category_id=?");
            push (@placeholder, $q->param('community_category_id'));
        }
        # Modfied 2008/10/23
        #$sql = $sql . ' WHERE' if 0 < @condition_sql;
        $sql = $sql . ' WHERE status_flag=2';
        $sql = $sql . ' AND' if 0 < @condition_sql;
        $sql .= sprintf (' %s', join (' AND ', @condition_sql));
        $sql .= " ORDER BY " . $orderby[($ordervalue-1)] . ' DESC';
        $sql .= " LIMIT " . $offset . ', ' . $condition_limit;

        ## Modified 2ind機能の有効化 2008/10/27
        $dbh->do('SET SESSION senna_2ind=ON;');

        my $aryref = $dbh->selectall_arrayref ($sql, { Columns => {} }, @placeholder);

        $obj->{LoopCommunityList} = ($record_limit == $#{$aryref}) ? $record_limit-1 : $#{$aryref};
        if (0 <= $obj->{LoopCommunityList}) {
            $obj->{IfExistsCommunityDataList} = 1;
            $obj->{rangeBegin} = ($offset+1);
            $obj->{rangeEnd}    = ($obj->{rangeBegin}+$obj->{LoopCommunityList});
            for (my $i = 0; $i <= $obj->{LoopCommunityList}; $i++) {
                $obj->{community_id}->[$i] = $aryref->[$i]->{community_id};
                $obj->{community_name}->[$i] = WebUtil::escapeTags ($aryref->[$i]->{community_name});
                $obj->{community_description}->[$i] = substr (WebUtil::escapeTags ($aryref->[$i]->{community_description}), 0, 100);
                $obj->{community_category_id}->[$i] = $aryref->[$i]->{community_category_id};
                $obj->{community_categoryDescription}->[$i] = $self->_getOneValueFromConf ('COMMUNITYCATEGORY', ($obj->{community_category_id}->[$i]-1));
                $obj->{community_total_member}->[$i] = $aryref->[$i]->{community_total_member};
                ## コミュニティー詳細へのリンクパラメータ
                $obj->{HPCommunityPARAM}->[$i] = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
                $obj->{HPCommunityPARAM}->[$i] .= '&action=view_community&m=cm&id=' . $aryref->[$i]->{community_id};
            }
            #/////////////////////////////
            # 次ページ（まだデータがある場合）
            #/////////////////////////////
            if ($record_limit == $#{$aryref}) {
                $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
                $obj->{IfNextData} = 1;
            }
            if ($record_limit <= $offset) {
                $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
                $obj->{IfPreviousData} = 1;
            }
        }
        else {
            $obj->{IfNotExistsCommunityDataList} = 1;
        }
    }
    $obj->{c} = $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        コミュニティーのトピック検索
# @param    $string
# @return    
#******************************************************
sub search_topic {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $obj = {};

    my $record_limit = 10;
    my $offset = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    if (!$q->param('search_word')) {
        $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG99');
    } else {
        my $sql = "SELECT * FROM HP_general.tCommunityTopicF WHERE community_id=?
 AND MATCH(community_topic_title, community_topic) AGAINST(? IN BOOLEAN MODE)
;";

        my $search_word = '*W1,2 ' . $q->param('search_word');
        my $aryref = $dbh->selectall_arrayref ($sql, { Columns => {} }, $q->param('id'), $search_word);

        $obj->{LoopTopicList} = ($record_limit == $#{$aryref}) ? $record_limit-1 : $#{$aryref};
        if (0 <= $obj->{LoopTopicList}) {
            $obj->{IfExistsTopicList} = 1;
            $obj->{rangeBegin} = ($offset+1);
            $obj->{rangeEnd}    = ($obj->{rangeBegin}+$obj->{LoopTopicList});
            for (my $i = 0; $i <= $obj->{LoopTopicList}; $i++) {
                $obj->{community_topic_id}->[$i] = $aryref->[$i]->{community_topic_id}; 
                $obj->{community_id}->[$i] = $aryref->[$i]->{community_id};
                $obj->{community_topic_title}->[$i] = WebUtil::escapeTags ($aryref->[$i]->{community_topic_title});
                ## トピックへのリンクパラメータ
                $obj->{HPCommunityTopicPARAM}->[$i] = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
                $obj->{HPCommunityTopicPARAM}->[$i] .= '&action=view_topic&m=cm&id=' . $aryref->[$i]->{community_id} . '&topic_id=' . $aryref->[$i]->{community_topic_id};
            }
            #/////////////////////////////
            # 次ページ（まだデータがある場合）
            #/////////////////////////////
            if ($record_limit == $#{$aryref}) {
                $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
                $obj->{IfNextData} = 1;
            }
            if ($record_limit <= $offset) {
                $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
                $obj->{IfPreviousData} = 1;
            }
        }
        else {
            $obj->{IfNotTopicList} = 1;
        }
    }
    $obj->{c} = $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        コミュニティー承認待ちリスト
# @param    $string
# @return    
#******************************************************
sub admissionlist {
    my ($self, $dbh) = @_;
    my $q = $self->getCgiQuery ();
    my $community_id = $q->param('id') || undef;
    my $obj = {};

    $obj->{community_id} = $community_id;
    #/////////////////////////////
    # 1ページの表示件数の処理
    #/////////////////////////////
    my $record_limit = 10;
    my $offset = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    if ("reject" eq $q->param('mode')) {
        $obj->{IfRejectMode} = 1;
    } else {
        $obj->{IfAdmitMode} =1;
    }

    my %condition = (
        columns        => ['owid', 'nickname', 'id', 'apply_date',],
        wherestr    => 'community_id=? AND status_flag IS NULL',
        orderbystr    => 'apply_date DESC',
        limitstr    => "$offset, $condition_limit",
        placeholder => ["$community_id"],
    );
    my $CommunityAdmissionList = MyClass::JKZDB::CommunityAdmissionList->new ($dbh);
    my $aryref = $CommunityAdmissionList->getSpecificValues (\%condition);

    $obj->{LoopAdmissionList} = ($record_limit == $#{$aryref->{owid}}) ? $record_limit-1 : $#{$aryref->{owid}};
    if ( 0 <= $obj->{LoopAdmissionList}) {
        $obj->{rangeBegin} = ($offset+1);
        $obj->{rangeEnd}    = ($obj->{rangeBegin}+$obj->{LoopAdmissionList});

        my $yyyymmdd_now = WebUtil::GetTime ("1");

        for (my $i = 0; $i <= $obj->{LoopAdmissionList}; $i++) {WebUtil::warnMSG_LINE($aryref, __LINE__);
            map { $obj->{$_}->[$i] = $aryref->{$_}->[$i] } qw(owid nickname id apply_date);

            $obj->{apply_date}->[$i] = $obj->{apply_date}->[$i] =~ /$yyyymmdd_now/ ? substr($obj->{apply_date}->[$i], 5, 11) : substr($obj->{apply_date}->[$i], 5, 5);
            $obj->{apply_date}->[$i] =~ s!-!/!; 
            ## コミュニティー参加希望ユーザーのプロフURL
            $obj->{USER_PROFILE_URL}->[$i] = $self->{HP_URL} . '/' . $obj->{id}->[$i] . '/?prof' . '&c=' . $self->_encryptParamC ();
        }
        $obj->{IfExistsAdmissionData} = 1;
    }
    #/////////////////////////////
    # 次ページ（まだデータがある場合）
    #/////////////////////////////
    if ($record_limit == $#{$aryref->{owid}}) {
        $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
        $obj->{IfNextData} = 1;
    }
    if ($record_limit <= $offset) {
        $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
        $obj->{IfPreviousData} = 1;
    }
    else {
        $obj->{IfNotExistsCommunityDataList} = 1;
    }
    ## 参加承認待ちが０の場合の処理
    $obj->{IfNotExistsAdmissionData} = 1 if 0 > $obj->{LoopAdmissionList};
    $obj->{c} = $self->_encryptParamC ();
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{HPeditURL} = $self->{HPeditURL};
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $self->_encryptParamC ();

    $self->_processHtml ($obj);
}


#******************************************************
# @access    public
# @desc        コミュニティー承認待ちの承認・拒否
# @param    $string
# @return    
#******************************************************
sub admitmember {
    my ($self, $dbh) = @_;

    my $q = $self->getCgiQuery ();
    my $community_id = int ($q->param('id')) || undef;
    my $obj = {};
    $obj->{c} = $self->_encryptParamC ();

    my @owid_array = (1 == $q->param('mode') && defined ($q->param('rejection_owid'))) ? $q->param('rejection_owid') : $q->param('admission_owid');
    my $status_flag = (1 == $q->param('mode')) ? "0" : "2";

    unless ( $q->MethPost() || !defined $community_id) {
        ## 正常処理続行不可
        $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG98');
    } else {
        if (0 < @owid_array) {
            my $sqlUpdate = sprintf ("UPDATE HP_general.tCommunityAdmissionF SET status_flag=?, admission_date=NOW() WHERE community_id=? AND owid IN(%s)", join (",", @owid_array));
            ## 承認OKの場合はtCommunityMemberMにデータを挿入
            my $sqlInsert = sprintf ("INSERT INTO tCommunityMemberM (community_id, community_member_owid, community_member_nickname, community_member_id, status_flag, registration_date) SELECT community_id, owid, nickname, id, status_flag, admission_date FROM tCommunityAdmissionF WHERE owid IN(%s) AND community_id=?;", join (",", @owid_array));
            ## コミュニティーマスターの総参加者数をインクリメント
            my $sqlUpdateTotal = "UPDATE tCommunityM SET community_total_member = (community_total_member+1) WHERE community_id=?";
            ## トランザクション開始
            my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);
            eval {
                ## 承認データ更新
                $dbh->do ($sqlUpdate, undef, $status_flag, $community_id);
                ## コミュニティー会員データ挿入
                $dbh->do ($sqlInsert, undef, $community_id) if 2 == $status_flag;
                ## コミュニティーマスターの総会員数を更新
                $dbh->do ($sqlUpdateTotal, undef, $community_id) if 2 == $status_flag;
                $dbh->commit ();
            };
            ## 失敗のロールバック
            if ($@) {
                $dbh->rollback ();
                $obj->{ERROR_MSG} = $self->_ERROR_MSG ('ERR_MSG8');
            } else {
                $obj->{IfUpdateSuccess} = 1;
                $obj->{NumberDone} = @owid_array;
            }
            MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
        }
    }
    $obj->{thisCommunityTopParam} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC (). '&id=' . $q->param('id');
    $obj->{id} = $community_id;
    $obj->{HPCommunityPARAM} = $self->{HPeditURL} . '?mod=Community&c=' . $self->_encryptParamC ();
    $obj->{MEMBER_PARAM} = $self->{HPeditURL} . '?c=' . $obj->{c};

    $self->_processHtml ($obj);
}





#******************************************************
# @access    private
# @desc        トピックのｺﾒﾝﾄの取得
# @param    $object  データベースハンドル
# @param    $integer トピックのid
# @return    list
#******************************************************
sub _fetchTopicCommentListBy {
    my ($self, $dbh, $community_id, $community_topic_id, $offset, $condition_limit) = @_;

    my %condition = (
        ## Modified 条件にstatus_flagを追加 2008/11/27
        wherestr    => 'community_id=? AND community_topic_id=? AND status_flag=?',
        orderbystr    => 'registration_date DESC',
        limitstr    => "$offset, $condition_limit",
        placeholder => ["$community_id", "$community_topic_id", 2],
    );

    my $CommunityTopicCommentList = MyClass::JKZDB::CommunityTopicCommentList->new ($dbh);
    $CommunityTopicCommentList->executeSelect (\%condition);

    return $CommunityTopicCommentList;
}



#******************************************************
# @desc        アクセッサメソッド
#            引数を元にコミュニティー属性情報をかえします。
# @access    public
# @return    
#******************************************************

sub attrCommunity {
    my $self = shift;

    return (undef) unless @_;
    $self->{$_[0]} = $_[1] if @_ > 1;
    return ($self->{$_[0]});
}





1;
__END__
