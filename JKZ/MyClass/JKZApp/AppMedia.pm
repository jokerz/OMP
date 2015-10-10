#******************************************************
# @desc      広告管理クラス
# @package   MyClass::JKZApp::AppMedia
# @access    public
# @author    Iwahase Ryo
# @create    2009/01/13
# @update    2010/03/26  identifyUserByMediaSessionIDメソッド追加 広告不正の管理機能追加
# @version   1.00
#******************************************************
package MyClass::JKZApp::AppMedia;

use 5.008005;
our $VERSION = '1.00';

use strict;

use base qw(MyClass::JKZApp);

## ポイントバック広告
use MyClass::JKZDB::Media;
use MyClass::JKZDB::MediaCategory;
use MyClass::JKZDB::MediaAgent;
## アフィリエイト広告
use MyClass::JKZDB::Affiliate;
## リンクバナー広告
use MyClass::JKZDB::Adv;
## マイページ広告
use MyClass::JKZDB::MyPageMedia;
use MyClass::JKZDB::Member;

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
# @desc        親クラスのメソッド
# @param    
#******************************************************
sub dispatch {
    my $self = shift;

    !defined($self->query->param('action')) ? $self->action('mediaTopMenu') : $self->action();

    my $publishdir = $self->PUBLISH_DIR() . '/admin/Media';
    if (! -d $publishdir) {
        MyClass::WebUtil::createDir($publishdir);
    }
    $self->{publishdir} = $publishdir;

    $self->SUPER::dispatch();
}


#******************************************************
# @access    publich
# @desc        accessor
# @param    
# @param    
# @return    
#******************************************************
sub publishdir {
    my $self = shift;
    return ($self->{publishdir});
}


#******************************************************
# @access    public
# @desc        default page
# @param
# @return    
#******************************************************
sub mediaTopMenu {
    my $self = shift;
  ## 検索フォームの表示
    $self->action('searchMedia');
   my $obj = {};

# Modified 2010/02/22
     my $categoryobj               = $self->fetchMediaCategory();
     $obj->{LoopSearchMediaCategoryList} = $#{ $categoryobj->{mediacategory_id} };
     if (0 <= $obj->{LoopSearchMediaCategoryList}) {
         map {
             foreach my $key (qw( mediacategory_id mediacategory_name )) {
                 $obj->{'search_'.$key}->[$_] = $categoryobj->{$key}->[$_];
             }
         } 0..$obj->{LoopSearchMediaCategoryList};
     }


	return $obj;
}


#************************************************************************************************************
# ポイントバックメディア広告
#************************************************************************************************************

sub registAgent_Category {
    my $self = shift;
    my $obj  = {};

    my $mediaagentlist    = $self->getFromObjectFile({ CONFIGURATION_VALUE => 'MEDIAAGENTLIST_OBJ' });
    my $mediacategorylist = $self->getFromObjectFile({ CONFIGURATION_VALUE => 'MEDIACATEGORYLIST_OBJ' });

            $obj->{LoopMediaAgentList} = $#{ $mediaagentlist }-1;
            map {
                foreach my $key (keys %{ $mediaagentlist->[$_+1] } ) {
                    $obj->{$key}->[$_] = $mediaagentlist->[$_+1]->{$key};
                }
            } 0..$obj->{LoopMediaAgentList};

            $obj->{LoopMediaCategoryList} = $#{ $mediacategorylist }-1;
            map {
                foreach my $key (keys %{ $mediacategorylist->[$_+1] } ) {
                    $obj->{$key}->[$_] = $mediacategorylist->[$_+1]->{$key};
                    2 == $obj->{status_flag}->[$_] ? $obj->{IfStatusIsActive}->[$_] = 1 : $obj->{IfStatusIsNotActive}->[$_] = 1;
                    $obj->{cssstyle}->[$_] = 0 != $_ % 2 ? 'focusodd' : 'focuseven';
                }
            } 0..$obj->{LoopMediaCategoryList};

    return $obj;
}


#******************************************************
# @access    public
# @desc      メディア広告検索
# @param
# @return    
#******************************************************
sub searchMedia {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};
    my $dbh  = $self->getDBConnection();

