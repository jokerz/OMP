#******************************************************
# @desc		ローテーションバナープラグイン
# @package	MyClass::Plugin::RTBanner
# @author	Iwahase Ryo
# @create	2010/09/03
# @update	2010/
# @version	1.00
#******************************************************
package MyClass::Plugin::RTBanner;

use strict;
use warnings;
no warnings 'redefine';
use base 'MyClass::Plugin';

use MyClass::WebUtil;
use MyClass::JKZSession;
use MyClass::JKZDB::BannerClick;
use MyClass::JKZDB::BannerCount;
use MyClass::JKZDB::Member;
use MyClass::JKZDB::PointLog;


#******************************************************
# @desc     ローテーションバナーのフック 処理実行
# @param    
# @param    
# @return   
#******************************************************
sub fetch_banner :Hook('HOOK.ROTATIONBANNER') {
    my ($self, $c, $args) = @_;
    # バナーのベース置き換え文字
    my $bannerstr  = 'ROTATEBANNER';
    my $return_obj = {};
    my $name_space = $c->waf_name_space();
    my $dbh        = $c->getDBConnection();
    $c->setDBCharset('SJIS');

    # 有効なバナーデータを取得
    # SELECT id, bannerm_id FROM tBannerDataM WHERE (DATE(valid_date) <= CURDATE() AND DATE(expire_date) >= CURDATE()) AND status_flag=2
    my $sql1 = sprintf("SELECT id, bannerm_id FROM %s.tBannerDataM WHERE (DATE(valid_date) <= CURDATE() AND DATE(expire_date) >= CURDATE()) AND status_flag=2", $name_space);
    my $sql2 = sprintf("SELECT id, bannerm_id, bannerdatam_id, banner_url, banner_text, image_flag FROM %s.tBannerDataF WHERE 
 bannerm_id=? AND bannerdatam_id=?
 AND status_flag=2
 AND carrier & ?
 AND sex & ?
 AND personality & ?
 AND bloodtype & ?
 AND occupation & ?
 AND prefecture & ?;", $name_space);


    my $aryref = $dbh->selectall_arrayref($sql1);
    foreach my $ref (@{ $aryref }) {
        ## バナーの詳細データ取得
        my $rowref = $dbh->selectall_arrayref($sql2, { Columns => {} },
            $ref->[1],
            $ref->[0],
            $c->attrAccessUserData("carrier"),
            $c->attrAccessUserData("sex"),
            $c->attrAccessUserData("personality"),
            $c->attrAccessUserData("bloodtype"),
            $c->attrAccessUserData("occupation"),
            $c->attrAccessUserData("prefecture")
        );

        ## 該当データが場合はreturnで終了

        if (!$rowref || 1 > @{ $rowref }) {
            next;
        }

        my $rows = @{ $rowref };
        my $rand = int(rand($rows));
        my $param = sprintf("rt=%s::%s::%s", $rowref->[$rand]->{bannerm_id}, $rowref->[$rand]->{bannerdatam_id}, $rowref->[$rand]->{id});

        #******************************
        # 3.バナーの置換ﾀｸﾞを生成
        #
        # %&ROTATEBANNER12&% ROTATEBANNER13 ROTATEBANNER22 みたいな感じ
        #******************************
        
        my $repstr = sprintf("%s%s%s", $bannerstr . $ref->[1], $ref->[0]);
        $return_obj->{$repstr} = ( 2 == $rowref->[$rand]->{image_flag} ) 
        ? 
        sprintf("<a href=\"%sa=toBannerURL&%s\"><img src=\"%s?%s&b=1\" /></a>", $c->MEMBERMAINURL(), $param, $c->CONFIGURATION_VALUE('IMAGE_BANNER_SCRIPT_NAME'), $param)
        :
        sprintf("<a href=\"%sa=toBannerURL&%s\">%s</a>", $c->MEMBERMAINURL(), $param, $rowref->[$rand]->{banner_text} )
        ;
        #sprintf("<a href=\"%sa=toBannerURL&%s\"><img src=\"%s?id=%s%s%s&b=1\" /></a>", $c->MEMBERMAINURL(), $param, $c->CONFIGURATION_VALUE('IMAGE_BANNER_SCRIPT_NAME'), $rowref->[$rand]->{bannerm_id}, $rowref->[$rand]->{bannerdatam_id}, $rowref->[$rand]->{id})
        
    }

    $return_obj->{'If.HOOK.ROTATIONBANNER'} = 1;

    return $return_obj;
}


#******************************************************
# @access   
# @desc     必要なのはbannerm_id bannerdatam_id bannerdataf_id
# @param    
# @param    
# @return   
#******************************************************
sub toBannerURL :Method {
    my ($self, $c, $args) = @_;

   ## パラメータrtを::で分解
    my ($bannerm_id, $bannerdatam_id, $bannerdataf_id) = split(/::/, $c->query->param('rt'));

    my $owid       = $c->attrAccessUserData("owid");
    my $guid       = $c->user_guid();
    my $name_space = $c->waf_name_space();
    my $member_name_space = $c->waf_name_space() . 'memberdata';
    my $sql;
    my $dbh        = $c->getDBConnection();
    $c->setDBCharset('SJIS');

#************************************
# バナー情報チェック 期限・ポイント・ポイント上限・リンク先
#************************************
    $sql = sprintf("SELECT m.point_flag, m.point, m.point_limit, f.banner_url
 FROM %s.tBannerDataM m
 LEFT JOIN %s.tBannerDataF f
  ON (m.bannerm_id=f.bannerm_id AND m.id=f.bannerdatam_id)
 WHERE f.bannerm_id=? AND f.bannerdatam_id=? AND f.id=?;", $name_space, $name_space);

    my ($point_flag, $point, $point_limit, $banner_url) = $dbh->selectrow_array($sql, undef, $bannerm_id, $bannerdatam_id, $bannerdataf_id);

#************************************
# ﾎﾟｲﾝﾄ付与バナーの場合
#************************************
    if (2 == $point_flag) {
       ## 共通データ
        my $today           = MyClass::WebUtil::GetTime("1");
        my $bannerclickdata = {
            owid           => $owid,
            bannerm_id     => $bannerm_id,
            bannerdatam_id => $bannerdatam_id,
            point_click    => $today,
#            click          => 1,      この値はupdateの場合click+1となる
        };

        my $bannercountdata = {
            bannerm_id     => $bannerm_id,
            bannerdatam_id => $bannerdatam_id,
            bannerdataf_id => $bannerdataf_id,
            clickdate     => $today,
            click          => 1,
        };

    #************************************
    # ﾎﾟｲﾝﾄ付与状態をチェック
    #************************************
        my $tBannerClickF = sprintf("%s.tBannerClickF_%s", $name_space, MyClass::WebUtil::GetTime("5"));
=pod
        $sql = sprintf("SELECT click FROM %s
 WHERE owid=? AND (bannerm_id=? AND bannerdatam_id=?) AND point_click=CURDATE()
 HAVING click >= ?;", $tBannerClickF);
=cut
    #*************************
    # ポイント付与回数からクリック数を引き算して値が0以上のときはまだポイント付与OK
    # 値がpoint_limitと同じ場合はtBannerClickF_yyyymmに INSERT
    # それ以外はtBannerClickF_yyyymm を                 UPDATE
    # 値が0以上でpoint_limit以下の場合はpoint付与    tPointLogFに INSERT
    #                                                tMemberMを   UPDATE
    #
        $sql = sprintf("SELECT (%d - click) FROM %s WHERE owid=? AND (bannerm_id=? AND bannerdatam_id=?) AND point_click=CURDATE();", $point_limit, $tBannerClickF);
        my $rv = $dbh->selectrow_array($sql, undef, $owid, $bannerm_id, $bannerdatam_id);

        my $myBannerClick = MyClass::JKZDB::BannerClick->new($dbh);
        my $myBannerCount = MyClass::JKZDB::BannerCount->new($dbh);
        $myBannerClick->switchMRG_MyISAMTableSQL( { separater => '_', value => MyClass::WebUtil::GetTime("5") } );
        $myBannerCount->switchMRG_MyISAMTableSQL( { separater => '_', value => MyClass::WebUtil::GetTime("5") } );

        #***************************
        # バナーカウント
        #***************************
        $myBannerCount->executeUpdate($bannercountdata, -1);


     #**********************************
     # point_limit - clickが０< (point_limit - click) >= point_limitの場合はポイント処理
     #**********************************
        if ( 0 < $rv && $rv <= $point_limit ) {
            my $myMember      = MyClass::JKZDB::Member->new($dbh);
            my $myPointLog    = MyClass::JKZDB::PointLog->new($dbh);
            my $attr_ref      = MyClass::UsrWebDB::TransactInit($dbh);

            eval {
               #***************************
               # (point_limit - click)がpoint_limitと同じ場合は最初のクリックとなる
               #***************************
                if ($rv == $point_limit) {
                    $bannerclickdata->{point_click} = $today;
                    $bannerclickdata->{click}       = 1;
                    $myBannerClick->executeUpdate($bannerclickdata, -1);
                }
                else {
                    $myBannerClick->updateClick($bannerclickdata);
                }

               #***************************
               # 会員ポイント付与
               #***************************
                $myMember->updatePointSQL({
                            owid     => $owid,
                            point    => $point,
                            operator => '+',
                 });

               #***************************
               # ポイントログ
               #***************************
               my $id_of_type = sprintf("%s::%s::%s", $bannerm_id, $bannerdatam_id, $bannerdataf_id);
                $myPointLog->executeUpdate({
                            id            => -1,
                            owid          => $owid,
                            guid          => $guid,
                            type_of_point => 64,
                            id_of_type    => $id_of_type,
                            point         => $point,
                });

                $dbh->commit();
            };

            if ($@) {
                $dbh->rollback();
            }

            MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
            $c->deleteFromCache("$member_name_space:$guid");
            ## session情報をクリアして、最新情報を取得する
            my $sess_ref = MyClass::JKZSession->open($guid);
            $sess_ref->clear_session() if defined $sess_ref;
        }
        else {
            #***************************
            # ポイントクリック
            #***************************
            $myBannerClick->updateClick($bannerclickdata);

            #***************************
            # バナーカウント
            #***************************
            #$myBannerCount->executeUpdate($bannercountdata, -1);
        }

=pod
     #************************************
     # 当日はまだポイントの取得がない→ポイント処理開始
     #************************************
        if (0 == $rv || !defined($rv)) {
            my $myMember      = MyClass::JKZDB::Member->new($dbh);
            my $myPointLog    = MyClass::JKZDB::PointLog->new($dbh);
            my $attr_ref      = MyClass::UsrWebDB::TransactInit($dbh);

            eval {
               #***************************
               # ポイントクリック
               #***************************
                $bannerclickdata->{point_click} = $today;
                $bannerclickdata->{click}       = 1;
                $myBannerClick->executeUpdate($bannerclickdata, -1);

               #***************************
               # バナーカウント
               #***************************
               #$myBannerCount->executeUpdate($bannercountdata, -1);

               #***************************
               # 会員ポイント付与
               #***************************
                $myMember->updatePointSQL({
                            owid     => $owid,
                            point    => $point,
                            operator => '+',
                 });

               #***************************
               # ポイントログ
               #***************************
               my $id_of_type = sprintf("%s::%s::%s", $bannerm_id, $bannerdatam_id, $bannerdataf_id);
                $myPointLog->executeUpdate({
                            id            => -1,
                            owid          => $owid,
                            guid          => $guid,
                            type_of_point => 64,
                            id_of_type    => $id_of_type,
                            point         => $point,
                });

                $dbh->commit();
            };

            if ($@) {
                $dbh->rollback();
            }

            MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
            $c->deleteFromCache("$member_name_space:$guid");
            ## session情報をクリアして、最新情報を取得する
            my $sess_ref = MyClass::JKZSession->open($guid);
            $sess_ref->clear_session() if defined $sess_ref;
        }
        else {
            #***************************
            # ポイントクリック
            #***************************
            $myBannerClick->updateClick($bannerclickdata);

            #***************************
            # バナーカウント
            #***************************
            #$myBannerCount->executeUpdate($bannercountdata, -1);
        }
=cut
    }

    ## バナー先にリダイレクト
    return print "Location: $banner_url\n\n";

}


sub class_component_plugin_attribute_detect_cache_enable { 0 }

1;