# Modified 2010/02/22
     my $categoryobj               = $self->fetchMediaCategory();
     $obj->{LoopSearchMediaCategoryList} = $#{ $categoryobj->{mediacategory_id} };
     if (0 <= $obj->{LoopSearchMediaCategoryList}) {
         map {
             foreach my $key (qw( mediacategory_id mediacategory_name )) {
                 $obj->{'search_'.$key}->[$_] = $categoryobj->{$key}->[$_];
             }
         } 0..$obj->{LoopSearchMediaCategoryList};
     }

    if ($q->param('search') and 'searchMedia' eq $q->param('action')) {

        my %condition = ();
        $condition{columnslist} = [
                 'ad_id',
                 'status_flag',
                 'point_type',
                 'agent_name',
                 'ad_name',
                 'ad_period_flag',
                 'point',
                 'carrier',
                 'price_per_regist',
                 'mediacategory_id',
        ];

        #*************************
        # 検索条件生成
        #*************************
        my @searchquery;
        ## 検索条件の内容
        my @searchquerymessage;
        my $cookie_name     = $self->{cfg}->param('COOKIE_NAME') . 'searchcondition';
        my $record_limit    = $q->param('limit') || 50;
        my $offset          = $q->param('off')   || 0;
        my $condition_limit = $record_limit+1;

        ## 全レコード件数SQL
        my $MAXREC_SQL = "SELECT COUNT(m.ad_id) FROM JKZ_WAF.tMediaM m";

        if ($q->MethGet() && defined($q->param('off'))) {
            my $cookie = $q->cookie($cookie_name);

            my ($whereSQL, $orderbySQL, $holder)                 = split (/,/, $cookie);
            ( $condition{whereSQL}, $obj->{SEARCHQUERYMESSAGE} ) = split(/::/, $whereSQL);
            @{ $condition{placeholder} }                         = split(/ /, $holder);
            $condition{orderbySQL}                               = $orderbySQL;

            $MAXREC_SQL .= sprintf(" WHERE %s", $condition{whereSQL}) if $condition{whereSQL} ne "";

        }
        else {

            #*************************
            # 広告ID fsad_id fsad_id -> start point fead_id -> end point
            #*************************
            if ($q->param('fsad_id')) {
                my @ad_id;
                my $ad_idplaceholder;
                my @param = $q->param('fsad_id');
                if (0 < $#param) {
                    #$ad_id = join(',', @param);
                    @ad_id = @param;
                    $ad_idplaceholder = ',?' x $#ad_id;
                }
                else {
                    my $id = $param[0];
                    $id =~ s/^[\s|,]+//g;
                    $id =~ s/[\s|,]+$//g;
                    $id =~ s/[\s|,]+/,/g;
                    @ad_id = split(/,/, $id);
                    $ad_idplaceholder = ',?' x $#ad_id;
                }

                push(@searchquery, sprintf("ad_id IN(?%s)", $ad_idplaceholder));

                push(@{ $condition{placeholder} }, @ad_id);

                push(@searchquerymessage, sprintf("広告ID：[ %s ]", join(' ', @ad_id)));

            } else {
                push @searchquerymessage, "広告ID：[ 指定なし ]";
            }

            #*************************
            # 広告名・サイト名
            #*************************
            if ($q->param('ad_name')) {
                my $ad_name = $q->param('ad_name');
                push(@searchquery, "ad_name LIKE ?");
                push(@{ $condition{placeholder} }, '%' . $ad_name . '%');
                push @searchquerymessage, "広告名・サイト名：[ $ad_name ]";
            } else {
                push @searchquerymessage, "広告名・サイト名：[ 指定なし ]";
            }

            #*************************
            # 代理店名
            #*************************
            if ($q->param('agent_name')) {
                my $agent_name = $q->param('agent_name');
                push(@searchquery, 'agent_name LIKE ?');
                push(@{ $condition{placeholder} }, '%' . $agent_name . '%');
                push @searchquerymessage, "代理店名：[ $agent_name ]";
            } else {
                push @searchquerymessage, "代理店名：[ 指定なし ]";
            }

            #*********************************
            # 状態検索条件SQLの生成
            #*********************************
            my $status_flag;
            if ($q->param('status_flag')) {
                ## bit演算ではない
                map { $status_flag += $_ } $q->param('status_flag');
                ## 全選択もしくは選択無し以外での処理
                if (7 > $status_flag && 0 < $status_flag) {
                    push(@searchquery, 'status_flag & ?');
                    push(@{ $condition{placeholder} }, $status_flag);
                    my $search_status =
                        ( 2 == $status_flag ) ? "公開状態：[ 公開 ]"                :
                        ( 3 == $status_flag ) ? "公開状態：[ 公開 非公開 ]"         :
                        ( 4 == $status_flag ) ? "公開状態：[ 有効期限切れ ]"        :
                        ( 5 == $status_flag ) ? "公開状態：[ 非公開 有効期限切れ ]" :
                        ( 6 == $status_flag ) ? "公開状態：[ 公開 有効期限切れ ]"   :
                                           "公開状態：[ 非公開 ]"              ;
                    push( @searchquerymessage, $search_status );
                }

            } else {
                push @searchquerymessage, "公開状態：[ 指定無し ]";
            }

            #*********************************
            # メディアのカテゴリ追加 2010/02/22
            #*********************************

            my $mediacategory_id;
            if (0 < $q->param('search_mediacategory_id')) {
                $mediacategory_id = $q->param('search_mediacategory_id');
                    push(@searchquery, 'mediacategory_id = ?');
                    push(@{ $condition{placeholder} }, $mediacategory_id);

            } else {
                push @searchquerymessage, "カテゴリ：[ 指定無し ]";
            }

            $obj->{SEARCHQUERYMESSAGE} = join('　', @searchquerymessage);

            $condition{whereSQL} = sprintf "%s", join(' AND ', @searchquery);

            my @ORDERBY = ('registration_date', 'ad_id', 'point', 'price_per_regist',);

            $condition{orderbySQL} = sprintf("%s DESC", $ORDERBY[$q->param('order_by')-1]);

            $MAXREC_SQL .= sprintf(" %s%s", (0 < @searchquery ? "WHERE " : ""),join(' AND ', @searchquery));

            my $cookiesql = join(' AND ', @searchquery);
            $cookiesql .= sprintf("::%s", $obj->{SEARCHQUERYMESSAGE});
            $cookiesql .= sprintf("\, %s", $condition{orderbySQL});
            $cookiesql .= "\,@{ $condition{placeholder} }" if defined(@{ $condition{placeholder} });

            $self->{cookie} = $self->query->cookie(
                            -name  => $cookie_name,
                            -value => $cookiesql,
                            -path  =>    '/',
                            );

        }

        $condition{limitSQL} = "$offset, $condition_limit";

        #*********************************
        ## ページ数表示リンクのナビ
        #*********************************
        my @navilink;
        my $maxrec = $dbh->selectrow_array($MAXREC_SQL, undef, @{ $condition{placeholder} });

        ## レコード数が1ページ上限数より多い場合
        if ($maxrec > $record_limit) {

            my $url = 'app.mpl?app=AppMedia;action=searchMedia;search=1';

        ## 前へページの生成
            if (0 == $offset) { ## 最初のページの場合
                push(@navilink, "&lt;&lt;前&nbsp;");
            } else { ## 2ページ目以降の場合
                push(@navilink, $self->genNaviLink($url, "&lt;&lt;前&nbsp;", $offset - $record_limit));
            }

        ## ページ番号生成
            for (my $i = 0; $i < $maxrec; $i += $record_limit) {

                my $pageno = int ($i / $record_limit) + 1;

                if ($i == $offset) { ###現在表示してるﾍﾟｰｼﾞ分
                    push (@navilink, '<font style="font-size:14px;font-weight:bold;">' . $pageno . '</font>');
                } else {
                    push (@navilink, $self->genNaviLink($url, $pageno, $i));
                }
            }

        ## 次へページの生成
            if (($offset + $record_limit) > $maxrec) {
                push (@navilink, "&nbsp;次&gt;&gt;");
            } else {
                push (@navilink, $self->genNaviLink($url, "&nbsp;次&gt;&gt;", $offset + $record_limit));
            
            }

            @navilink = map{ "$_\n" } @navilink;
            
            $obj->{pagenavi} = sprintf("<font size=-1>[全%s件 / %s件\表\示]</font><br />", $maxrec, $record_limit) . join(' ', @navilink);
        }
        else { ## Modified レコード数の表示を追加 2009/10/29 
            $obj->{pagenavi} = sprintf("<font size=-1>[全%s件]</font><br />", $maxrec, $record_limit);
        }

        ## メディアのカテゴリ名
        my $mediacategorylist = $self->getFromObjectFile({ CONFIGURATION_VALUE => 'MEDIACATEGORYLIST_OBJ' });

        my $MediaList = MyClass::JKZDB::Media->new($dbh);
        my $aryref = $MediaList->getSpecificValuesSQL(\%condition);

        $obj->{LoopSearchMediaList} = ($#{ $aryref->{ad_id} } >= $record_limit) ? $#{ $aryref->{ad_id} }-1 : $#{ $aryref->{ad_id} };
        if (0 <= $obj->{LoopSearchMediaList}) {
            map {
                foreach my $key (%{ $aryref }) {
                    $obj->{$key}->[$_] = $aryref->{$key}->[$_];
                }
                2 == $obj->{carrier}->[$_]  ? $obj->{IfCarrier2}->[$_]  = 1  :
                4 == $obj->{carrier}->[$_]  ? $obj->{IfCarrier4}->[$_]  = 1  :
                6 == $obj->{carrier}->[$_]  ? $obj->{IfCarrier6}->[$_]  = 1  :
                8 == $obj->{carrier}->[$_]  ? $obj->{IfCarrier8}->[$_]  = 1  :
                10 == $obj->{carrier}->[$_] ? $obj->{IfCarrier10}->[$_] = 1 :
                12 == $obj->{carrier}->[$_] ? $obj->{IfCarrier12}->[$_] = 1 :
                                              $obj->{IfCarrier14}->[$_] = 1 ;
                $obj->{IfStatusFlagIsActive}->[$_] = 1 if 2 == $obj->{status_flag}->[$_];

                $obj->{status_flagImages}->[$_]  = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$_]-1));
                $obj->{mediacategory_name}->[$_] = $mediacategorylist->[$obj->{mediacategory_id}->[$_]]->{mediacategory_name};

            } 0..$obj->{LoopSearchMediaList};

           $obj->{hit_record} = $obj->{LoopSearchMediaList}+1;
           $obj->{IfSearchResultExists} = 1;
        }

        $obj->{IfSearchResultNotExists} = 1 if 0 > $obj->{LoopSearchMediaList};
        $obj->{IfSearchExecuted} = 1;
    }
    return $obj;

}


sub changeMediaStatus {
    my $self = shift;

}


#******************************************************
# @access    public
# @desc      ポイント広告マイページ表示設定処理
# @param    
#******************************************************
sub addtoMyPageMedia_UpDateStatus {
    my $self = shift;
    my @ad_id = $self->query->param('ad_id');
    my $set_status_flag_to = $self->query->param('setMyPageMediaStatusTo');

   my $sql = ( 2 == $set_status_flag_to ) ? sprintf("REPLACE INTO tMyPageMediaF (ad_id, ad_name, point, mediacategory_id, carrier, ad_16words_text) 
 SELECT ad_id, ad_name, point, mediacategory_id, carrier, ad_16words_text
 FROM tMediaM
 WHERE ad_id IN(%s)", join(',', @ad_id))  :
             ( 1 == $set_status_flag_to ) ? sprintf("DELETE FROM tMyPageMediaF WHERE ad_id IN(%s)", join(',', @ad_id)) :
             -1;
    if (0 > $sql) {
        my $obj = $self->printErrorPage("選択ステータスNG");
        return $obj;
    }

    my $dbh  = $self->getDBConnection();
    my $rc   = $dbh->do($sql);

my $str = Dumper(\@ad_id);
$str .= '<hr />' .$sql;
$str .= '<hr />DB格納時リターンコード：' .$rc;
$str .= '<hr />' . $self->query->Dump();
my $obj = $self->printErrorPage($str);

return $obj;

}


#******************************************************
# @access    public
# @desc      ポイント広告マイページ一覧表示
# @param    
#******************************************************
sub viewMyPageMediaList {
    my $self = shift;
    my $obj  = {};

    my $dbh = $self->getDBConnection();
    $self->setDBCharset('sjis');
    my $MyPageMediaList = MyClass::JKZDB::MyPageMedia->new($dbh);
    my $aryref    = $MyPageMediaList->getSpecificValuesSQL(
        {
            columnslist => [
                     'ad_id',
                     'status_flag',
                     'ad_name',
                     'point',
                     'carrier',
                     'ad_16words_text',
            ],
        }
    );

    $obj->{LoopMyPagePointBackMediaList} = $#{ $aryref->{ad_id} };

    if (0 <= $obj->{LoopMyPagePointBackMediaList}) {
        $obj->{IfExistsMyPageMediaList} = 1;
        no strict 'refs';
        map {
            foreach my $key (%{ $aryref }) {
                $obj->{$key}->[$_] = $aryref->{$key}->[$_];
            }
            $obj->{status_flagImages}->[$_]  = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$_]-1));

            2 == $obj->{carrier}->[$_]  ? $obj->{IfCarrier2}->[$_] = 1  :
            4 == $obj->{carrier}->[$_]  ? $obj->{IfCarrier4}->[$_] = 1  :
            6 == $obj->{carrier}->[$_]  ? $obj->{IfCarrier6}->[$_] = 1  :
            8 == $obj->{carrier}->[$_]  ? $obj->{IfCarrier8}->[$_] = 1  :
            10 == $obj->{carrier}->[$_] ? $obj->{IfCarrier10}->[$_] = 1 :
            12 == $obj->{carrier}->[$_] ? $obj->{IfCarrier12}->[$_] = 1 :
                                          $obj->{IfCarrier14}->[$_] = 1 ;

        } 0..$obj->{LoopMyPagePointBackMediaList};
    } else {
        $obj->{IfNotExistsMyPageMediaList} = 1;
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc      メディアカテゴリリスト
# @param    
#******************************************************
sub fetchMediaCategory {
    my $self = shift;

    my $memcached = $self->initMemcachedFast();
    my $obj       = $memcached->get("JKZ_WAFAppMediaCategorylist");
    if (!$obj) {
        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');

        my $cmsMediaCategorylist = MyClass::JKZDB::MediaCategory->new($dbh);
        $cmsMediaCategorylist->executeSelectList();
        map { $obj->{$_} = $cmsMediaCategorylist->{columnslist}->{$_} } keys %{$cmsMediaCategorylist->{columnslist}};

        $memcached->add("JKZ_WAFAppMediaCategorylist", $obj, 600);

        undef($cmsMediaCategorylist);
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc      代理店情報取得
# @param
# @return    
#******************************************************
sub fetchMediaAgent {
    my $self = shift;

    my $memcached = $self->initMemcachedFast();
    my $obj       = $memcached->get("JKZ_WAFAppMediaAgentlist");
    if (!$obj) {
        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');

        my $cmsMediaAgentlist = MyClass::JKZDB::MediaAgent->new($dbh);
        $cmsMediaAgentlist->executeSelectList();
        map { $obj->{$_} = $cmsMediaAgentlist->{columnslist}->{$_} } keys %{ $cmsMediaAgentlist->{columnslist} };

        $memcached->add("JKZ_WAFAppMediaAgentlist", $obj, 600);

        undef($cmsMediaAgentlist);
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc      メディアカテゴリデータ登録・更新実行
# @param
# @return    
#******************************************************
sub modifyMediaCategory {
    my $self = shift;
    my $mediacategory_name = $self->query->param('mediacategory_name');
    my $mediacategory_id;

    my $updateData = {};

   ## このパラメータがある場合新規登録
    if (defined($self->query->param('registMediaCategory'))) {
        $updateData->{mediacategory_id} = -1;
        $updateData->{status_flag}      = $self->query->param('status_flag');
    }
    else {
        if ("" eq $self->query->param('mediacategory_id') || !defined($self->query->param('mediacategory_id') )) {
    	    $updateData->{ERROR_MSG} = "カテゴリIDがありません。";
    	    return $updateData;
        }
        $updateData->{mediacategory_id} = $self->query->param('mediacategory_id');
        $updateData->{status_flag}      = $self->query->param('status_flag');
    }

    if (5 > length($mediacategory_name) || "" eq $mediacategory_name) {
    	$updateData->{ERROR_MSG} = "カテゴリ名がありません。";
    	return $updateData;
    }
    $updateData->{mediacategory_name} = $mediacategory_name;

    my $dbh  = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $cmsMediaCategory = MyClass::JKZDB::MediaCategory->new($dbh);
    if ('0E0' eq $cmsMediaCategory->executeUpdate($updateData)) {
        $updateData->{ERROR_MSG} = '<li>' . $self->ERROR_MSG("ERR_MSG99") . '</li>';
        return $updateData;
    }

    ## オブジェクト再構築
    my $moddir = $self->CONFIGURATION_VALUE("MODULE_DIR");
    my $module = sprintf("%s/%s", $moddir, $self->CONFIGURATION_VALUE("GENERATE_MEDIACATEGORY_LIST"));
    if (-e $module) {
        system("cd $moddir && perl $module");
        warn "cd $moddir && perl $module";
    }

    $self->action('registAgent_Category');
    return $self->registAgent_Category();
}


#******************************************************
# @access    public
# @desc        データ登録・更新実行
# @param
# @return    
#******************************************************
sub modifyMedia {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    if (!$q->MethPost()) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG18");
    }

    my $updateData = {
        ad_id            => undef,
        status_flag      => undef,
        point_type       => undef,
        agent_name       => undef,
        ad_name          => undef,
        ad_url           => undef,
        ad_period_flag   => undef,
        valid_date       => undef,
        expire_date      => undef,
        point            => undef,
        mediacategory_id => undef,
        personality      => undef,
        carrier          => undef,
        price_per_regist => undef,
        return_url       => undef,
        ad_16words_text  => undef,
        ad_text          => undef,
        param_name_for_session_id        => undef,
        param_name_for_status            => undef,
        param_name_for_result_session_id => undef,
        status_value_for_success         => undef,
        send_param_name                  => undef,
    };

    if (defined($q->param('registMedia'))) {
        my $publishdir = $self->publishdir();
        my $publish = sprintf("%s/%s", $publishdir, $q->param('md5key'));
        eval {
            my $publishobj = MyClass::WebUtil::publishObj( { file=>$publish } );
            map { exists($updateData->{$_}) ? $updateData->{$_} = $publishobj->{$_} : "" } keys %{ $publishobj };
         $updateData->{send_param_name} = $publishobj->{send_param_name};
        };

        ## シリアライズオブジェクトの破棄
        MyClass::WebUtil::clearObj($publish);
    }
    else {
        if ("" eq $q->param('ad_id') || !$q->param('ad_id')) {
            $obj->{ERROR_MSG} = '<li>' . $self->ERROR_MSG("NO ID has been FOUND") . '</li>';
            return $obj;
        }
        $updateData->{ad_id}            = $q->param('ad_id');
        $updateData->{status_flag}      = $q->param('status_flag');
        $updateData->{point_type}       = $q->param('point_type');
        $updateData->{agent_name}       = $q->param('agent_name');
        $updateData->{ad_name}          = $q->param('ad_name');
        $updateData->{ad_url}           = $q->param('ad_url');
        $updateData->{ad_period_flag}   = $q->param('ad_period_flag');
        $updateData->{years}            = $q->param('years');
        $updateData->{months}           = $q->param('months');
        $updateData->{dates}            = $q->param('dates');
        $updateData->{toyears}          = $q->param('toyears');
        $updateData->{tomonths}         = $q->param('tomonths');
        $updateData->{todates}          = $q->param('todates');
        $updateData->{valid_date}       = sprintf("%s-%02d-%02d",$updateData->{years}, $updateData->{months}, $updateData->{dates});
        $updateData->{expire_date}      = sprintf("%s-%02d-%02d",$updateData->{toyears}, $updateData->{tomonths}, $updateData->{todates});
        $updateData->{point}            = $q->param('point');
        $updateData->{mediacategory_id} = $q->param('mediacategory_id');

        map { $updateData->{carrier}    += 2 ** $_ } $q->param('carrier');
        $updateData->{price_per_regist} = $q->param('price_per_regist');
        $updateData->{return_url}       = $q->param('return_url');
        $updateData->{ad_16words_text}  = $q->param('ad_16words_text');
        $updateData->{ad_text}          = $q->param('ad_text');
        $updateData->{param_name_for_session_id}        = $q->param('param_name_for_session_id');
        $updateData->{param_name_for_status}            = $q->param('param_name_for_status');
        $updateData->{param_name_for_result_session_id} = $q->param('param_name_for_result_session_id');
        $updateData->{status_value_for_success}         = $q->param('status_value_for_success');
        $updateData->{send_param_name}         = $q->param('send_param_name');
    }

        ## 暫定処理 primary keyをacdにしたため新規登録とデータの編集の区別をsubmitボタンの名前でする
   $updateData->{ad_id} = -1 if defined($q->param('registMedia'));
        my $dbh  = $self->getDBConnection();
        $self->setDBCharset("sjis");
        my $cmsMedia = MyClass::JKZDB::Media->new($dbh);

        if ('0E0' eq $cmsMedia->executeUpdate($updateData)) {
            $obj->{ERROR_MSG} = '<li>' . $self->ERROR_MSG("ERR_MSG99") . '</li>';

            return $obj;
        }

        undef($cmsMedia);


    $self->action('mediaTopMenu');
    return $self->mediaTopMenu();
    #$self->action('detailMedia');
    #$q->param(-name=>"mode",-value=>"view");
    #$q->param(-name=>"ad_id",-value=>$updateData->{ad_id});
    #return $self->detailMedia();

}


#******************************************************
# @access    public
# @desc        メディアの登録新規
# @param
# @return    
#******************************************************
sub registMedia {
    my $self = shift;
    my $q    = $self->query();
    $q->autoEscape(0);
    my $obj  = {};

    defined($q->param('md5key')) ? $obj->{IfConfirmMedia} = 1 : $obj->{IfRegistMedia} = 1;

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    if ($obj->{IfConfirmMedia}) {
my $agent_id = $q->param('agent_id');
        my $dbh  = $self->getDBConnection();
        $self->setDBCharset("sjis");
my $cmsMediaAgent = MyClass::JKZDB::MediaAgent->new($dbh);
my $tmpobj = $cmsMediaAgent->getSpecificValuesSQL({
columnslist => [
  'agent_id',
  'agent_name', 
  'return_base_url',
  'kick_back_url',
  'param_name_for_session_id',
  'param_name_for_status',
  'param_name_for_result_session_id',
  'status_value_for_success',
  'send_param_name'
],
whereSQL => 'agent_id=?',
placeholder => [$agent_id]
});

        ( $obj->{mediacategory_id} , $obj->{EncodedMediaCategoryName} ) = split(/;/, $q->param('mediacategory_id'));
        $obj->{status_flag}      = $q->param('status_flag');
        $obj->{point_type}       = $q->param('point_type');
        $obj->{agent_name}       = $tmpobj->{agent_name}->[0];
        $obj->{ad_name}          = $q->param('ad_name');
        $obj->{ad_url}           = $q->param('ad_url');
        $obj->{ad_period_flag}   = $q->param('ad_period_flag');
        $obj->{years}            = $q->param('years');
        $obj->{months}           = $q->param('months');
        $obj->{dates}            = $q->param('dates');
        $obj->{toyears}          = $q->param('toyears');
        $obj->{tomonths}         = $q->param('tomonths');
        $obj->{todates}          = $q->param('todates');
        $obj->{valid_date}       = sprintf("%s-%02d-%02d",$obj->{years}, $obj->{months}, $obj->{dates});
        $obj->{expire_date}      = sprintf("%s-%02d-%02d",$obj->{toyears}, $obj->{tomonths}, $obj->{todates});
        $obj->{point}            = $q->param('point');
        map { $obj->{carrier}    += 2 ** $_ } $q->param('carrier');
        $obj->{price_per_regist} = $q->param('price_per_regist');
        $obj->{return_url}       = $tmpobj->{return_base_url}->[0];
        $obj->{KICKBACKURL}      = sprintf("%s?s={%s}&st={%s}&rs={%s}", $tmpobj->{return_base_url}->[0], $tmpobj->{param_name_for_session_id}->[0], $tmpobj->{param_name_for_status}->[0], $tmpobj->{param_name_for_result_session_id}->[0]);
        $obj->{ad_16words_text}  = $q->param('ad_16words_text');
        $obj->{ad_text}          = $q->param('ad_text');
        $obj->{param_name_for_session_id}        = $tmpobj->{param_name_for_session_id}->[0];
        $obj->{param_name_for_status}            = $tmpobj->{param_name_for_status}->[0];
        $obj->{param_name_for_result_session_id} = $tmpobj->{param_name_for_result_session_id}->[0];
        $obj->{status_value_for_success}         = $tmpobj->{status_value_for_success}->[0];
        $obj->{send_param_name}                  = $tmpobj->{send_param_name}->[0];

        my $publish = sprintf("%s/%s", $self->publishdir(), $q->param('md5key'));
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

        $obj->{DecodedMediaCategoryName} = $q->unescape( $obj->{EncodedMediaCategoryName} );
        $obj->{ad_16words_text} = MyClass::WebUtil::yenRyenN2br($obj->{ad_16words_text});
        $obj->{ad_text}         = MyClass::WebUtil::yenRyenN2br($obj->{ad_text});

        $obj->{carrierDescription}       = 
                ( 14 == $obj->{carrier} ) ? $obj->{IfAllCarrier}     = 1 :
                ( 2  == $obj->{carrier} ) ? $obj->{IfDoCoMo}         = 1 :
                ( 4  == $obj->{carrier} ) ? $obj->{IfSoftBank}       = 1 :
                ( 8  == $obj->{carrier} ) ? $obj->{IfAU}             = 1 :
                ( 12 == $obj->{carrier} ) ? $obj->{IfSoftBankAU}     = 1 :
                ( 6  == $obj->{carrier} ) ? $obj->{IfDoCoMoSoftBank} = 1 :
                                            $obj->{IfDoCoMoAU}       = 1 ;

        2 == $q->param('ad_period_flag')  ? $obj->{IfAdPeriodFlagSelected} = 1 : $obj->{IfAdPeriodFlagNotSelected} = 1 ;
        2 == $q->param('point_type')      ? $obj->{IfPointTypeSelected}    = 1 : $obj->{IfPointTypeNotSelected} = 1;

        $obj->{ERROR_MSG} .= '<li>代理店名が入力されてません</li>' if "" eq $obj->{agent_name};
        $obj->{ERROR_MSG} .= '<li>広告設定名・サイト名が入力されてません</li>' if "" eq $obj->{ad_name};
        $obj->{ERROR_MSG} .= '<li>開始日と終了日の整合性がとれてないです</li>' if $obj->{years} > $obj->{toyears};
        $obj->{ERROR_MSG} .= '<li>広告先URLが有効なURLではありません</li>' if !MyClass::WebUtil::checkURL($q->param('ad_url'));

      ## 代理店名が無いもしくは8文字以下は登録できない
        #$obj->{IfDoNotShowSubmitButton} = 1 if !$q->param('agent_name') || 8 < length($q->param('agent_name'));
        #$obj->{IfDoNotShowSubmitButton} = 1 if !$q->param('ad_name')    || 8 < length($q->param('ad_name'));
        $obj->{IfDoNotShowSubmitButton} = 1 if !MyClass::WebUtil::checkURL($q->param('ad_url'));
        $obj->{IfShowSubmitButton}      = 1 if !$obj->{IfDoNotShowSubmitButton};
    }
    elsif ($obj->{IfRegistMedia}) {
        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');
        my $cmsMedia = MyClass::JKZDB::Media->new($dbh);
        $obj->{max_ad_id} = $cmsMedia->maxAdID() + 1;

        my $categoryobj               = $self->fetchMediaCategory();
        $obj->{LoopMediaCategoryList} = $#{ $categoryobj->{mediacategory_id} };
        if (0 <= $obj->{LoopMediaCategoryList}) {
            map {
                foreach my $key (qw( mediacategory_id mediacategory_name )) {
                    $obj->{$key}->[$_] = $categoryobj->{$key}->[$_];
                }
                $obj->{EncodedMediaCategoryName}->[$_] = $q->escape($obj->{mediacategory_name}->[$_]);

            } 0..$obj->{LoopMediaCategoryList};
        }

        my $agentobj = $self->fetchMediaAgent();
        $obj->{LoopMediaAgentList} = $#{ $agentobj->{agent_id} };
        if (0 <= $obj->{LoopMediaAgentList}) {
            map {
                foreach my $key (qw(agent_id agent_name)) {
                    $obj->{$key}->[$_] = $agentobj->{$key}->[$_];
                }
            } 0..$obj->{LoopMediaAgentList};
        }

        my $pulldown = $self->createPeriodPullDown({year=>"years", month=>"months", date=>"dates", range=>"0,3"});
        map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
        $pulldown = $self->createPeriodPullDown({year=>"toyears", month=>"tomonths", date=>"todates", range=>"0,3"});
        map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        メディアの詳細
# @param
# @return    
#******************************************************
sub detailMedia {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    $obj->{md5key}     = MyClass::WebUtil::createHash($self->__session_id(), 20);
    $obj->{IfModeView} = !defined($q->param('mode')) || 'view' eq $q->param('mode') ? 1 : 0;
    $obj->{IfModeEdit} = defined($q->param('mode'))  && 'edit' eq $q->param('mode') ? 1 : 0;

    my $ad_id = $q->param('ad_id');
    my $dbh   = $self->getDBConnection();
    $self->setDBCharset("sjis");
    
    my $cmsMedia = MyClass::JKZDB::Media->new($dbh);
    
    if (!$cmsMedia->executeSelect({whereSQL => "ad_id=?", placeholder => [$ad_id]})) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG12');
    } else {
        map { $obj->{$_} = $cmsMedia->{columns}->{$_} } keys %{$cmsMedia->{columns}};

## 共通事項
        #2 == $obj->{status_flag}    ? $obj->{IfStatusFlagIsActive}   = 1 : $obj->{IfStatusFlagIsNotActive}   = 1;
        # 20100301
        2 == $obj->{status_flag}    ? $obj->{IfStatusFlagIsActive}   = 1 :
        4 == $obj->{status_flag}    ? $obj->{IfStatusFlagIsExpired}  = 1 :
                                      $obj->{IfStatusFlagIsNotActive}= 1;
        2 == $obj->{ad_period_flag} ? $obj->{IfAdPeriodFlagSelected} = 1 : $obj->{IfAdPeriodFlagNotSelected} = 1;
        2 == $obj->{point_type}     ? $obj->{IfPointTypeSelected}    = 1 : $obj->{IfPointTypeNotSelected}    = 1;
        $obj->{carrierDescription} = 
                    ( 14 == $obj->{carrier} ) ? $obj->{IfAllCarrier}     = 1 :
                    ( 2  == $obj->{carrier} ) ? $obj->{IfDoCoMo}         = 1 :
                    ( 4  == $obj->{carrier} ) ? $obj->{IfSoftBank}       = 1 :
                    ( 8  == $obj->{carrier} ) ? $obj->{IfAU}             = 1 :
                    ( 12 == $obj->{carrier} ) ? $obj->{IfSoftBankAU}     = 1 :
                    ( 6  == $obj->{carrier} ) ? $obj->{IfDoCoMoSoftBank} = 1 :
                                                $obj->{IfDoCoMoAU}       = 1 ;

        if ($obj->{IfModeEdit}) {
            my $mediacategorylist = $self->getFromObjectFile({ CONFIGURATION_VALUE => 'MEDIACATEGORYLIST_OBJ' });

            $obj->{LoopMediaCategoryList} = $#{ $mediacategorylist } - 1;
            map {
                $obj->{lmediacategory_id}->[$_]         = $mediacategorylist->[$_+1]->{'mediacategory_id'};
                $obj->{lmediacategory_name}->[$_]       = $mediacategorylist->[$_+1]->{'mediacategory_name'};
                $obj->{IfSelectedMediaCategoryID}->[$_] = 1 if $obj->{lmediacategory_id}->[$_] == $obj->{mediacategory_id};
            } 0..$obj->{LoopMediaCategoryList};

            my $pulldown = $self->createPeriodPullDown({year=>"years", month=>"months", date=>"dates", range=>"0,3", defaultvalue=> $obj->{valid_date}});
            map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
            $pulldown = $self->createPeriodPullDown({year=>"toyears", month=>"tomonths", date=>"todates", range=>"0,3", defaultvalue=> $obj->{expire_date}});
            map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};

        }
        if ($obj->{IfModeView}) {
            $obj->{ad_16words_text} = MyClass::WebUtil::yenRyenN2br($obj->{ad_16words_text});
            $obj->{ad_text}         = MyClass::WebUtil::yenRyenN2br($obj->{ad_text});
            $obj->{valid_date}      =  substr($obj->{valid_date}, 0, 10);
            $obj->{expire_date}     =  substr($obj->{expire_date}, 0, 10);

            ( $obj->{fromyear}, $obj->{frommonth}, $obj->{fromdate} ) = split(/-/, $obj->{valid_date});
            ( $obj->{toyear}, $obj->{tomonth}, $obj->{todate} )       = split(/-/, $obj->{expire_date});

            $obj->{KICKBACKURL}      = sprintf("%s?s={%s}&st={%s}&rs={%s}", $obj->{return_url}, $obj->{param_name_for_session_id}, $obj->{param_name_for_status}, $obj->{param_name_for_result_session_id} );
            $obj->{status_flagImages}= $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}-1));

            my $tmpobj = $self->getFromObjectFile({ CONFIGURATION_VALUE => 'MEDIACATEGORYLIST_OBJ' , subject_id => $obj->{mediacategory_id} });
            $obj->{mediacategory_name} = $tmpobj->{mediacategory_name};
       ## 集計追加 2010/02/10
            my $sql = "
SELECT
 m.agent_name,
 m.ad_name,
 m.ad_id,
 COUNT(IF(ml.status_flag=2 AND ml.carrier=2, ml.ad_id, NULL)) AS REGD,
 COUNT(IF(ml.status_flag=2 AND ml.carrier=4, ml.ad_id, NULL)) AS REGSB,
 COUNT(IF(ml.status_flag=2 AND ml.carrier=8, ml.ad_id, NULL)) AS REGAU,
 COUNT(IF(ml.status_flag=2, ml.ad_id, NULL)) AS REGTOTAL,
 SUM(IF(ml.status_flag=2, ml.price_per_regist, 0)) AS PRICETOTAL,
 COUNT(IF(ml.status_flag=4 AND ml.carrier=2, ml.ad_id, NULL)) AS FAILD,
 COUNT(IF(ml.status_flag=4 AND ml.carrier=4, ml.ad_id, NULL)) AS FAILSB,
 COUNT(IF(ml.status_flag=4 AND ml.carrier=8, ml.ad_id, NULL)) AS FAILAU,
 COUNT(IF(ml.status_flag=4, ml.ad_id, NULL)) AS FAILTOTAL,
 COUNT(DISTINCT(IF(ml.carrier=2, ml.guid, NULL))) AS CLICKD, 
 COUNT(DISTINCT(IF(ml.carrier=4, ml.guid, NULL))) AS CLICKSB,
 COUNT(DISTINCT(IF(ml.carrier=8, ml.guid, NULL))) AS CLICKAU,
 COUNT(DISTINCT(ml.guid)) AS CLICKTOTAL
 FROM tMediaM m LEFT JOIN tMediaAccessLogF ml
 ON m.ad_id=ml.ad_id
 WHERE m.ad_id=? GROUP BY ml.ad_id;
";
            my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $ad_id);
            #use Data::Dumper;
            #warn Dumper($aryref);
            map { $obj->{$_} = $aryref->[0]->{$_} } keys %{ $aryref };
        }
    }
    undef($cmsMedia);

    return $obj;
}

#************************************************************************************************************
# アフィリエイト
#************************************************************************************************************

#******************************************************
# @access	public
# @desc		アフィリエイトデータ登録・更新実行
# @param
# @return	
#******************************************************
sub modifyAffiliate {
	my $self = shift;

	my $q = $self->query();
	my $obj = {};

	if (!$q->MethPost()) {
		$obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG18");
	}

	my $updateData = {
		acd			=> undef,
		status_flag	=> undef,
		valid_date	=> undef,
		expire_date	=> undef,
		param_name1	=> undef,
		param_name2	=> undef,
		return_url	=> undef,
		access_url	=> undef,
		client_name	=> undef,
		price		=> undef,
		comment		=> undef,
	};

	my $publishdir = $self->publishdir();
	my $publish = sprintf("%s/%s", $publishdir, $q->param('md5key'));
	eval {
		my $publishobj = MyClass::WebUtil::publishObj( { file=>$publish } );
		map { exists($updateData->{$_}) ? $updateData->{$_} = $publishobj->{$_} : "" } keys %{ $publishobj };
		$updateData->{return_url}	=~ s/&#37;&amp;/%&/g;
		$updateData->{return_url}	=~ s/&amp;&#37;/&%/g;
	};
	## パブリッシュオブジェクトの取得失敗の場合
	if ($@) {
		
	} else {

		## 暫定処理 primary keyをacdにしたため新規登録とデータの編集の区別をsubmitボタンの名前でする
		my $flag = defined($q->param('registAffiliate')) ? -1 : 1;

		my $dbh = $self->getDBConnection();
		$self->setDBCharset("sjis");
		my $cmsAffiliate = MyClass::JKZDB::Affiliate->new($dbh);

		if ('0E0' eq $cmsAffiliate->executeUpdate($updateData, $flag)) {
			$obj->{ERROR_MSG} = '<li>' . $self->ERROR_MSG("ERR_MSG99") . '</li>';
			## シリアライズオブジェクトの破棄
			MyClass::WebUtil::clearObj($publish);

			return $obj;
		}
		## シリアライズオブジェクトの破棄
		MyClass::WebUtil::clearObj($publish);
		undef($cmsAffiliate);
	}

	$self->_publishAffiliateLinkBannerDATA();

	$self->action('viewAffiliateList');
	return $self->viewAffiliateList();
}


#******************************************************
# @access	public
# @desc		アフィリエイトデータ新規登録
# @param
# @return	
#******************************************************
sub registAffiliate {
	my $self = shift;

	my $q = $self->query();
	$q->autoEscape(0);
	my $obj = {};

	defined($q->param('md5key')) ? $obj->{IfConfirmMedia} = 1 : $obj->{IfRegistMedia} = 1;

	$obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
	if ($obj->{IfConfirmMedia}) {
		$obj->{acd}			= $q->param('acd');
		$obj->{status_flag}	= $q->param('status_flag');
		$obj->{years}		= $q->param('years');
		$obj->{months}		= $q->param('months');
		$obj->{dates}		= $q->param('dates');
		$obj->{toyears}		= $q->param('toyears');
		$obj->{tomonths}	= $q->param('tomonths');
		$obj->{todates}		= $q->param('todates');
		$obj->{valid_date}	= sprintf("%s-%02d-%02d",$obj->{years}, $obj->{months}, $obj->{dates});
		$obj->{expire_date}	= sprintf("%s-%02d-%02d",$obj->{toyears}, $obj->{tomonths}, $obj->{todates});
		$obj->{param_name1}	= $q->param('param_name1');
		$obj->{param_name2}	= $q->param('param_name2');
		$obj->{client_name}	= $q->param('client_name');
		$obj->{return_url}	= $q->param('return_url');
		$obj->{return_url}	=~ s/%&/&#37;&amp;/g;
		$obj->{return_url}	=~ s/&%/&amp;&#37;/g;
		$obj->{access_url}	= $q->param('access_url');
		$obj->{price}		= $q->param('price');
		$obj->{comment}		= $q->param('comment');

		my $publish = sprintf("%s/%s", $self->publishdir(), $q->param('md5key'));
		MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

		$obj->{ERROR_MSG} .= '<li>広告コードが入力されてません</li>' if "" eq $obj->{acd};
		$obj->{ERROR_MSG} .= '<li>開始日と終了日の整合性がとれてないです</li>' if $obj->{years} > $obj->{toyears};
		$obj->{ERROR_MSG} .= '<li>成果送信先URLが有効なURLではありません</li>' if !MyClass::WebUtil::checkURL($q->param('return_url'));
		$obj->{ERROR_MSG} .= '<li>出稿URLが有効なURLではありません</li>' if !MyClass::WebUtil::checkURL($q->param('access_url'));

	}
	elsif ($obj->{IfRegistMedia}) {
		my $pulldown = $self->createPeriodPullDown({year=>"years", month=>"months", date=>"dates", range=>"0,3"});
		map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
		$pulldown = $self->createPeriodPullDown({year=>"toyears", month=>"tomonths", date=>"todates", range=>"0,3"});
		map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
	}

	return $obj;
}


#******************************************************
# @access    public
# @desc        登録済みアフィリエイトメディアの一覧表示
# @param
# @return    
#******************************************************
sub viewAffiliateList {
    my $self = shift;

    my $obj = {};

    my $dbh = $self->getDBConnection();

    my  $sql = "SELECT a.acd, a.status_flag, a.valid_date, a.expire_date, a.client_name, a.return_url, al.ACNT, ur.RCNT
 FROM tAffiliateM a
  LEFT JOIN (
   SELECT acd, COUNT(acd) AS ACNT
    FROM tAffiliateAccessLogF GROUP BY acd
  ) AS al ON (a.acd=al.acd)
   LEFT JOIN (
    SELECT acd, COUNT(acd) RCNT
     FROM tUserRegistLogF GROUP BY acd
  ) AS ur ON (a.acd=ur.acd)
  ORDER BY a.acd
";

    my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} });

    $obj->{LoopMediaList} = $#{$aryref};
    if (0 > $obj->{LoopMediaList}) {
        $obj->{IfNotExistsMediaList} = 1;
    }
    else {
        $obj->{IfExistsMediaList} = 1;
        for (my $i = 0; $i <= $obj->{LoopMediaList}; $i++) {
            map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{$aryref};

            ## 成果URL内の置換文字のキーを変換
            $obj->{return_url}->[$i] =~ s/%&/&#37;&amp;/g;
            $obj->{return_url}->[$i] =~ s/&%/&amp;&#37;/g;
            ## status_flagを画像に変換
            $obj->{status_flagImages}->[$i] = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$i]-1));
            ## 日付のセパレータを変更
            $obj->{valid_date}->[$i]  = MyClass::WebUtil::formatDateTimeSeparator($obj->{valid_date}->[$i], {sepfrom =>'-', septo=>'/'});
            $obj->{expire_date}->[$i] = MyClass::WebUtil::formatDateTimeSeparator($obj->{expire_date}->[$i], {sepfrom =>'-', septo=>'/'});

            my @IfStatus_flag = ('IfInvalid', 'IfValid');
            $obj->{$IfStatus_flag[$obj->{status_flag}->[$i] - 1]}->[$i] = 1;
        }
    }

    return $obj;
}


#******************************************************
# @access	public
# @desc		アフィリエイトの詳細
# @param
# @return	
#******************************************************
sub detailAffiliate {
	my $self = shift;

	my $q = $self->query();

	my $obj = {};

	defined($q->param('md5key')) ? $obj->{IfConfirmMedia} = 1 : $obj->{IfModifyMedia} = 1;

	$obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);

	if ($obj->{IfConfirmMedia}) {
		$obj->{acd}			= $q->param('acd');
		$obj->{status_flag}	= $q->param('status_flag');
		$obj->{years}		= $q->param('years');
		$obj->{months}		= $q->param('months');
		$obj->{dates}		= $q->param('dates');
		$obj->{toyears}		= $q->param('toyears');
		$obj->{tomonths}	= $q->param('tomonths');
		$obj->{todates}		= $q->param('todates');
		$obj->{valid_date}	= sprintf("%s-%02d-%02d",$obj->{years}, $obj->{months}, $obj->{dates});
		$obj->{expire_date}	= sprintf("%s-%02d-%02d",$obj->{toyears}, $obj->{tomonths}, $obj->{todates});
		$obj->{param_name1}	= $q->param('param_name1');
		$obj->{param_name2}	= $q->param('param_name2');
		$obj->{client_name}	= $q->param('client_name');
		$obj->{return_url}	= $q->param('return_url');
		$obj->{return_url}	=~ s/%&/&#37;&amp;/g;
		$obj->{return_url}	=~ s/&%/&amp;&#37;/g;
		$obj->{access_url}	= $q->param('access_url');
		$obj->{price}		= $q->param('price');
		$obj->{comment}		= $q->param('comment');

		2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;

		my $publish = sprintf("%s/%s", $self->publishdir(), $q->param('md5key'));
		MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

		$obj->{ERROR_MSG} .= '<li>広告コードが入力されてません</li>' if "" eq $obj->{acd};
		$obj->{ERROR_MSG} .= '<li>開始日と終了日の整合性がとれてないです</li>' if $obj->{years} > $obj->{toyears};
		$obj->{ERROR_MSG} .= '<li>成果送信先URLが有効なURLではありません</li>' if !MyClass::WebUtil::checkURL($q->param('return_url'));
		$obj->{ERROR_MSG} .= '<li>出稿URLが有効なURLではありません</li>' if !MyClass::WebUtil::checkURL($q->param('access_url'));

	}
	elsif ($obj->{IfModifyMedia}) {
		my $acd = $q->param('acd');
		my $dbh = $self->getDBConnection();
		$self->setDBCharset("sjis");

		my $cmsMedia = MyClass::JKZDB::Affiliate->new($dbh);

		if (!$cmsMedia->executeSelect({whereSQL => "acd=?", placeholder => [$acd]})) {
			$obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG12');
		} else {
			map { $obj->{$_} = $cmsMedia->{columns}->{$_} } keys %{$cmsMedia->{columns}};
			$obj->{return_url}	=~ s/%&/&#37;&amp;/g;
			$obj->{return_url}	=~ s/&%/&amp;&#37;/g;
			2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;

			my $pulldown = $self->createPeriodPullDown({year=>"years", month=>"months", date=>"dates", range=>"0,3", defaultvalue=>$obj->{valid_date}});
			map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
			$pulldown = $self->createPeriodPullDown({year=>"toyears", month=>"tomonths", date=>"todates", range=>"0,3", defaultvalue=>$obj->{expire_date}});
			map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};

		}
		undef($cmsMedia);
	}

	return $obj;
}


#******************************************************
# @access    public
# @desc      不正ポイント取得ユーザー
# @param
# @return    
#******************************************************
sub identifyUserByMediaSessionID {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    $obj->{action} = $self->action;

    if ($q->param('identifyUser')) {

        if ($q->param('fssession_id')) {
            my @session_id;
            my $session_id_placeholder;
            my @param = $q->param('fssession_id');
            $obj->{s_fssession_id} = $q->param('fssession_id');
            if (0 < $#param) {
                @session_id  = @param;
                $session_id_placeholder = ',?' x $#session_id;
            }
            else {
                my $id = $param[0];
                $id =~ s/^[\s|,]+//g;
                $id =~ s/[\s|,]+$//g;
                $id =~ s/[\s|,]+/,/g;
                @session_id = split(/,/, $id);
                $session_id_placeholder = ',?' x $#session_id;
            }

            my $search_query = sprintf("l.session_id IN(?%s)", $session_id_placeholder);
            my $sql          = sprintf("SELECT l.session_id, l.ad_id, m.owid, ad.ad_name, ad.agent_name
 FROM JKZ_WAF.tMediaAccessLogF l
  LEFT JOIN JKZ_WAF.tMemberM m
   ON l.guid=m.guid
  LEFT JOIN JKZ_WAF.tMediaM ad
   ON l.ad_id=ad.ad_id
 WHERE %s;", $search_query);

            my $dbh    = $self->getDBConnection();
            my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, @session_id);

            $obj->{LoopIdentifiedUserList} = $#{$aryref};

            if (0 > $obj->{LoopIdentifiedUserList}) {
                $obj->{IfSearchResultNotExists} = 1;
            }
            else {
                $obj->{IfSearchResultExists} = 1;
                map {
                    foreach my $key (keys %{ $aryref }) {
                        $obj->{$key}->[$_]     = $aryref->[$_]->{$key};
                        $obj->{cssstyle}->[$_] = ( 0 == $_ % 2 ) ? 'focusodd' : 'focuseven';
                    }
                } 0 .. $obj->{LoopIdentifiedUserList};
            }



$obj->{DUMP} = $sql;
$obj->{DUMP} .= '<hr />' . Dumper(\@session_id);

        }



        $obj->{IfSearchExecuted} = 1;
    }

    return $obj;
}




#******************************************************
# @access    public
# @desc        外部リンクバナーの登録新規
# @param
# @return    
#******************************************************
sub registLinkBanner {
    my $self = shift;

    my $q = $self->query();
    $q->autoEscape(0);
    my $obj = {};

    defined($q->param('md5key')) ? $obj->{IfConfirmLinkBanner} = 1 : $obj->{IfRegistLinkBanner} = 1;

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    if ($obj->{IfConfirmLinkBanner}) {
        $obj->{acd}            = $q->param('acd');
        $obj->{status_flag}    = $q->param('status_flag');
        $obj->{years}        = $q->param('years');
        $obj->{months}        = $q->param('months');
        $obj->{dates}        = $q->param('dates');
        $obj->{toyears}        = $q->param('toyears');
        $obj->{tomonths}    = $q->param('tomonths');
        $obj->{todates}        = $q->param('todates');
        $obj->{valid_date}    = sprintf("%s-%02d-%02d",$obj->{years}, $obj->{months}, $obj->{dates});
        $obj->{expire_date}    = sprintf("%s-%02d-%02d",$obj->{toyears}, $obj->{tomonths}, $obj->{todates});
        $obj->{client_name}    = $q->param('client_name');
        $obj->{comment}        = $q->param('comment');

        ($obj->{tmplt_id}, $obj->{DecodedSummary}) = split(/;/, $q->param('tmplt_id'));
        $obj->{DecodedSummary}            = $q->unescape($obj->{DecodedSummary});

        $obj->{access_url}    = sprintf("%s/?t=%s", $self->CONFIGURATION_VALUE("MAIN_URL"), $obj->{tmplt_id});


        my $publish = sprintf("%s/%s", $self->publishdir(), $q->param('md5key'));
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

        $obj->{ERROR_MSG} .= '<li>広告コードが入力されてません</li>' if "" eq $obj->{acd};
        $obj->{ERROR_MSG} .= '<li>開始日と終了日の整合性がとれてないです</li>' if $obj->{years} > $obj->{toyears};
        $obj->{ERROR_MSG} .= '<li>アクセス先URLが有効なURLではありません</li>' if !MyClass::WebUtil::checkURL($q->param('access_url'));

    }
    elsif ($obj->{IfRegistLinkBanner}) {
        my $pulldown = $self->createPeriodPullDown({year=>"years", month=>"months", date=>"dates", range=>"0,3"});
        map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
        $pulldown = $self->createPeriodPullDown({year=>"toyears", month=>"tomonths", date=>"todates", range=>"0,3"});
        map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};

        #*********************************
        # テンプレートリストを取得
        #*********************************
        my $tmpltobj = $self->fetchTmplt();
        ## Modified テンプレートのデータをキャッシュ化 2009/03/11 END
        $obj->{LoopTmpltMasterList} = $#{$tmpltobj->{tmplt_id}};
        if (0 <= $obj->{LoopTmpltMasterList}) {
        no strict('refs');
            for (my $i = 0; $i <= $obj->{LoopTmpltMasterList}; $i++) {
                map { $obj->{$_}->[$i] = $tmpltobj->{$_}->[$i] } qw(tmplt_id summary);
                $obj->{EncodedSummary}->[$i] = $q->escape($obj->{summary}->[$i]);
                ## 商品マスタのtmplt_idとテンプレートリストデータのtmplt_idが一致したら選択フラグを立てる
                $obj->{IfSelectedMasterID}->[$i] = 1 if $obj->{tmplt_id}->[$i] == $obj->{tmplt_id};
            }
        }
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        リンクバナーの詳細
# @param
# @return    
#******************************************************
sub detailLinkBanner {
    my $self = shift;

    my $q = $self->query();

    my $obj = {};

    defined($q->param('md5key')) ? $obj->{IfConfirmLinkBanner} = 1 : $obj->{IfModifyLinkBanner} = 1;

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);

    if ($obj->{IfConfirmLinkBanner}) {
        $obj->{id}            = $q->param('id');
        $obj->{acd}            = $q->param('acd');
        $obj->{status_flag}    = $q->param('status_flag');
        $obj->{years}        = $q->param('years');
        $obj->{months}        = $q->param('months');
        $obj->{dates}        = $q->param('dates');
        $obj->{toyears}        = $q->param('toyears');
        $obj->{tomonths}    = $q->param('tomonths');
        $obj->{todates}        = $q->param('todates');
        $obj->{valid_date}    = sprintf("%s-%02d-%02d",$obj->{years}, $obj->{months}, $obj->{dates});
        $obj->{expire_date}    = sprintf("%s-%02d-%02d",$obj->{toyears}, $obj->{tomonths}, $obj->{todates});
        $obj->{client_name}    = $q->param('client_name');
        $obj->{access_url}    = $q->param('access_url');
        $obj->{comment}        = $q->param('comment');

        my $publish = sprintf("%s/%s", $self->publishdir(), $q->param('md5key'));
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

        $obj->{ERROR_MSG} .= '<li>広告コードが入力されてません</li>' if "" eq $obj->{acd};
        $obj->{ERROR_MSG} .= '<li>開始日と終了日の整合性がとれてないです</li>' if $obj->{years} > $obj->{toyears};
        $obj->{ERROR_MSG} .= '<li>アクセス先URLが有効なURLではありません</li>' if !MyClass::WebUtil::checkURL($q->param('access_url'));

    }
    elsif ($obj->{IfModifyLinkBanner}) {
        my $acd = $q->param('acd');
        my $dbh = $self->getDBConnection();
        $self->setDBCharset("sjis");

        my $cmsLinkBanner = MyClass::JKZDB::Adv->new($dbh);

        if (!$cmsLinkBanner->executeSelect({whereSQL => "acd=?", placeholder => [$acd]})) {
            $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG12');
        } else {
            map { $obj->{$_} = $cmsLinkBanner->{columns}->{$_} } keys %{$cmsLinkBanner->{columns}};

            my $pulldown = $self->createPeriodPullDown({year=>"years", month=>"months", date=>"dates", range=>"0,3", defaultvalue=>$obj->{valid_date}});
            map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
            $pulldown = $self->createPeriodPullDown({year=>"toyears", month=>"tomonths", date=>"todates", range=>"0,3", defaultvalue=>$obj->{expire_date}});
            map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};

        }
        undef($cmsLinkBanner);
    }

        2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive}   = 1 :
        1 == $obj->{status_flag} ? $obj->{IfStatusFlagIsNotActive}= 1 :
                                   $obj->{IfStatusFlagIsPeriod}   = 1;

    return $obj;
}


#******************************************************
# @access    public
# @desc        データ登録・更新実行
# @param
# @return    
#******************************************************
sub modifyLinkBanner {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    if (!$q->MethPost()) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG18");
    }

    my $updateData = {
        id          => undef,
        acd         => undef,
        status_flag => undef,
        carrier     => undef,
        valid_date  => undef,
        expire_date => undef,
        access_url  => undef,
        client_name => undef,
        comment     => undef,
    };

    my $publish = sprintf("%s/%s", $self->publishdir(), $q->param('md5key'));
    eval {
        my $publishobj = MyClass::WebUtil::publishObj( { file=>$publish } );
        map { exists($updateData->{$_}) ? $updateData->{$_} = $publishobj->{$_} : "" } keys %{ $publishobj };
    };
    ## パブリッシュオブジェクトの取得失敗の場合
    if ($@) {
        
    } else {

        ## 暫定処理 primary keyをacdにしたため新規登録とデータの編集の区別をsubmitボタンの名前でする
        my $flag = defined($q->param('registLinkBanner')) ? -1 : 1;

        my $dbh = $self->getDBConnection();
        $self->setDBCharset("sjis");
        my $cmsAdv = MyClass::JKZDB::Adv->new($dbh);

        if ('0E0' eq $cmsAdv->executeUpdate($updateData, $flag)) {
            $obj->{ERROR_MSG} = '<li>' . $self->ERROR_MSG("ERR_MSG99") . '</li>';
            ## シリアライズオブジェクトの破棄
            MyClass::WebUtil::clearObj($publish);

            return $obj;
        }
        ## シリアライズオブジェクトの破棄
        MyClass::WebUtil::clearObj($publish);
        undef($cmsAdv);
    }

    $self->_publishAffiliateLinkBannerDATA();

    $self->action('viewLinkBannerList');
    return $self->viewLinkBannerList();
}


#******************************************************
# @access    public
# @desc      登録済み外部リンクバナーの一覧表示
# @param
# @return    
#******************************************************
sub viewLinkBannerList {
    my $self = shift;

    my $obj = {};

    my $dbh = $self->getDBConnection();

    my  $sql = "SELECT a.acd, a.status_flag, a.access_url, a.valid_date, a.expire_date, a.client_name, al.ACNT, ur.RCNT
 FROM tAdvM a
  LEFT JOIN (
   SELECT acd, COUNT(acd) AS ACNT
    FROM tAffiliateAccessLogF GROUP BY acd
  ) AS al ON (a.acd=al.acd)
   LEFT JOIN (
    SELECT acd, COUNT(acd) RCNT
     FROM tUserRegistLogF GROUP BY acd
  ) AS ur ON (a.acd=ur.acd)
  ORDER BY a.acd
";

    my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} });

    $obj->{LoopLinkBannerList} = $#{$aryref};
    if (0 > $obj->{LoopLinkBannerList}) {
        $obj->{IfNotExistsLinkBannerList} = 1;
    }
    else {
        $obj->{IfExistsLinkBannerList} = 1;
        for (my $i = 0; $i <= $obj->{LoopLinkBannerList}; $i++) {
            map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{$aryref};

            ## status_flagを画像に変換
            $obj->{status_flagImages}->[$i]        = $self->fetchOneValueFromConf('STATUSIMAGES', (log($obj->{status_flag}->[$i]) / log(2)));
            ## 日付のセパレータを変更
            $obj->{valid_date}->[$i]  = MyClass::WebUtil::formatDateTimeSeparator($obj->{valid_date}->[$i], {sepfrom =>'-', septo=>'/'});
            $obj->{expire_date}->[$i] = MyClass::WebUtil::formatDateTimeSeparator($obj->{expire_date}->[$i], {sepfrom =>'-', septo=>'/'});

            my @IfStatus_flag = ('IfInvalid', 'IfValid',);
            $obj->{$IfStatus_flag[$obj->{status_flag}->[$i] - 1]}->[$i] = 1;
        }
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        広告の状態更新
# @param    char    $acd
# @return    
#******************************************************
sub updateStatus {
    my $self = shift;
    my $q = $self->query();

    my $param = $q->param('adv') || undef;

    if ($q->param('acd')) {
        my $acd = $q->param('acd');
        my $dbh = $self->getDBConnection();
    ## Modified アフィリエイトのときと通常のリンクバナーの処理を同じメソッド実行のため 2009/09/10
        my $class = ( defined ($param) ) ? MyClass::JKZDB::Adv->new($dbh) : MyClass::JKZDB::Affiliate->new($dbh);
        $class->reverseupdateStatus($acd);
    }

    defined $param ? $self->action('viewLinkBannerList') : $self->action('viewAffiliateList');
    return ( defined ($param) ? $self->viewLinkBannerList() : $self->viewAffiliateList() );

}


#******************************************************
# @access    private
# @desc        アフィリエイト及びバナーデータ登録・更新時にデータをpublishする。
#            このデータは管理画面の他の機能で使用
# @param    
# @param    
# @return    
#******************************************************
sub _publishAffiliateLinkBannerDATA {
    my $self = shift;

    my $sql = "(SELECT acd, client_name FROM JKZ_WAF.tAffiliateM) UNION (SELECT acd, client_name FROM JKZ_WAF.tAdvM);";
    my $dbh = $self->getDBConnection();
    $self->setDBCharset('SJIS');
    my $aryref = $dbh->selectall_arrayref($sql);

    return if !defined($aryref);

    my $obj;
    foreach (@{$aryref}) {
        $obj->{$_->[0]} = $_->[1];
    }

    my $publish = sprintf("%s/AffiliateLinkBanner.obj", $self->publishdir());
    MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

    return 1;
}


1;

__END__