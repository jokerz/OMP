#******************************************************
# @desc        集計クラス「管理」
#             会員・アクセス・PV・
#            
# @package    MyClass::JKZApp::AppShukei
# @access    public
# @author    Iwahase Ryo
# @create    2009/4/2
# @version    1.00
#******************************************************
package MyClass::JKZApp::AppShukei;

use 5.008005;
our $VERSION = '1.00';
use strict;

use base qw(MyClass::JKZApp);

use MyClass::WebUtil;
#use MyClass::DataReportUtil;

#use MyClass::JKZDB::Affiliate;
#use MyClass::JKZDB::QuestionnarieAnswerData;

use Data::Dumper();

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
# @desc        親クラスのgetActionをオーバーライド。ここはサブクラスごとに設定
# @param    
#******************************************************
sub getAction {
    my $self = shift;

    return ("" eq $self->action() ? 'shukeiTopMenu' : $self->action());
}


#******************************************************
# @access    public
# @desc        親クラスのメソッド
# @param    
#******************************************************
sub dispatch {
    my $self = shift;
    $self->query->autoEscape(0);

    $self->SUPER::dispatch();
}


#******************************************************
# @access    public
# @desc        この管理画面ﾄｯﾌﾟメニュー
#******************************************************
sub shukeiTopMenu {
    my $self = shift;

    return;
}


#******************************************************
# @access    public
# @desc        コンテンツのダウンロード数
# @desc        月毎のコンテンツダウンロード数を集計
#            コンテンツ名・サブカテゴリ・ダウンロード数
# @param    %4d%02d (YYYYmm)
#******************************************************
sub shukeiDLContentsByMonth {
    my $self = shift;
    my $q    = $self->query;
    my $obj  = {};

    $obj->{action} = $self->{action};

    #*********************************
    # 年月pulldown生成
    #*********************************
    my $pulldown = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"-1,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{ $pulldown };

    if (defined ($q->param('year'))) {
        my ($sYear, $sMonth, $orderby);
        $sYear   = $q->param('year');
        $sMonth  = $q->param('month');
        $orderby = (1 == $q->param('orderby')) ? 'DESC' : 'ASC';

        #*********************************
        # 対象年月生成
        #*********************************
        my $targetPeriod    = sprintf("%04d-%02s-01", $sYear, $sMonth);
        my $targetYearMonth = sprintf("%4d%02d", $sYear, $sMonth);

        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');
        $self->setDBCharset("sjis");

        my $sql = "SELECT d.product_id, SUM(d.counter) AS DL, p.product_name, log(2, p.categorym_id) AS categorym_id, p.subcategorym_id
 FROM tDownloadCounterF d, tProductM p
 WHERE d.product_id=p.product_id AND
 DATE_FORMAT(d.download_date, '%Y%m') = ?
 GROUP BY d.product_id
 ORDER BY DL $orderby;
";

        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $targetYearMonth);

        $obj->{LoopDLList} = $#{$aryref};
        if (1 > $obj->{LoopDLList}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        }
        else {
            ## サブカテゴリ名の取得
            my $objdata = $self->getSubCategoryOBJ();

            for (my $i = 0; $i <= $obj->{LoopDLList}; $i++) {
                map  { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                $obj->{category_name}->[$i]    = $objdata->[$obj->{categorym_id}->[$i]]->[$obj->{subcategorym_id}->[$i]]->{category_name};
                $obj->{subcategory_name}->[$i] = $objdata->[$obj->{categorym_id}->[$i]]->[$obj->{subcategorym_id}->[$i]]->{subcategory_name};
                $obj->{cssstyle}->[$i]         = 0 == $i % 2 ? 'focusodd' : 'focuseven';
            }

            $obj->{IfData} = 1;
        }
        $obj->{sYEAR}  = $sYear;
        $obj->{sMONTH} = $sMonth;
        $obj->{pMONTH} = $sMonth-1;
        $obj->{nMONTH} = $sMonth+1;
        $obj->{IfToPreviousMonth} = 1 < $sMonth  ? 1 : 0;
        $obj->{IfToNextMonth}     = 12 > $sMonth ? 1 : 0;

        $obj->{IfAction} = 1;
    }

    return($obj);
}


#******************************************************
# @access    public
# @desc      ポイント広告の登録状態 成果発生したものだけ
# @return    
#******************************************************
sub shukeiMediaClick {
    my $self = shift;
    my $q = $self->query;

    my $obj = {};

    return $obj if !$q->param('submit');

    $obj = {
        fsyear  => $q->param('fsyear'),
        fsmonth => $q->param('fsmonth'),
        fsdate  => $q->param('fsdate'),
        feyear  => $q->param('feyear'),
        femonth => $q->param('femonth'),
        fedate  => $q->param('fedate'),
    };

    $obj->{IfAction} = 1;
    my @wherecondition;
    my @whereplaceholder;
    my @searchquerymessage;

    if ($q->param('fsyear')) {
        my $fsyymmdd = sprintf("%02d%02d%02d", $q->param('fsyear'), $q->param('fsmonth'), $q->param('fsdate'));
        (
            push(@wherecondition, "ml.in_date >= ?")
            && 
            push(@whereplaceholder, $fsyymmdd)
        );
        push @searchquerymessage, "集計日時下限：[ $fsyymmdd ]";
    } else {
        push @searchquerymessage, "集計日時下限：[ 指定なし ]";
    }

    if ($q->param('feyear')) {
        my $feyymmdd = sprintf("%02d%02d%02d", $q->param('feyear'), $q->param('femonth'), $q->param('fedate'));
        (
            push(@wherecondition, "ml.in_date <= ?")
            &&
            push(@whereplaceholder, $feyymmdd)
        );
        push @searchquerymessage, "集計日時上限：[ $feyymmdd ]";
    } else {
        push @searchquerymessage, "集計日時上限：[ 指定なし ]";
    }

    $obj->{SEARCHQUERYMESSAGE} = join('　', @searchquerymessage);

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
 SUM(IF(ml.status_flag=2, ml.ad_point, 0)) AS ADPOINTTOTAL,
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
 WHERE m.ad_id IN (SELECT DISTINCT(ad_id) FROM tMediaAccessLogF)
";

    $sql .= ( 0 < @wherecondition ) ? sprintf(" AND %s GROUP BY ml.ad_id;", join(' AND ', @wherecondition )) : " GROUP BY ml.ad_id;";


    my $dbh = $self->getDBConnection();
    my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, @whereplaceholder);

   $obj->{LoopMediatList} = $#{$aryref};
    map {
        foreach my $key (keys %{ $aryref }) {
            $obj->{$key}->[$_] = $aryref->[$_]->{$key};
        }
        $obj->{cssstyle}->[$_] = 0 != $_ % 2 ? 'focuseven' : 'focusodd';
    } 0..$obj->{LoopMediatList};

    return $obj;

}





#******************************************************
# @access    public
# @desc        月次アクセス数・会員登録数を出す
#            step1-ste3
#            step1.対象月の日・曜日の生成して一時テーブルに格納
#            step2.対象月の日・曜日を元にアクセスログテーブルと会員テーブルから情報を取得
#            step3.一時テーブルの削除
# @return    
#******************************************************
sub shukeiByMonth {
    my $self = shift;
    my $q = $self->query;

    my $obj = {};
    $obj->{action} = $self->{action};

    #*********************************
    # 年月pulldown生成
    #*********************************
    $obj->{action} = $self->{action};

    my $pulldown = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"-1,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{ $pulldown };

    if (defined ($q->param('year'))) {
        my ($sYear, $sMonth);
        $sYear  = $q->param('year');
        $sMonth = $q->param('month');

        ## ここで初期化
        my $aryref;
        ## 新規にグラフを生成するかの判定フラグ
        my $flagnew = 0;
#*********************************
# シリアライズデータ機能追加2009/07/28 BEGIN
#*********************************

        ## パブリッシュディレクトリ
        my $publishdir = sprintf("%s/admin/%s", $self->CONFIGURATION_VALUE("SERIALIZEDOJB_DIR"), $self->_myMethodName());
        if (! -d $publishdir) {
            MyClass::WebUtil::createDir($publishdir);
        }
        ## パブリッシュファイルの名前
        my $publish_filename = sprintf("%4d%02d", $sYear, $sMonth);
        my $publishobj = sprintf("%s/%s.obj", $publishdir, $publish_filename);
        ## グラフのパス
        my $graphimage_path = $self->CONFIGURATION_VALUE("GRAPTHIMAGE_DIR");
        my $graphimage_name = sprintf("%s_%s.png", $self->_myMethodName(), $publish_filename);

#*********************************
# シリアライズデータ使用の場合
#*********************************
        ## パブリッシュされた最終時間を取得する
        if (-e $publishobj) {
            my ($lsize, $ltime) = stat($publishobj) ? (stat(_))[7, 9] : (0, 0);
            require POSIX;
            POSIX->import(qw(strftime)); 

            my $yyyymm = strftime("%Y%m", localtime($ltime));
            if ($publish_filename < $yyyymm) {
                eval {
                    $aryref = MyClass::WebUtil::publishObj( { file=>$publishobj } );
                };
                ## オブジェクト取得失敗の場合
                if ($@) {
                    goto DOSQLACCESS;
                }
            }
            else {
                goto DOSQLACCESS;
            }
        }
        else {
#*********************************
# DBアクセスSQL発行の場合
#*********************************
DOSQLACCESS:
            #*********************************
            # 対象月の日・曜日の生成
            #*********************************
            my $targetPeriod        = sprintf("%04d-%02s-01", $sYear, $sMonth);
            my $tAccessLogF_MONTH    = 'tAccessLogF_' . sprintf("%4d%02d", $sYear, $sMonth);
            my $tPageViewLogF_MONTH = 'tPageViewLogF_' . sprintf("%4d%02d", $sYear, $sMonth);

            my $dbh = $self->getDBConnection();
            $dbh->do('USE JKZ_WAF');
            #*********************************
            # 対象月の日・曜日の格納一時テーブル生成
            #*********************************

            my $sql;
            #***************************
            #  STEP1 一時テーブル作成
            #***************************
            $sql = sprintf("
CREATE TEMPORARY TABLE TMP_SHUKEIBYMONTH(DDATE DATE, DMON CHAR(2))
 SELECT
 DISTINCT(DATE(a.in_datetime)) AS DDATE, DAYOFMONTH(a.in_datetime) AS DMON
 FROM %s a
 ORDER BY DDATE;", $tAccessLogF_MONTH);

            ## SQL実行1
            $dbh->do($sql);

            #***************************
            # STEP2 ｱｸｾｽ数の一時データ
            #***************************
            $sql = sprintf("CREATE TEMPORARY TABLE TMPA (
SELECT DDATE, DMON,
 COUNT(IF(DDATE=DATE(a.in_datetime) AND a.carrier=2, a.id, NULL)) AS AD,
 COUNT(IF(DDATE=DATE(a.in_datetime) AND a.carrier=4, a.id, NULL)) AS ASB,
 COUNT(IF(DDATE=DATE(a.in_datetime) AND a.carrier=8,  a.id, NULL)) AS AAU,
 COUNT(IF(DDATE=DATE(a.in_datetime), a.id, NULL)) AS ATOTAL
 FROM TMP_SHUKEIBYMONTH, %s a GROUP BY DMON)", $tAccessLogF_MONTH);

            ## SQL実行2
            $dbh->do($sql);

            #***************************
            # STEP3 会員登録数の一時データ
            #***************************
            $sql = "CREATE TEMPORARY TABLE TMPB (
 SELECT DDATE, DMON,
 COUNT(IF(u.status_flag=2 AND u.carrier=2, u.id, NULL)) AS RD,
 COUNT(IF(u.status_flag=2 AND u.carrier=4, u.id, NULL)) AS RSB,
 COUNT(IF(u.status_flag=2 AND u.carrier=8, u.id, NULL)) AS RA,
 COUNT(IF(u.status_flag=2, u.id, NULL)) AS RTOTAL,
 COUNT(IF(u.status_flag=4 AND u.carrier=2, u.id, NULL)) AS WD,
 COUNT(IF(u.status_flag=4 AND u.carrier=4, u.id, NULL)) AS WSB,
 COUNT(IF(u.status_flag=4 AND u.carrier=8, u.id, NULL)) AS WA,
 COUNT(IF(u.status_flag=4, u.id, NULL)) AS WTOTAL
 FROM TMP_SHUKEIBYMONTH
  LEFT JOIN tUserRegistLogF u
   ON DDATE=DATE(u.date_of_transaction) GROUP BY DDATE
)";

                ## SQL実行3
                $dbh->do($sql);

            #***************************
            # STEP4 ページビューの一時データ
            #***************************
    ## Modified 2009/12/02
            $sql = sprintf("CREATE TEMPORARY TABLE TMPC (
SELECT DDATE, DMON,
 SUM(IF(DDATE=p.in_date AND carrier=2, p.pvcount, 0)) AS PVD,
 SUM(IF(DDATE=p.in_date AND carrier=4, p.pvcount, 0)) AS PVSB,
 SUM(IF(DDATE=p.in_date AND carrier=8, p.pvcount, 0)) AS PVAU,
 SUM(IF(DDATE=p.in_date, p.pvcount, 0)) AS PVTOTAL
 FROM TMP_SHUKEIBYMONTH, %s p
  GROUP BY DMON
)", $tPageViewLogF_MONTH);

                ## SQL実行4
                $dbh->do($sql);


            #***************************
            # STEP5 3つのテーブル合体 集計 TMPA TMPB TMPC
            #***************************
            $sql = "SELECT
 a.DDATE, a.DMON, a.AD, a.ASB, a.AAU, a.ATOTAL,
 b.RD, b.RSB, b.RA, b.RTOTAL, b.WD, b.WSB, b.WA, b.WTOTAL,
 c.PVD, c.PVSB, c.PVAU, c.PVTOTAL
 FROM TMPA a 
  LEFT JOIN TMPB b ON a.DMON=b.DMON
  LEFT JOIN TMPC c ON a.DMON=c.DMON
";

            ## SQL実行5
            $aryref = $dbh->selectall_arrayref($sql);

            #*********************************
            # 一時テーブルの削除
            #*********************************
            $sql = "DROP TABLE TMP_SHUKEIBYMONTH, TMPA, TMPB, TMPC";
            ## SQL実行5
            $dbh->do($sql);

## Modified 対象集計テーブル変更のため 2010/02/26 END

            #***************************
            # 集計データをシリアライズしてパブリッシュ
            #***************************
            MyClass::WebUtil::publishObj({ file=>$publishobj, obj=>$aryref });

            #***************************
            # ここのラベルへきたらグラフは新規生成
            #***************************
            $flagnew = 1;
        }

#*********************************
# シリアライズデータ機能追加2009/07/28 END
#*********************************

        #*********************************
        # 共通処理開始
        #*********************************
        $obj->{LoopMember} = $#{ $aryref };
        if (0 > $obj->{LoopMember}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {

            my $hashkey       = MyClass::WebUtil::createHash(rand(), 20);
            my $basesearchstr = sprintf("yyyymmdd=%s-%s-", $sYear, $sMonth);

            for (my $i = 0; $i <= $obj->{LoopMember}; $i++) {
                if (0 < $aryref->[$i]->[9]) {
                    $obj->{IfExistsRegsitData}->[$aryref->[$i]->[1]-1] = 1;
                    $obj->{RegParam}->[$aryref->[$i]->[1]-1]           = sprintf("yyyymmdd=%s", MyClass::WebUtil::encodeMD5($aryref->[$i]->[0] . ';status_flag=2', $hashkey));
                }
                if (0 < $aryref->[$i]->[10]) {
                    $obj->{IfExistsWithdrawData}->[$aryref->[$i]->[1]-1] = 1;
                    $obj->{WithdrawParam}->[$aryref->[$i]->[1]-1]        = MyClass::WebUtil::encodeMD5($basesearchstr . $aryref->[$i]->[0] . ';status_flag=1', $hashkey);
                }

            #### VER2 アクセス　登録　退会　PV
                    $obj->{AD}->[$aryref->[$i]->[1]-1]      = $aryref->[$i]->[2];
                    $obj->{ASB}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[3];
                    $obj->{AAU}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[4];
                    $obj->{ATOTAL}->[$aryref->[$i]->[1]-1]  = $aryref->[$i]->[5];
                    $obj->{RD}->[$aryref->[$i]->[1]-1]      = $aryref->[$i]->[6];
                    $obj->{RSB}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[7];
                    $obj->{RA}->[$aryref->[$i]->[1]-1]      = $aryref->[$i]->[8];
                    $obj->{RTOTAL}->[$aryref->[$i]->[1]-1]  = $aryref->[$i]->[9];
                    $obj->{WD}->[$aryref->[$i]->[1]-1]      = $aryref->[$i]->[10];
                    $obj->{WSB}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[11];
                    $obj->{WA}->[$aryref->[$i]->[1]-1]      = $aryref->[$i]->[12];
                    $obj->{WTOTAL}->[$aryref->[$i]->[1]-1]  = $aryref->[$i]->[13];
                    $obj->{PVD}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[14];
                    $obj->{PVSB}->[$aryref->[$i]->[1]-1]    = $aryref->[$i]->[15];
                    $obj->{PVAU}->[$aryref->[$i]->[1]-1]    = $aryref->[$i]->[16];
                    $obj->{PVTOTAL}->[$aryref->[$i]->[1]-1] = $aryref->[$i]->[17];

                    $obj->{YEAR}->[$aryref->[$i]->[1]-1]    = $sYear;
                    $obj->{RYO}->[$aryref->[$i]->[1]-1]     = $sMonth;

            ## ROLLUPが使用できないからここで合計値を出す
                    $obj->{TAD}     += $aryref->[$i]->[2];
                    $obj->{TASB}    += $aryref->[$i]->[3];
                    $obj->{TAA}     += $aryref->[$i]->[4];
                    $obj->{TATOTAL} += $aryref->[$i]->[5];
                    $obj->{TRD}     += $aryref->[$i]->[6];
                    $obj->{TRSB}    += $aryref->[$i]->[7];
                    $obj->{TRA}     += $aryref->[$i]->[8];
                    $obj->{TRT}     += $aryref->[$i]->[9];
                    $obj->{TWD}     += $aryref->[$i]->[10];
                    $obj->{TWSB}    += $aryref->[$i]->[11];
                    $obj->{TWA}     += $aryref->[$i]->[12];
                    $obj->{TWT}     += $aryref->[$i]->[13];
                    $obj->{TPVD}    += $aryref->[$i]->[14];
                    $obj->{TPVSB}   += $aryref->[$i]->[15];
                    $obj->{TPVA}    += $aryref->[$i]->[16];
                    $obj->{TPV}     += $aryref->[$i]->[17];
            }
            $obj->{IfData} = 1;

            $obj->{TASB}    = MyClass::WebUtil::insertComma($obj->{TASB});
            $obj->{TAA}     = MyClass::WebUtil::insertComma($obj->{TAA});
            $obj->{TATOTAL} = MyClass::WebUtil::insertComma($obj->{TATOTAL});
            $obj->{TPV}     = MyClass::WebUtil::insertComma($obj->{TPV});

            #*********************************
            # 対象月の日・曜日の生成 こちらに移動
            #*********************************
            my $calender = $self->createMonthTable($sYear, $sMonth);
            map { $obj->{$_} = $calender->{$_} } keys %{ $calender };

            #*********************************
            # グラフ生成 新規生成フラグが立ってれば もしくはまだグラフ画像が無い場合は新規生成
            #*********************************
=pod 2010/02/26 グラフは無し
            my $fullpath_to_graphimage = sprintf("%s/%s", $graphimage_path, $graphimage_name);
            if ($flagnew || ! -e $fullpath_to_graphimage) {
                my $title = MyClass::WebUtil::convertByNKF('-w', "$sMonth 月 アクセス/ページビュー");
                ## データを設定
                my @labels   = @{ $obj->{day} };
                my @auaccess = @{ $obj->{AAU} };
                my @sbaccess = @{ $obj->{ASB} };
                my @access   = @{ $obj->{ATOTAL} };
                my @pv       = @{ $obj->{PVTOTAL} };
                my @regtotal = @{ $obj->{RTOTAL} };
                my @data     = (\@labels, \@pv, \@access, \@auaccess , \@sbaccess, \@regtotal);

                ## 日本語はutf8に変換
                my @legend    = (
                    MyClass::WebUtil::convertByNKF('-w', 'ページビュー'),
                    MyClass::WebUtil::convertByNKF('-w', 'アクセス'),
                    MyClass::WebUtil::convertByNKF('-w', 'EzWebアクセス'),
                    MyClass::WebUtil::convertByNKF('-w', 'SoftBankアクセス'),
                    MyClass::WebUtil::convertByNKF('-w', '会員登録'),
                );

                my @types   = qw(area area bars bars lines);
                my @dclrs   = qw(LightBlue AliceBlue LightSalmon1 BlueViolet DeepPink);
                my @markers = qw(5);

                if ( !MyClass::DataReportUtil::createGraph({
                        graphsize  => {
                            width  => 760,
                            height => 480,
                        },
                        data       => [\@data],
                        legend     => \@legend,
                        graph_set  => {
                            title           => $title,
                            t_margin         => 10,
                            b_margin         => 10,
                            l_margin         => 0,
                            r_margin         => 0,
                            x_label          => MyClass::WebUtil::convertByNKF('-w', '日付'),
                            x_label_position => 0, 
                            y_label          => MyClass::WebUtil::convertByNKF('-w', 'アクセス/ページ カウント'),
                            y_label_position => 0.5, 
                            y_max_value      => 1000,
                            show_values      => 1,
                            values_forma     => '%d',
                            types            => [\@types],
                            dclrs            => [\@dclrs],
                            axislabelclr     => 'black',
                            borderclrs       => 'black',
                            bgclr            => 'white',
                            boxclr           => 'LightGrey',
                            fgclr            => 'black',
                            boxclr           => 'LightGrey',
                            accentclr        => 'LightSlateGray',
                            shadowclr        => 'DarkSlateGrey',
                            y_tick_number    => 10,
                            y_label_skip     => 0,
                            overwrite        => 0,
                            line_types       => [1,],
                            line_width       => 1,
                            long_ticks       => 1,
                            x_ticks          => 0,
                            bar_width        => 10,
                            bar_spacing      => 0,
                            box_axis         => 1,
                            zero_axis_only   => 0,
                            skip_undef       => 1,
                            legend_placement => "BR",
                        },
                        font_size    => {
                            title_font   => 10,
                            legend_font  => 8,
                            x_axis_font  => 6,
                            x_label_font => 9,
                            y_axis_font  => 6,
                            y_label_font => 9,
                        },
                        graphimage_path  => $graphimage_path,
                        graphimage_name  => $graphimage_name,
                })) {
                    $obj->{IfExistsGraph}    = 0;
                }

            }
=cut
            #*********************************
            # グラフ生成 END
            #*********************************
            $obj->{IfExistsGraph}    = 0;
            #$obj->{graphimage_name} = sprintf("%s_%s.png", $self->_myMethodName(), $publish_filename);
            #$obj->{graphimage_name} = $graphimage_name;
        }

        $obj->{sYEAR}             = $sYear;
        $obj->{sMONTH}            = $sMonth;
        $obj->{pMONTH}            = $sMonth-1;
        $obj->{nMONTH}            = $sMonth+1;
        $obj->{IfToPreviousMonth} = 1 < $sMonth ? 1 : 0;
        $obj->{IfToNextMonth}     = 12 > $sMonth ? 1 : 0;
        #*********************************
        # IfActionブロックを有効にする
        #*********************************
        $obj->{IfAction}          = 1;
    }

    return($obj);
}


#******************************************************
# @access    public
# @desc        年次アクセス数・会員登録数を出す
#            step1-ste3
#            step1.対象月の日・曜日の生成して一時テーブルに格納
#            step2.対象月の日・曜日を元にアクセスログテーブルと会員テーブルから情報を取得
#            step3.一時テーブルの削除
# @return    
#******************************************************
sub shukeiByYear {
    my $self = shift;
    my $q = $self->query();

    my $obj = {};
    $obj->{action} = $self->{action};

    my $pulldown = $self->createPeriodPullDown({year=>"year", range=>"-1,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{ $pulldown };
    
    if (defined ($q->param('year'))) {
        my ($sYear, $sMonth);
        $sYear = $q->param('year');
        #*********************************
        # 対象年の生成
        #*********************************
        #my $targetPeriod = sprintf("%04d-%02s-01", $sYear, $sMonth);
        my $tAccessLogF_YEAR   = 'tAccessLogF_' . sprintf("%4d", $sYear);
        my $tPageViewLogF_YEAR = 'tPageViewLogF_' . sprintf("%4d", $sYear);
        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');

        #*********************************
        # 集計SQL
        #*********************************

        my $sql;
        #***************************
        #  STEP1 会員登録・退会一時テーブル作成
        #***************************
        $sql = "
CREATE TEMPORARY TABLE TMPa(
 SELECT m.DMON AS MONTH
 ,COUNT(IF(u.status_flag=2 AND u.carrier=8, u.id, NULL)) AS RA
 ,COUNT(IF(u.status_flag=2 AND u.carrier=4, u.id, NULL)) AS RSB
 ,COUNT(IF(u.status_flag=2 AND u.carrier=2, u.id, NULL)) AS RD
 ,COUNT(IF(u.status_flag=2, u.id, NULL)) AS RTOTAL
 ,COUNT(IF(u.status_flag=4 AND u.carrier=8, u.id, NULL)) AS WA
 ,COUNT(IF(u.status_flag=4 AND u.carrier=4, u.id, NULL)) AS WSB
 ,COUNT(IF(u.status_flag=4 AND u.carrier=2, u.id, NULL)) AS WD
 ,COUNT(IF(u.status_flag=4, u.id, NULL)) AS WTOTAL
 FROM tMonthM m
  LEFT JOIN tUserRegistLogF u
   ON DATE_FORMAT(u.date_of_transaction, '%Y%m')"
        . sprintf("=CONCAT(%4d,m.DMON) GROUP BY DMON);", $sYear)
        ;

        ## SQL実行1
        $dbh->do($sql);

        #***************************
        # STEP2 アクセス数の一時テーブル作成
        #***************************
        $sql = sprintf("CREATE TEMPORARY TABLE TMPb(
 SELECT m.DMON AS MONTH
 ,COUNT(IF(a.carrier=8, a.id, NULL)) AS AA
 ,COUNT(IF(a.carrier=4, a.id, NULL)) AS ASB
 ,COUNT(IF(a.carrier=2, a.id, NULL)) AS AD
 ,COUNT(a.id) AS ATOTAL
  FROM tMonthM m
  LEFT JOIN %s a", $tAccessLogF_YEAR)
        . " ON DATE_FORMAT(a.in_datetime, '%m')=m.DMON GROUP BY DMON);"
        ;

        ## SQL実行2
        $dbh->do($sql);

        #***************************
        # STEP3 ページビュー数の一時テーブル作成
        #***************************
=pod
        $sql = sprintf("CREATE TEMPORARY TABLE TMPc (
 SELECT m.DMON AS MONTH
 ,IFNULL(SUM(p.pvcount), 0) AS PV
  FROM tMonthM m
  LEFT JOIN %s p", $tPageViewLogF_YEAR)
        . " ON DATE_FORMAT(p.in_date, '%m')=m.DMON GROUP BY DMON);"
        ;
=cut
        $sql = sprintf("CREATE TEMPORARY TABLE TMPc (
 SELECT m.DMON AS MONTH
 ,IFNULL(SUM(p.pvcount), 0) AS PV
 ,SUM(IF(carrier=2, p.pvcount, 0)) AS PVD
 ,SUM(IF(carrier=4, p.pvcount, 0)) AS PVSB
 ,SUM(IF(carrier=8, p.pvcount, 0)) AS PVA
  FROM tMonthM m
  LEFT JOIN %s p", $tPageViewLogF_YEAR)
        . " ON DATE_FORMAT(p.in_date, '%m')=m.DMON GROUP BY DMON);"
        ;

        ## SQL実行3
        $dbh->do($sql);

        #***************************
        # STEP4 3つのテーブル合体集計 TMPa TMPb TMPc
        #***************************
        $sql = "SELECT
 a.MONTH, a.RTOTAL, a.WTOTAL, b.ATOTAL,
 a.RA, a.WA, b.AA,
 a.RSB, a.WSB, b.ASB,
 a.RD, a.WD, b.AD,
 c.PV,
 c.PVD, c.PVSB, c.PVA
 FROM TMPa a, TMPb b, TMPc c
 WHERE a.MONTH=b.MONTH AND a.MONTH=c.MONTH;";


        ## SQL実行4
        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} });

        #***************************
        # STEP5 生成一時テーブルの破棄
        #***************************
        $sql = "DROP TABLE TMPa, TMPb, TMPc;";

        ## SQL実行5
        $dbh->do($sql);

        $obj->{LoopYearLog} = $#{ $aryref };
        if (1 > $obj->{LoopYearLog}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {

            ## 会員登録数・退会数格納一時変数
            my ($tmpcnt1, $tmpcnt2);
            for (my $i = 0; $i <= $obj->{LoopYearLog}; $i++) {
                map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                $obj->{MONTH}->[$i] = sprintf("%d", $obj->{MONTH}->[$i]);
            ## 率
                ## 登録率(アクセスに対する) ＊仮に例外的にアクセス数が０の場合これではエラーになるから修正 2010/02/26
                $obj->{RATIO_OF_REGISTRATION}->[$i] = ( 0 < $obj->{RTOTAL}->[$i] && 0 < $obj->{ATOTAL}->[$i] ) ? MyClass::WebUtil::Round((($obj->{RTOTAL}->[$i] / $obj->{ATOTAL}->[$i]) * 100), 2) : $obj->{RTOTAL}->[$i];

                $obj->{RATIO_OF_WITHDRAW}->[$i]     = 0 < $obj->{WTOTAL}->[$i] ? MyClass::WebUtil::Round((($obj->{WTOTAL}->[$i] / $obj->{RTOTAL}->[$i]) * 100), 2) : $obj->{WTOTAL}->[$i];
            ## 会員数を出す
                $tmpcnt1 += $obj->{RTOTAL}->[$i];
                $tmpcnt2 += $obj->{WTOTAL}->[$i];
                $obj->{KAIINSU}->[$i] = ($tmpcnt1 - $tmpcnt2);

            ## 各合計
                $obj->{SUM_RA}  += $obj->{RA}->[$i];
                $obj->{SUM_WA}  += $obj->{WA}->[$i];
                $obj->{SUM_AA}  += $obj->{AA}->[$i];
                $obj->{SUM_RSB} += $obj->{RSB}->[$i];
                $obj->{SUM_WSB} += $obj->{WSB}->[$i];
                $obj->{SUM_ASB} += $obj->{ASB}->[$i];
                $obj->{SUM_RD}  += $obj->{RD}->[$i];
                $obj->{SUM_WD}  += $obj->{WD}->[$i];
                $obj->{SUM_AD}  += $obj->{AD}->[$i];

                $obj->{cssstyle}->[$i] = 0 == $i % 2 ? 'focusodd' : 'focuseven';
            }
        ## ROLLUPを使用できないので、ここで計算
            map { $obj->{SUM_RTOTAL} += $_ } @{ $obj->{RTOTAL} };
            map { $obj->{SUM_WTOTAL} += $_ } @{ $obj->{WTOTAL} };
            map { $obj->{SUM_ATOTAL} += $_ } @{ $obj->{ATOTAL} };
            map { $obj->{SUM_PV}     += $_ } @{ $obj->{PV} };
            map { $obj->{SUM_PVD}    += $_ } @{ $obj->{PVD} };
            map { $obj->{SUM_PVSB}   += $_ } @{ $obj->{PVSB} };
            map { $obj->{SUM_PVA}    += $_ } @{ $obj->{PVA} };

        ## 登録率
            $obj->{SUM_RATIO_OF_REGISTRATION} = MyClass::WebUtil::Round((($obj->{SUM_RTOTAL} / $obj->{SUM_ATOTAL}) * 100), 2);
        ## 退会率
            $obj->{SUM_RATIO_OF_WITHDRAW}     = MyClass::WebUtil::Round((($obj->{SUM_WTOTAL} / $obj->{SUM_RTOTAL}) * 100), 2);

            $obj->{IfData} = 1;

## Modified No Graph creating 2010/02/26 BEGIN
=pod
            ## グラフのパス
            my $graphimage_path = $self->CONFIGURATION_VALUE("GRAPTHIMAGE_DIR");
            my $graphimage_name = sprintf("%s_%s.png", $self->_myMethodName(), $sYear);

            my $title = MyClass::WebUtil::convertByNKF('-w', "$sYear 年度 集計 ");
            my @labels   = @{ $obj->{MONTH} };
            my @regist   = @{ $obj->{RTOTAL} };
            my @withdraw = @{ $obj->{WTOTAL} };
            my @access   = @{ $obj->{ATOTAL} };
            my @auaccess = @{ $obj->{AA} };
            my @sbaccess = @{ $obj->{ASB} };
            my @pv       = @{ $obj->{PV} };

            my @data     = (\@labels, \@access, \@regist, \@withdraw, \@auaccess, \@sbaccess);

            my @legend   = (
                MyClass::WebUtil::convertByNKF('-w', 'アクセス'),
                MyClass::WebUtil::convertByNKF('-w', '会員登録'),
                MyClass::WebUtil::convertByNKF('-w', '会員退会'),
                MyClass::WebUtil::convertByNKF('-w', 'EzWebアクセス'),
                MyClass::WebUtil::convertByNKF('-w', 'SoftBankアクセス'),
            );
            my @types    = qw(area bars bars lines lines);
            my @dclrs    = qw(AliceBlue DeepPink DeepSkyBlue LightSalmon1 BlueViolet);


            if ( !MyClass::DataReportUtil::createGraph({
                    graphsize  => {
                        width  => 760,
                        height => 480,
                    },
                    data       => [\@data],
                    legend     => \@legend,
                    graph_set  => {
                        title            => $title,
                        t_margin         => 10,
                        b_margin         => 10,
                        l_margin         => 0,
                        r_margin         => 0,
                        x_label          => MyClass::WebUtil::convertByNKF('-w', '月'),
                        x_label_position => 0, 
                        y_label          => MyClass::WebUtil::convertByNKF('-w', 'アクセス/登録/退会 数'),
                        y_label_position => 0.5, 
                        #y_max_value         => 1000,
                        show_values      => 1,
                        values_forma     => '%d',
                        types            => [\@types],
                        dclrs            => [\@dclrs],
                        axislabelclr     => 'black',
                        borderclrs       => 'black',
                        bgclr            => 'white',
                        boxclr           => 'LightGrey',
                        fgclr            => 'black',
                        boxclr           => 'LightGrey',
                        accentclr        => 'LightSlateGray',
                        shadowclr        => 'DarkSlateGrey',
                        y_tick_number    => 10,
                        y_label_skip     => 0,
                        overwrite        => 0,
                        line_types       => [1, 1],
                        line_width       => 1,
                        long_ticks       => 1,
                        x_ticks          => 0,
                        bar_width        => 10,
                        bar_spacing      => 0,
                        box_axis         => 1,
                        zero_axis_only   => 0,
                        skip_undef       => 1,
                        legend_placement => "BR",
                    },
                    font_size  => {
                        title_font       => 10,
                        legend_font      => 6,
                        x_axis_font      => 6,
                        x_label_font     => 9,
                        y_axis_font      => 6,
                        y_label_font     => 9,
                    },
                    graphimage_path => $graphimage_path,
                    graphimage_name => $graphimage_name,
            })) {
                $obj->{IfExistsGraph}    = 0;
            }
            #*********************************
            # グラフ生成 END
            #*********************************
            $obj->{IfExistsGraph}   = 1;
            $obj->{graphimage_name} = $graphimage_name;
=cut
## Modified No Graph creating 2010/02/26 END
        }
        $obj->{sYEAR} = $sYear;
        $obj->{pYEAR} = $sYear-1;
        $obj->{nYEAR} = $sYear+1;
        $obj->{IfToPreviousYear} = 1 < $sYear ? 1 : 0;
        $obj->{IfToNextYear}     = 12 > $sYear ? 1 : 0;
        #*********************************
        # IfActionブロックを有効にする
        #*********************************
        $obj->{IfAction} = 1;
    }

    return($obj);
}


#******************************************************
# @access    public
# @desc      商品集計
# @return    
#******************************************************
sub shukeiProductView {
    my $self = shift;
    my $q = $self->query();

    my $obj = {};
    $obj->{action} = $self->{action};
    my $pulldown = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"-1,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{ $pulldown };

    if (defined ($q->param('year'))) {


    if (defined($q->param('ext')) && 'period' eq $q->param('ext')) {
        my @searchquery;
        my @searchquerymessage;

        my ($fsindate, $feindate);

        my $sql = "SELECT l.product_name, l.product_id, SUM(l.pvcount) AS SUM_PV,
 SUM(IF(carrier=2, l.pvcount, 0)) AS SUM_PVD,
 SUM(IF(carrier=4, l.pvcount, 0)) AS SUM_PVAU,
 SUM(IF(carrier=8, l.pvcount, 0)) AS SUM_PVSB
 FROM tProductViewLogF l ";

        if($q->param('fsdate') ne ''){
            $fsindate = sprintf("%s-%s-%s", $q->param('year'), $q->param('fsmonth'), $q->param('fsdate'));
            push(@searchquery , "l.in_date >= '$fsindate'");
            push(@searchquerymessage, "日時下限：[ $fsindate ]");
         }

        if($q->param('fedate') ne ''){
            $feindate = sprintf("%s-%s-%s", $q->param('year'), $q->param('femonth'), $q->param('fedate'));
            push(@searchquery , "l.in_date <= '$feindate'");
            push(@searchquerymessage, "日時上限限：[ $feindate ]");
            
         }
        if (0 < @searchquery) {
        	$sql .= sprintf(" WHERE %s", join(' AND ', @searchquery));
        }

        $sql .= "  GROUP BY  l.product_id ORDER BY  SUM_PV DESC;";
        $obj->{SEARCHQUERYMESSAGE} = join('　', @searchquerymessage);

        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');

        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} });

            $obj->{LoopProductViewLog} = $#{$aryref};

            if (0 > $obj->{LoopProductViewLog}) {
                $obj->{ERRORMSG} = '集計データがありません。';
                $obj->{IfNoData} = 1;
            } else {
                for (my $i = 0; $i <= $obj->{LoopProductViewLog}; $i++) {
                    map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                    $obj->{cssstyle}->[$i] = 0 == $i % 2 ? 'focusodd' : 'focuseven';
                }
                $obj->{IfData} = 1;
            }
            $obj->{IfAction} = 1;

        }
    }
    return $obj;
}

#******************************************************
# @access    public
# @desc        PV集計
# @return    
#******************************************************
sub shukeiPageViewByMonth {
    my $self = shift;
    my $q = $self->query();

    my $obj = {};
    $obj->{action} = $self->{action};

    #*********************************
    # 年月pulldown生成
    #*********************************
    my $pulldown = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"-1,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{ $pulldown };

## Modified 2010/03/08 
=pod
    $obj = {
        fsmonth => $q->param('fsmonth'),
        fsdate  => $q->param('fsdate'),
        femonth => $q->param('femonth'),
        fedate  => $q->param('fedate'),
    };
=cut


    if (defined ($q->param('year'))) {
#=pod

    if (defined($q->param('ext')) && 'period' eq $q->param('ext')) {
=pod
        my @searchquery;
        my ($fsindate, $frindate);
		my $table = sprintf("tPageViewLogF_%s", $q->param('year'));
        my $sql ="SELECT t.summary, SUM(l.pvcount) AS SUM_PV,
 SUM(IF(carrier=2, l.pvcount, 0)) AS SUM_PVD,
 SUM(IF(carrier=4, l.pvcount, 0)) AS SUM_PVAU,
 SUM(IF(carrier=8, l.pvcount, 0)) AS SUM_PVSB
 FROM $table l, tTmpltM t";

        if($q->param('fsdate') ne ''){
            $fsindate = sprintf("%s-%s-%s", $q->param('year'), $q->param('fsmonth'), $q->param('fsdate'));
            push(@searchquery , "l.in_date >= '$fsindate'")
         }

        if($q->param('frdate') ne ''){
            $fsindate = sprintf("%s-%s-%s", $q->param('year'), $q->param('frmonth'), $q->param('frdate'));
            push(@searchquery , "l.in_date <= '$frindate'")
         }
        if (0 < @searchquery) {
        	$sql .= sprintf(" WHERE %s", join(' AND ', @searchquery));
        }
=cut

        my @searchquery;
        my @searchquerymessage;

        my ($fsindate, $feindate);
		my $table = sprintf("tPageViewLogF_%s", $q->param('year'));

my $sql = sprintf("SELECT t.summary, SUM(l.pvcount) AS SUM_PV,
 SUM(IF(carrier=2, l.pvcount, 0)) AS SUM_PVD,
 SUM(IF(carrier=4, l.pvcount, 0)) AS SUM_PVAU,
 SUM(IF(carrier=8, l.pvcount, 0)) AS SUM_PVSB
 FROM %s l, tTmpltM t WHERE l.tmplt_name=t.tmplt_name", $table);

        if($q->param('fsdate') ne ''){
            $fsindate = sprintf("%s-%s-%s", $q->param('year'), $q->param('fsmonth'), $q->param('fsdate'));
            push(@searchquery , "l.in_date >= '$fsindate'");
            push(@searchquerymessage, "日時下限：[ $fsindate ]");
         }

        if($q->param('fedate') ne ''){
            $feindate = sprintf("%s-%s-%s", $q->param('year'), $q->param('femonth'), $q->param('fedate'));
            push(@searchquery , "l.in_date <= '$feindate'");
            push(@searchquerymessage, "日時上限限：[ $feindate ]");
            
         }
        if (0 < @searchquery) {
        	$sql .= sprintf(" AND %s", join(' AND ', @searchquery));
        }
        if (0 < @searchquery) {
            $sql .= sprintf(" AND %s", join(' AND ', @searchquery));
        }
$sql .= "  GROUP BY  l.tmplt_name ORDER BY  SUM_PV DESC;";
        $obj->{SEARCHQUERYMESSAGE} = join('　', @searchquerymessage);

# WHERE (l.in_date >= '2010-03-01' AND l.in_date <= '2010-03-04')
#  AND l.tmplt_name=t.tmplt_name
#  GROUP BY  l.tmplt_name
#  ORDER BY  SUM_PV DESC;";

my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');

        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} });

        $obj->{LoopPageViewLog} = $#{$aryref};

        if (0 > $obj->{LoopPageViewLog}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopPageViewLog}; $i++) {
                map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                $obj->{cssstyle}->[$i] = 0 == $i % 2 ? 'focusodd' : 'focuseven';
            }
            $obj->{IfData} = 1;
        }
$obj->{IfAction2} = 1;

    }
}

#=cut
=pod

        my ($sYear, $sMonth);
        $sYear  = $q->param('year');
        $sMonth = $q->param('month');
        #*********************************
        # 対象月の日・曜日の生成
        #*********************************
        my $targetPeriod = sprintf("%04d-%02s-01", $sYear, $sMonth);
        my $tPageViewLogF_MONTH = 'tPageViewLogF_' . sprintf("%4d%02d", $sYear, $sMonth);
        #*********************************
        # 対象月の日・曜日の生成
        #*********************************
        my $calender = $self->createMonthTable($sYear, $sMonth);
        map { $obj->{$_} = $calender->{$_} } keys %{ $calender };

        my @SUMIF = map { sprintf("SUM(IF(DAYOFMONTH(p.in_date) = '%s', p.pvcount, '0')) AS 'DAY%s'", $_, $_) } @{ $obj->{day} };

        my $sql = sprintf("SELECT t.summary,
 %s,
 SUM(p.pvcount) AS DAYTOTAL
 FROM %s p, tTmpltM t
 WHERE p.tmplt_name=t.tmplt_name
 GROUP BY p.tmplt_name", join(',', @SUMIF), $tPageViewLogF_MONTH);

        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');

        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} });

        $obj->{LoopPageViewLog} = $#{$aryref};

        if (0 > $obj->{LoopPageViewLog}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopPageViewLog}; $i++) {
                map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                $obj->{cssstyle}->[$i] = 0 == $i % 2 ? 'focusodd' : 'focuseven';
                ## Modified 2009/07/28
                $obj->{IfExistsDay31}->[$i] = exists($obj->{DAY31}) ? 1 : 0;
                $obj->{YEAR}->[$i]          = $sYear;
                $obj->{RYO}->[$i]           = $sMonth;

            }
            $obj->{IfData} = 1;
        }
        $obj->{Days}   = $obj->{LoopMONTH} + 3;
        $obj->{sYEAR}  = $sYear;
        $obj->{sMONTH} = $sMonth;
        $obj->{pMONTH} = $sMonth - 1;
        $obj->{nMONTH} = $sMonth + 1;
        $obj->{IfToPreviousMonth}    = 1 < $sMonth ? 1 : 0;
        $obj->{IfToNextMonth}        = 12 > $sMonth ? 1 : 0;
        #*********************************
        # IfActionブロックを有効にする
        #*********************************
        $obj->{IfAction} = 1;
    }
=cut
    return($obj);
}


#******************************************************
# @access    public
# @desc        PV集計 時間別
# @return    
#******************************************************
sub shukeiPageViewByHour {
    my $self = shift;
    my $q = $self->query();

    my $obj = {};
    $obj->{action} = $self->{action};

    if (defined ($q->param('year'))) {
        my ($sYear, $sMonth, $sDate);
        $sYear  = $q->param('year');
        $sMonth = $q->param('month');
        $sDate  = $q->param('date');

    ## ここで初期化
    my $aryref;

#*********************************
# シリアライズデータ機能追加2009/07/28 BEGIN
#*********************************
    ## パブリッシュディレクトリ フぁィル数が大量になるから年ごとに分ける＝＝３６５ファイル
    my $publishdir = sprintf("%s/admin/%s/%s", $self->CONFIGURATION_VALUE("SERIALIZEDOJB_DIR"), $self->_myMethodName(), $sYear);
    if (! -d $publishdir) {
        MyClass::WebUtil::createDir($publishdir);
    }
    my $publish_filename = sprintf("%4d%02d%02d", $sYear, $sMonth, $sDate);
    my $publishobj = sprintf("%s/%s.obj", $publishdir, $publish_filename);

#*********************************
# シリアライズデータ使用の場合
#*********************************
    ## パブリッシュされた最終時間を取得する
    if (-e $publishobj) {
        my ($lsize, $ltime) = stat($publishobj) ? (stat(_))[7, 9] : (0, 0);
        require POSIX;
        POSIX->import(qw(strftime)); 

        my $yyyymmdd = strftime("%Y%m%d", localtime($ltime));
        if ($publish_filename < $yyyymmdd) {
            eval {
                $aryref = MyClass::WebUtil::publishObj( { file=>$publishobj } );
            };
            ## オブジェクト取得失敗の場合
            if ($@) {
                goto DOSQLACCESS;
            }
        }
        else {
            goto DOSQLACCESS;
        }
    }
    else {
#*********************************
# DBアクセスSQL発行の場合
#*********************************
DOSQLACCESS:

        #*********************************
        # 対象月の日・曜日の生成
        #*********************************
        my $targetPeriod        = sprintf("%04d-%02s-%02s", $sYear, $sMonth, $sDate);
        my $tPageViewLogF_MONTH = 'tPageViewLogF_' . sprintf("%4d%02d", $sYear, $sMonth);
        my $sql                 = sprintf("SELECT DAYOFMONTH(p.in_date),  t.summary,
 SUM(IF(p.in_time = '00' AND carrier=2, p.pvcount, '0')) AS 'TIME0D',
 SUM(IF(p.in_time = '00' AND carrier=4, p.pvcount, '0')) AS 'TIME0SB',
 SUM(IF(p.in_time = '00' AND carrier=8, p.pvcount, '0')) AS 'TIME0AU',
 SUM(IF(p.in_time = '01' AND carrier=2, p.pvcount, '0')) AS 'TIME1D',
 SUM(IF(p.in_time = '01' AND carrier=4, p.pvcount, '0')) AS 'TIME1SB',
 SUM(IF(p.in_time = '01' AND carrier=8, p.pvcount, '0')) AS 'TIME1AU',
 SUM(IF(p.in_time = '02' AND carrier=2, p.pvcount, '0')) AS 'TIME2D',
 SUM(IF(p.in_time = '02' AND carrier=4, p.pvcount, '0')) AS 'TIME2SB',
 SUM(IF(p.in_time = '02' AND carrier=8, p.pvcount, '0')) AS 'TIME2AU',
 SUM(IF(p.in_time = '03' AND carrier=2, p.pvcount, '0')) AS 'TIME3D',
 SUM(IF(p.in_time = '03' AND carrier=4, p.pvcount, '0')) AS 'TIME3SB',
 SUM(IF(p.in_time = '03' AND carrier=8, p.pvcount, '0')) AS 'TIME3AU',
 SUM(IF(p.in_time = '04' AND carrier=2, p.pvcount, '0')) AS 'TIME4D',
 SUM(IF(p.in_time = '04' AND carrier=4, p.pvcount, '0')) AS 'TIME4SB',
 SUM(IF(p.in_time = '04' AND carrier=8, p.pvcount, '0')) AS 'TIME4AU',
 SUM(IF(p.in_time = '05' AND carrier=2, p.pvcount, '0')) AS 'TIME5D',
 SUM(IF(p.in_time = '05' AND carrier=4, p.pvcount, '0')) AS 'TIME5SB',
 SUM(IF(p.in_time = '05' AND carrier=8, p.pvcount, '0')) AS 'TIME5AU',
 SUM(IF(p.in_time = '06' AND carrier=2, p.pvcount, '0')) AS 'TIME6D',
 SUM(IF(p.in_time = '06' AND carrier=4, p.pvcount, '0')) AS 'TIME6SB',
 SUM(IF(p.in_time = '06' AND carrier=8, p.pvcount, '0')) AS 'TIME6AU',
 SUM(IF(p.in_time = '07' AND carrier=2, p.pvcount, '0')) AS 'TIME7D',
 SUM(IF(p.in_time = '07' AND carrier=4, p.pvcount, '0')) AS 'TIME7SB',
 SUM(IF(p.in_time = '07' AND carrier=8, p.pvcount, '0')) AS 'TIME7AU',
 SUM(IF(p.in_time = '08' AND carrier=2, p.pvcount, '0')) AS 'TIME8D',
 SUM(IF(p.in_time = '08' AND carrier=4, p.pvcount, '0')) AS 'TIME8SB',
 SUM(IF(p.in_time = '08' AND carrier=8, p.pvcount, '0')) AS 'TIME8AU',
 SUM(IF(p.in_time = '09' AND carrier=4, p.pvcount, '0')) AS 'TIME9SB',
 SUM(IF(p.in_time = '09' AND carrier=2, p.pvcount, '0')) AS 'TIME9D',
 SUM(IF(p.in_time = '09' AND carrier=8, p.pvcount, '0')) AS 'TIME9AU',
 SUM(IF(p.in_time = '10' AND carrier=2, p.pvcount, '0')) AS 'TIME10D',
 SUM(IF(p.in_time = '10' AND carrier=4, p.pvcount, '0')) AS 'TIME10SB',
 SUM(IF(p.in_time = '10' AND carrier=8, p.pvcount, '0')) AS 'TIME10AU',
 SUM(IF(p.in_time = '11' AND carrier=2, p.pvcount, '0')) AS 'TIME11D',
 SUM(IF(p.in_time = '11' AND carrier=4, p.pvcount, '0')) AS 'TIME11SB',
 SUM(IF(p.in_time = '11' AND carrier=8, p.pvcount, '0')) AS 'TIME11AU',
 SUM(IF(p.in_time = '12' AND carrier=2, p.pvcount, '0')) AS 'TIME12D',
 SUM(IF(p.in_time = '12' AND carrier=4, p.pvcount, '0')) AS 'TIME12SB',
 SUM(IF(p.in_time = '12' AND carrier=8, p.pvcount, '0')) AS 'TIME12AU',
 SUM(IF(p.in_time = '13' AND carrier=2, p.pvcount, '0')) AS 'TIME13D',
 SUM(IF(p.in_time = '13' AND carrier=4, p.pvcount, '0')) AS 'TIME13SB',
 SUM(IF(p.in_time = '13' AND carrier=8, p.pvcount, '0')) AS 'TIME13AU',
 SUM(IF(p.in_time = '14' AND carrier=2, p.pvcount, '0')) AS 'TIME14D',
 SUM(IF(p.in_time = '14' AND carrier=4, p.pvcount, '0')) AS 'TIME14SB',
 SUM(IF(p.in_time = '14' AND carrier=8, p.pvcount, '0')) AS 'TIME14AU',
 SUM(IF(p.in_time = '15' AND carrier=2, p.pvcount, '0')) AS 'TIME15D',
 SUM(IF(p.in_time = '15' AND carrier=4, p.pvcount, '0')) AS 'TIME15SB',
 SUM(IF(p.in_time = '15' AND carrier=8, p.pvcount, '0')) AS 'TIME15AU',
 SUM(IF(p.in_time = '16' AND carrier=2, p.pvcount, '0')) AS 'TIME16D',
 SUM(IF(p.in_time = '16' AND carrier=4, p.pvcount, '0')) AS 'TIME16SB',
 SUM(IF(p.in_time = '16' AND carrier=8, p.pvcount, '0')) AS 'TIME16AU',
 SUM(IF(p.in_time = '17' AND carrier=2, p.pvcount, '0')) AS 'TIME17D',
 SUM(IF(p.in_time = '17' AND carrier=4, p.pvcount, '0')) AS 'TIME17SB',
 SUM(IF(p.in_time = '17' AND carrier=8, p.pvcount, '0')) AS 'TIME17AU',
 SUM(IF(p.in_time = '18' AND carrier=2, p.pvcount, '0')) AS 'TIME18D',
 SUM(IF(p.in_time = '18' AND carrier=4, p.pvcount, '0')) AS 'TIME18SB',
 SUM(IF(p.in_time = '18' AND carrier=8, p.pvcount, '0')) AS 'TIME18AU',
 SUM(IF(p.in_time = '19' AND carrier=2, p.pvcount, '0')) AS 'TIME19D',
 SUM(IF(p.in_time = '19' AND carrier=4, p.pvcount, '0')) AS 'TIME19SB',
 SUM(IF(p.in_time = '19' AND carrier=8, p.pvcount, '0')) AS 'TIME19AU',
 SUM(IF(p.in_time = '20' AND carrier=2, p.pvcount, '0')) AS 'TIME20D',
 SUM(IF(p.in_time = '20' AND carrier=4, p.pvcount, '0')) AS 'TIME20SB',
 SUM(IF(p.in_time = '20' AND carrier=8, p.pvcount, '0')) AS 'TIME20AU',
 SUM(IF(p.in_time = '21' AND carrier=2, p.pvcount, '0')) AS 'TIME21D',
 SUM(IF(p.in_time = '21' AND carrier=4, p.pvcount, '0')) AS 'TIME21SB',
 SUM(IF(p.in_time = '21' AND carrier=8, p.pvcount, '0')) AS 'TIME21AU',
 SUM(IF(p.in_time = '22' AND carrier=2, p.pvcount, '0')) AS 'TIME22D',
 SUM(IF(p.in_time = '22' AND carrier=4, p.pvcount, '0')) AS 'TIME22SB',
 SUM(IF(p.in_time = '22' AND carrier=8, p.pvcount, '0')) AS 'TIME22AU',
 SUM(IF(p.in_time = '23' AND carrier=2, p.pvcount, '0')) AS 'TIME23D',
 SUM(IF(p.in_time = '23' AND carrier=4, p.pvcount, '0')) AS 'TIME23SB',
 SUM(IF(p.in_time = '23' AND carrier=8, p.pvcount, '0')) AS 'TIME23AU',
 SUM(IF(carrier=2, p.pvcount, '0')) AS 'SUMD',
 SUM(IF(carrier=4, p.pvcount, '0')) AS 'SUMSB',
 SUM(IF(carrier=8, p.pvcount, '0')) AS 'SUMAU',
 SUM(p.pvcount) AS TIMETOTAL
 FROM %s p, tTmpltM t
 WHERE p.in_date=? AND p.tmplt_name=t.tmplt_name
 GROUP BY p.tmplt_name
 ORDER BY p.in_time", $tPageViewLogF_MONTH);

        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');
        $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $targetPeriod);

            #***************************
            # 集計データをシリアライズしてパブリッシュ
            #***************************
            MyClass::WebUtil::publishObj({ file => $publishobj, obj => $aryref });
        }

        $obj->{LoopPageViewLog} = $#{ $aryref };

        if (1 > $obj->{LoopPageViewLog}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopPageViewLog}; $i++) {
                map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                $obj->{cssstyle}->[$i] = 0 == $i % 2 ? 'focusodd' : 'focuseven';
            }
            $obj->{IfData}    = 1;
            $obj->{sYEAR}    = $sYear;
            $obj->{sMONTH}    = $sMonth;
            $obj->{sDATE}    = $sDate;
        }
        $obj->{IfAction} = 1;
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        アクセス集計
# @return    
#******************************************************
sub shukeiAccess {
    my $self = shift;
    my $q = $self->query();

    my $obj = {};
    $obj->{action} = $self->{action};
    #*********************************
    # 年月pulldown生成
    #*********************************
    my $pulldown = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"-1,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{ $pulldown };
    if (defined ($q->param('year'))) {
        my ($sYear, $sMonth);
        $sYear    = $q->param('year');
        $sMonth = $q->param('month');

        ## ここで初期化
        my $aryref;
        ## 新規にグラフを生成するかの判定フラグ
        my $flagnew = 0;
        #*********************************
        # シリアライズデータ機能追加2009/08/03 BEGIN
        #*********************************

        ## パブリッシュディレクトリ
        my $publishdir = sprintf("%s/admin/%s", $self->CONFIGURATION_VALUE("SERIALIZEDOJB_DIR"), $self->_myMethodName());
        if (! -d $publishdir) {
            MyClass::WebUtil::createDir($publishdir);
        }
        ## パブリッシュファイルの名前
        my $publish_filename = sprintf("%4d%02d", $sYear, $sMonth);
        my $publishobj = sprintf("%s/%s.obj", $publishdir, $publish_filename);
        ## グラフのパス
        my $graphimage_path = $self->CONFIGURATION_VALUE("GRAPTHIMAGE_DIR");
        my $graphimage_name = sprintf("%s_%s.png", $self->_myMethodName(), $publish_filename);

        #*********************************
        # シリアライズデータ使用の場合
        #*********************************
        ## パブリッシュされた最終時間を取得する
        if (-e $publishobj) {
            my ($lsize, $ltime) = stat($publishobj) ? (stat(_))[7, 9] : (0, 0);
            require POSIX;
            POSIX->import(qw(strftime)); 

            my $yyyymm = strftime("%Y%m", localtime($ltime));
            if ($publish_filename < $yyyymm) {
                eval {
                    $aryref = MyClass::WebUtil::publishObj( { file=>$publishobj } );
                };
                ## オブジェクト取得失敗の場合
                if ($@) {
                    goto DOSQLACCESS;
                }
            }
            else {
                goto DOSQLACCESS;
            }
        }
        else {
#*********************************
# DBアクセスSQL発行の場合
#*********************************
DOSQLACCESS:
            #*********************************
            # 対象月の日・曜日の生成
            #*********************************
            my $targetPeriod = sprintf("%04d-%02s-01", $sYear, $sMonth);
            my $tAccessLogF_MONTH = 'tAccessLogF_' . sprintf("%4d%02d", $sYear, $sMonth);
            my $sql = sprintf("SELECT DATE(in_datetime), DAYOFMONTH(in_datetime),
 COUNT(IF(carrier=2, id, NULL)) AS AD,
 COUNT(IF(carrier=4, id, NULL)) AS ASB,
 COUNT(IF(carrier=8, id, NULL)) AS AA,
 COUNT(id) AS ATOTAL
 FROM %s
 WHERE  DATE_FORMAT(in_datetime, '%Y')=DATE_FORMAT(?, '%Y')
 GROUP BY DATE(in_datetime) WITH ROLLUP", $tAccessLogF_MONTH);


            my $dbh = $self->getDBConnection();
            $dbh->do('USE JKZ_WAF');
            $aryref = $dbh->selectall_arrayref($sql, undef, $targetPeriod);

            #***************************
            # 集計データをシリアライズしてパブリッシュ
            #***************************
            MyClass::WebUtil::publishObj({ file=>$publishobj, obj=>$aryref });
            #***************************
            # ここのラベルへきたらグラフは新規生成
            #***************************
            $flagnew = 1;
        }

        $obj->{LoopAccessLog} = $#{ $aryref };
        if (1 > $obj->{LoopAccessLog}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopAccessLog}; $i++) {
                if ($#{$aryref}==$i) {
                    $obj->{TAD}        = $aryref->[$i]->[2];
                    $obj->{TASB}    = $aryref->[$i]->[3];
                    $obj->{TAA}        = $aryref->[$i]->[4];
                    $obj->{TATOTAL} = $aryref->[$i]->[5];
                }
                else {
                    $obj->{AD}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[2];
                    $obj->{ASB}->[$aryref->[$i]->[1]-1]    = $aryref->[$i]->[3];
                    $obj->{AA}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[4];
                    $obj->{ATOTAL}->[$aryref->[$i]->[1]-1] = $aryref->[$i]->[5];

                    $obj->{YEAR}->[$aryref->[$i]->[1]-1]   = $sYear;
                    $obj->{RYO}->[$aryref->[$i]->[1]-1]        = $sMonth;
                    $obj->{IfExistsAccessData}->[$aryref->[$i]->[1]-1] = 1;
                }
            }
            $obj->{IfData} = 1;

            #*********************************
            # 対象月の日・曜日の生成 こちらに移動
            #*********************************
            my $calender = $self->createMonthTable ($sYear, $sMonth);
            map { $obj->{$_} = $calender->{$_} } keys %{ $calender };


            #*********************************
            # グラフ生成 新規生成フラグが立ってれば もしくはまだグラフ画像が無い場合は新規生成
            #*********************************
            my $fullpath_to_graphimage = sprintf("%s/%s", $graphimage_path, $graphimage_name);
            if ($flagnew || ! -e $fullpath_to_graphimage) {
                my $title = MyClass::WebUtil::convertByNKF('-w', "$sMonth 月 アクセス");
                ## データを設定
                my @labels = @{ $obj->{day} };
                ## au+softbankが合計数になるから下記二つでOK
                my @au            = @{ $obj->{AA} };
                my @sb            = @{ $obj->{ASB} };
                #my @do            = @{ $obj->{AD} };

                my @data = (\@labels, \@au , \@sb);

                ## 日本語はutf8に変換
                my @legend    = (
                    MyClass::WebUtil::convertByNKF('-w', 'EzWebアクセス'),
                    MyClass::WebUtil::convertByNKF('-w', 'SoftBankアクセス'),
                );

                my @types    = qw(bars bars);
                my @dclrs    = qw(LightSalmon1 BlueViolet);
                #my @markers    = qw(5);

                if ( !MyClass::DataReportUtil::createGraph({
                        graphsize  => {
                            width  => 760,
                            height => 480,
                        },
                        data       => [\@data],
                        legend     => \@legend,
                        graph_set  => {
                            title    => $title,
                            t_margin => 10,
                            b_margin => 10,
                            l_margin => 0,
                            r_margin => 0,
                            x_label  => MyClass::WebUtil::convertByNKF('-w', '日付'),
                            x_label_position => 0, 
                            y_label          => MyClass::WebUtil::convertByNKF('-w', 'アクセス カウント'),
                            y_label_position => 0.5, 
                            y_max_value      => 1000,
                            show_values      => 1,
                            values_forma     => '%d',
                            types            => [\@types],
                            dclrs            => [\@dclrs],
                            axislabelclr     => 'black',
                            borderclrs       => 'black',
                            bgclr            => 'white',
                            boxclr           => 'LightGrey',
                            fgclr            => 'black',
                            boxclr           => 'LightGrey',
                            accentclr        => 'LightSlateGray',
                            shadowclr        => 'DarkSlateGrey',
                            y_tick_number    => 10,
                            y_label_skip     => 0,
                            overwrite        => 0,
                            line_types       => 1,
                            line_width       => 1,
                            long_ticks       => 1,
                            x_ticks          => 0,
                            bar_width        => 10,
                            bar_spacing      => 0,
                            box_axis         => 1,
                            zero_axis_only   => 0,
                            skip_undef       => 1,
                            legend_placement => "BR",
                        },
                        font_size    => {
                            title_font      => 10,
                            legend_font     => 8,
                            x_axis_font     => 6,
                            x_label_font    => 9,
                            y_axis_font     => 6,
                            y_label_font    => 9,
                        },
                        graphimage_path   => $graphimage_path,
                        graphimage_name   => $graphimage_name,
                        halfsize_image    => 1,
                })) {
                    $obj->{IfExistsGraph}    = 0;
                }
            }
            #*********************************
            # グラフ生成 END
            #*********************************
            $obj->{IfExistsGraph}    = 1;
            #$obj->{graphimage_name} = sprintf("%s_%s.png", $self->_myMethodName(), $publish_filename);
            $obj->{graphimage_name} = $graphimage_name;
        }
        $obj->{sYEAR} = $sYear;
        $obj->{sMONTH} = $sMonth;
        $obj->{pMONTH} = $sMonth - 1;
        $obj->{nMONTH} = $sMonth + 1;
        $obj->{IfToPreviousMonth} = 1 < $sMonth  ? 1 : 0;
        $obj->{IfToNextMonth}     = 12 > $sMonth ? 1 : 0;
        #*********************************
        # IfActionブロックを有効にする
        #*********************************
        $obj->{IfAction} = 1;
    }

    return($obj);
}


#******************************************************
# @access    
# @desc        アクセス集計の生データ
# @param    
# @param    
# @return    
#******************************************************
sub shukeiAccessByDate {
    my $self = shift;

    my $q = $self->query();

    my $obj = {};
    $obj->{action} = $self->{action};
    #*********************************
    # 年月pulldown生成
    #*********************************
#    my $pulldown = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"-1,3"});
#    map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
    if (defined ($q->param('year')) && $q->param('month') && $q->param('date')) {
        my ($sYear, $sMonth, $sDate);
        $sYear  = $q->param('year');
        $sMonth = $q->param('month');
        $sDate  = $q->param('date');

        ## ここで初期化
        my $aryref;
        ## 新規にグラフを生成するかの判定フラグ
        my $flagnew = 0;
        #*********************************
        # シリアライズデータ機能追加2009/08/03 BEGIN
        #*********************************

        ## パブリッシュディレクトリ
        my $publishdir = sprintf("%s/admin/%s", $self->CONFIGURATION_VALUE("SERIALIZEDOJB_DIR"), $self->_myMethodName());
        if (! -d $publishdir) {
            MyClass::WebUtil::createDir($publishdir);
        }
        ## パブリッシュファイルの名前
        my $publish_filename = sprintf("%4d%02d%02d", $sYear, $sMonth, $sDate);
        my $publishobj       = sprintf("%s/%s.obj", $publishdir, $publish_filename);

        #*********************************
        # シリアライズデータ使用の場合
        #*********************************
        ## パブリッシュされた最終時間を取得する
        if (-e $publishobj) {
            my ($lsize, $ltime) = stat($publishobj) ? (stat(_))[7, 9] : (0, 0);
            require POSIX;
            POSIX->import(qw(strftime)); 

            my $yyyymmdd = strftime("%Y%m%d", localtime($ltime));
            if ($publish_filename < $yyyymmdd) {
                eval {
                    $aryref = MyClass::WebUtil::publishObj( { file=>$publishobj } );
                };
                ## オブジェクト取得失敗の場合
                if ($@) {
                    goto DOSQLACCESS;
                }
            }
            else {
                goto DOSQLACCESS;
            }
        }
        else {
#*********************************
# DBアクセスSQL発行の場合
#*********************************
DOSQLACCESS:
            #*********************************
            # 対象日付の生成
            #*********************************
            my $targetPeriod      = sprintf("%04d-%02d-%02d", $sYear, $sMonth, $sDate); # eg 2009-08-15
            my $tAccessLogF_MONTH = 'tAccessLogF_' . sprintf("%4d%02d", $sYear, $sMonth);
            my $sql               = sprintf("SELECT TIME(in_datetime) AS in_datetime, acd, carrier, guid, useragent FROM %s WHERE DATE(in_datetime)=?;", $tAccessLogF_MONTH);

            my $dbh = $self->getDBConnection();
            $dbh->do('use JKZ_WAF');
            $aryref = $dbh->selectall_arrayref( $sql, { Columns => {} }, $targetPeriod );

            MyClass::WebUtil::publishObj({ file => $publishobj, obj => $aryref });

        }
        $obj->{LoopAccessLog} = $#{ $aryref };
        if (0 > $obj->{LoopAccessLog}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopAccessLog}; $i++) {
                map { $obj->{$_}->[$i]  = $aryref->[$i]->{$_} } keys %{ $aryref };
                $obj->{CARRIER}->[$i]   = $self->fetchOneValueFromConf('CARRIERNAME_JP', (log($obj->{carrier}->[$i]) / log(2)-1));
                $obj->{useragent}->[$i] = substr($obj->{useragent}->[$i], 0, 40);

            }
            $obj->{IfData} = 1;
            $obj->{sYEAR}  = $sYear;
            $obj->{sMONTH} = $sMonth;
            $obj->{sDATE}  = $sDate;
        }
        $obj->{IfAction} = 1;
    }

    return $obj;
}



#******************************************************
# @access    public
# @desc        広告コード別アクセスと会員登録数と 掲載期間中の全体アクセス数(アフィリエイト)
# @return    
#******************************************************
sub shukeiByACD {
    my $self = shift;
    my $q    = $self->query;
    my $obj  = {};

    $obj->{action} = $self->{action};

    #*********************************
    # 広告コードのpulldown生成
    #*********************************
    my $dbh = $self->getDBConnection();

    my $aryref = $dbh->selectall_arrayref("SELECT acd, client_name FROM JKZ_WAF.tAffiliateM ORDER BY registration_date DESC;", { Columns => {} });
    $obj->{LoopACDList} = $#{$aryref};
    my $tmpkey = 'p';
    for (my $i = 0; $i <= $obj->{LoopACDList}; $i++) {
        map { $obj->{$tmpkey . $_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
    }

    #*********************************
    # 集計開始 広告コード、年月パラメータがある場合
    #*********************************
    if (defined($q->param('acd'))) {
        ## 集計対象広告
        my @acd = $q->param('acd');
        my @placeholder;
        map { $placeholder[$_] = '?' } (0..$#acd);

        my $tAffiliateM = 'JKZ_WAF.tAffiliateM';
        my $tMemberM    = 'JKZ_WAF.tMemberM';
        my $tAccessLogF = 'JKZ_WAF.tAccessLogF_2009';

        my $sql;

        my $tAffiliateAccessLogF = 'JKZ_WAF.tAffiliateAccessLogF';
        my $tUserRegistLogF      = 'JKZ_WAF.tUserRegistLogF';

        $sql = "SELECT am.acd, am.valid_date, am.expire_date, am.client_name, al.ACNT, ur.RCNT
 ,COUNT(IF(DATE_FORMAT(ac.in_datetime, '%Y-%m-%d') BETWEEN am.valid_date AND am.expire_date, ac.id, NULL)) AS TCNT"
             . sprintf(" FROM %s ac, %s am
  LEFT JOIN (
   SELECT acd, COUNT(acd) AS ACNT
    FROM %s GROUP BY acd
  ) AS al ON (am.acd=al.acd)
   LEFT JOIN (
    SELECT acd, COUNT(acd) RCNT
     FROM %s GROUP BY acd
  ) AS ur ON (am.acd=ur.acd)
 WHERE am.acd IN(%s)
  GROUP BY am.acd
  ORDER BY am.acd
;", $tAccessLogF, $tAffiliateM, $tAffiliateAccessLogF, $tUserRegistLogF, join(',', @placeholder));

        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, @acd);

        $obj->{LoopArray} = $#{$aryref};
        if (0 > $obj->{LoopArray}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopArray}; $i++) {
                map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                ## 日付のセパレータを変更
                $obj->{valid_date}->[$i]  = MyClass::WebUtil::formatDateTimeSeparator($obj->{valid_date}->[$i], {sepfrom =>'-', septo=>'/'});
                $obj->{expire_date}->[$i] = MyClass::WebUtil::formatDateTimeSeparator($obj->{expire_date}->[$i], {sepfrom =>'-', septo=>'/'});
                $obj->{ACNT}->[$i]        = MyClass::WebUtil::insertComma($obj->{ACNT}->[$i]);
                $obj->{TCNT}->[$i]        = MyClass::WebUtil::insertComma($obj->{TCNT}->[$i]);
                $obj->{cssstyle}->[$i]    = 0 == $i % 2 ? 'focuseven' : 'focusodd' ;
                ( 0 < $obj->{RCNT}->[$i] ) ? $obj->{IfExistsData}->[$i] = 1 : $obj->{IfNotExistsData}->[$i] = 1 ;
            }
            $obj->{IfData} = 1;
        }
        #*********************************
        # IfActionブロックを有効にする
        #*********************************
        $obj->{IfAction} = 1;
    }
    return $obj;
}



#******************************************************
# @access    
# @desc        アフィリエイト
# @param    str    $string parameter advアフィリエイトかリンクかの識別
# @param    
# @return    
#******************************************************
sub shukeiAffiliate {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    $obj->{action} = $self->{action};
    #*********************************
    # 年月pulldown生成
    #*********************************
    my $pulldown = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"-1,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};

        my $flag        = 1 == $q->param('adv') ? 1 : undef;
        my $targetTable = $flag ? 'tAdvAccessLogF' : 'tAffiliateAccessLogF' ;
        my $masterTable = $flag ? 'tAdvM' : 'tAffiliateM';

        my $userRegistTable = 'tUserRegistLogF';
        my $IfFlag = sprintf("If%s", $masterTable);

        $obj->{$IfFlag} = 1;

    if (defined ($q->param('year'))) {
        my ($sYear, $sMonth);
        $sYear  = $q->param('year');
        $sMonth = $q->param('month');
        #*********************************
        # 対象月の日・曜日の生成
        #*********************************
        my $targetPeriod = sprintf("%04d-%02s", $sYear, $sMonth);

        #*********************************
        # 対象月の日・曜日の生成
        #*********************************
        my $calender = $self->createMonthTable($sYear, $sMonth);
        map { $obj->{$_} = $calender->{$_} } keys %{ $calender };

        map { $obj->{YEAR}->[$_]     = $sYear } 0..$#{ $obj->{day} };
        map { $obj->{RYO}->[$_]      = $sMonth } 0..$#{ $obj->{day} };
        map { $obj->{advValue}->[$_] = $flag } 0..$#{ $obj->{day} };

        my @COLUMNS     = map { sprintf("al.alDAY%s, rl.rlDAY%s", $_, $_) } @{ $obj->{day} };
        push(@COLUMNS, "al.alDAYTOTAL, rl.rlDAYTOTAL");
        my @AccessSUMIF = map { sprintf("COUNT(IF(DAYOFMONTH(in_date) = '%s', in_date, NULL)) AS 'alDAY%s'", $_, $_) } @{ $obj->{day} };
        my @RegistSUMIF = map { sprintf("SUM(IF(DAYOFMONTH(date_of_transaction) = '%s', 1, '0')) AS 'rlDAY%s'", $_, $_) } @{ $obj->{day} };
        my $sql         = sprintf("SELECT a.client_name,
 %s FROM %s a
 LEFT JOIN (
   SELECT acd, %s, COUNT(in_date) AS alDAYTOTAL FROM %s WHERE DATE_FORMAT(in_date, '%Y-%m')=? GROUP BY acd
 ) AS al ON (a.acd=al.acd)
  LEFT JOIN (
   SELECT acd, %s, SUM(1) AS rlDAYTOTAL FROM %s WHERE DATE_FORMAT(date_of_transaction, '%Y-%m')=? GROUP BY acd
 ) AS rl ON (a.acd=rl.acd)", join(',', @COLUMNS), $masterTable, join(',', @AccessSUMIF), $targetTable, join(',', @RegistSUMIF), $userRegistTable);

        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');

        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $targetPeriod, $targetPeriod);

        $obj->{LoopAccessCountLog} = $#{$aryref};

        if (0 > $obj->{LoopAccessCountLog}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopAccessCountLog}; $i++) {
                map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                $obj->{cssstyle}->[$i] = 0 == $i % 2 ? 'focuseven' : 'focusodd';
                $obj->{COLTOTAL}->[$i] = ($calender->{day}->[-1] + 2);
            ## Modified 2010/03/01 2月・うるう年処理 BEGIN
                31 == $calender->{day}->[-1] ? $obj->{IfExistsDay31}->[$i] = 1 :
                30 == $calender->{day}->[-1] ? $obj->{IfExistsDay31}->[$i] = 1 :
                29 == $calender->{day}->[-1] ? $obj->{IfExistsDay29}->[$i] = 1 :
                                               ""                              ;
            ## Modified 2010/03/01 2月・うるう年処理 END
            }
            $obj->{IfData} = 1;
        }
        $obj->{Days}   = $calender->{LoopMONTH} + 3;
        $obj->{sYEAR}  = $sYear;
        $obj->{sMONTH} = $sMonth;
        $obj->{pMONTH} = $sMonth - 1;
        $obj->{nMONTH} = $sMonth + 1;
        $obj->{IfToPreviousMonth} = 1 < $sMonth  ? 1 : 0;
        $obj->{IfToNextMonth}     = 12 > $sMonth ? 1 : 0;
        #*********************************
        # IfActionブロックを有効にする
        #*********************************
        $obj->{IfAction} = 1;
    }

    return($obj);
}


#******************************************************
# @access    public
# @desc        アフィリエイトの集計 時間別
# @return    
#******************************************************
sub shukeiAffiliateByHour {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    $obj->{action} = $self->{action};

    if (defined ($q->param('year'))) {
        my ($sYear, $sMonth, $sDate);
        $sYear  = $q->param('year');
        $sMonth = $q->param('month');
        $sDate  = $q->param('date');

        my $flag = 1 == $q->param('adv') ? 1 : undef;
        my $targetTable = $flag ? 'tAdvAccessLogF' : 'tAffiliateAccessLogF' ;
        my $masterTable = $flag ? 'tAdvM' : 'tAffiliateM';
        my $IfFlag = sprintf("If%s", $masterTable);
        $obj->{$IfFlag} = 1;

        ## ここで初期化
        my $aryref;

#*********************************
# シリアライズデータ機能追加2009/07/28 BEGIN
#*********************************

        ## パブリッシュディレクトリ フぁィル数が大量になるから年ごとに分ける＝＝３６５ファイル
        my $publishdir = sprintf("%s/admin/%s/%s/%s", $self->CONFIGURATION_VALUE("SERIALIZEDOJB_DIR"), $self->_myMethodName(), $targetTable, $sYear);
        if (! -d $publishdir) {
            MyClass::WebUtil::createDir($publishdir);
        }
        my $publish_filename = sprintf("%4d%02d%02d", $sYear, $sMonth, $sDate);
        my $publishobj = sprintf("%s/%s.obj", $publishdir, $publish_filename);

#*********************************
# シリアライズデータ使用の場合
#*********************************
        ## パブリッシュされた最終時間を取得する
        if (-e $publishobj) {
            my ($lsize, $ltime) = stat($publishobj) ? (stat(_))[7, 9] : (0, 0);
            require POSIX;
            POSIX->import(qw(strftime)); 

            my $yyyymmdd = strftime("%Y%m%d", localtime($ltime));
            if ($publish_filename < $yyyymmdd) {
                eval {
                    $aryref = MyClass::WebUtil::publishObj( { file=>$publishobj } );
                };
                ## オブジェクト取得失敗の場合
                if ($@) {
                    goto DOSQLACCESS;
                }
            }
            else {
                goto DOSQLACCESS;
            }
        }
        else {
#*********************************
# DBアクセスSQL発行の場合
#*********************************
DOSQLACCESS:

        #*********************************
        # 対象月の日・曜日の生成
        #*********************************
        #my $targetPeriod = sprintf("%04d-%02s-%02s", $sYear, $sMonth, $sDate);
        my $targetPeriod = sprintf("%02d%02s%02s", substr($sYear,2,4), $sMonth, $sDate);
=pod
        my $sql = sprintf("SELECT DAYOFMONTH(l.in_date),  a.client_name,
 SUM(IF(l.in_time = '00', l.accesscount, '0')) AS 'TIME0',
 SUM(IF(l.in_time = '01', l.accesscount, '0')) AS 'TIME1',
 SUM(IF(l.in_time = '02', l.accesscount, '0')) AS 'TIME2',
 SUM(IF(l.in_time = '03', l.accesscount, '0')) AS 'TIME3',
 SUM(IF(l.in_time = '04', l.accesscount, '0')) AS 'TIME4',
 SUM(IF(l.in_time = '05', l.accesscount, '0')) AS 'TIME5',
 SUM(IF(l.in_time = '06', l.accesscount, '0')) AS 'TIME6',
 SUM(IF(l.in_time = '07', l.accesscount, '0')) AS 'TIME7',
 SUM(IF(l.in_time = '08', l.accesscount, '0')) AS 'TIME8',
 SUM(IF(l.in_time = '09', l.accesscount, '0')) AS 'TIME9',
 SUM(IF(l.in_time = '10', l.accesscount, '0')) AS 'TIME10',
 SUM(IF(l.in_time = '11', l.accesscount, '0')) AS 'TIME11',
 SUM(IF(l.in_time = '12', l.accesscount, '0')) AS 'TIME12',
 SUM(IF(l.in_time = '13', l.accesscount, '0')) AS 'TIME13',
 SUM(IF(l.in_time = '14', l.accesscount, '0')) AS 'TIME14',
 SUM(IF(l.in_time = '15', l.accesscount, '0')) AS 'TIME15',
 SUM(IF(l.in_time = '16', l.accesscount, '0')) AS 'TIME16',
 SUM(IF(l.in_time = '17', l.accesscount, '0')) AS 'TIME17',
 SUM(IF(l.in_time = '18', l.accesscount, '0')) AS 'TIME18',
 SUM(IF(l.in_time = '19', l.accesscount, '0')) AS 'TIME19',
 SUM(IF(l.in_time = '20', l.accesscount, '0')) AS 'TIME20',
 SUM(IF(l.in_time = '21', l.accesscount, '0')) AS 'TIME21',
 SUM(IF(l.in_time = '22', l.accesscount, '0')) AS 'TIME22',
 SUM(IF(l.in_time = '23', l.accesscount, '0')) AS 'TIME23',
 SUM(l.accesscount) AS 'TIMETOTAL'
 FROM %s l, %s a
 WHERE l.in_date=? AND l.acd=a.acd
 GROUP BY l.acd
 ORDER BY l.in_time", $targetTable, $masterTable);
=cut


my $sql = sprintf("SELECT DAYOFMONTH(l.in_date),  a.client_name,
 COUNT(IF(HOUR(l.in_datetime) = '0', l.in_date, NULL)) AS 'TIME0',
 COUNT(IF(HOUR(l.in_datetime) = '1', l.in_date, NULL)) AS 'TIME1',
 COUNT(IF(HOUR(l.in_datetime) = '2', l.in_date, NULL)) AS 'TIME2',
 COUNT(IF(HOUR(l.in_datetime) = '3', l.in_date, NULL)) AS 'TIME3',
 COUNT(IF(HOUR(l.in_datetime) = '4', l.in_date, NULL)) AS 'TIME4',
 COUNT(IF(HOUR(l.in_datetime) = '5', l.in_date, NULL)) AS 'TIME5',
 COUNT(IF(HOUR(l.in_datetime) = '6', l.in_date, NULL)) AS 'TIME6',
 COUNT(IF(HOUR(l.in_datetime) = '7', l.in_date, NULL)) AS 'TIME7',
 COUNT(IF(HOUR(l.in_datetime) = '8', l.in_date, NULL)) AS 'TIME8',
 COUNT(IF(HOUR(l.in_datetime) = '9', l.in_date, NULL)) AS 'TIME9',
 COUNT(IF(HOUR(l.in_datetime) = '10', l.in_date, NULL)) AS 'TIME10',
 COUNT(IF(HOUR(l.in_datetime) = '11', l.in_date, NULL)) AS 'TIME11',
 COUNT(IF(HOUR(l.in_datetime) = '12', l.in_date, NULL)) AS 'TIME12',
 COUNT(IF(HOUR(l.in_datetime) = '13', l.in_date, NULL)) AS 'TIME13',
 COUNT(IF(HOUR(l.in_datetime) = '14', l.in_date, NULL)) AS 'TIME14',
 COUNT(IF(HOUR(l.in_datetime) = '15', l.in_date, NULL)) AS 'TIME15',
 COUNT(IF(HOUR(l.in_datetime) = '16', l.in_date, NULL)) AS 'TIME16',
 COUNT(IF(HOUR(l.in_datetime) = '17', l.in_date, NULL)) AS 'TIME17',
 COUNT(IF(HOUR(l.in_datetime) = '18', l.in_date, NULL)) AS 'TIME18',
 COUNT(IF(HOUR(l.in_datetime) = '19', l.in_date, NULL)) AS 'TIME19',
 COUNT(IF(HOUR(l.in_datetime) = '20', l.in_date, NULL)) AS 'TIME20',
 COUNT(IF(HOUR(l.in_datetime) = '21', l.in_date, NULL)) AS 'TIME21',
 COUNT(IF(HOUR(l.in_datetime) = '22', l.in_date, NULL)) AS 'TIME22',
 COUNT(IF(HOUR(l.in_datetime) = '23', l.in_date, NULL)) AS 'TIME23',
 COUNT(l.in_date) AS 'TIMETOTAL'
 FROM %s l, %s a
 WHERE l.in_date=? AND l.acd=a.acd
 GROUP BY l.acd
 ORDER BY HOUR(l.in_datetime)", $targetTable, $masterTable);


        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');
        $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $targetPeriod);

            #***************************
            # 集計データをシリアライズしてパブリッシュ
            #***************************
            MyClass::WebUtil::publishObj({ file=>$publishobj, obj=>$aryref });
        }

        $obj->{LoopAccessCountLog} = $#{$aryref};

        if (0 > $obj->{LoopAccessCountLog}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopAccessCountLog}; $i++) {
                map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
                $obj->{cssstyle}->[$i] = 0 == $i % 2 ? 'focusodd' : 'focuseven';
            }
            $obj->{IfData} = 1;
            $obj->{sYEAR}  = $sYear;
            $obj->{sMONTH} = $sMonth;
            $obj->{sDATE}  = $sDate;
        }
        $obj->{IfAction} = 1;
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        会員登録集計（月ごと）
# @return    
#******************************************************
sub shukeiRegMember {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    $obj->{action} = $self->{action};
    my $pulldown   = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"-1,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{ $pulldown };

    if (defined ($q->param('year'))) {
        ## 集計対象
        my ($sYear, $sMonth);
        $sYear    = $q->param('year');
        $sMonth = $q->param('month');

        #*********************************
        # 対象月の日・曜日の生成
        #*********************************
        my $targetPeriod = sprintf ("%04d-%02s-01", $sYear, $sMonth);

## Modified アクセスがあった日は全て対象とするため 2009/06/04 BEGIN
        my $tAccessLogF_MONTH = 'tAccessLogF_' . sprintf("%4d%02d", $sYear, $sMonth);
        my $sql = sprintf("
CREATE TEMPORARY TABLE TMP(DDATE DATE, DMON CHAR(2))
 SELECT
 DISTINCT(DATE(a.in_datetime)) AS DDATE, DAYOFMONTH(a.in_datetime) AS DMON
 FROM %s a
 ORDER BY DDATE;", $tAccessLogF_MONTH);

## Modified アクセスがあった日は全て対象とするため 2009/06/04 END

        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');
        $dbh->do($sql);


## Modified 集計方法のSQLの修正 2009/06/05 BEGIN

        $sql = "SELECT DDATE, DMON,
 COUNT(IF(u.status_flag=2 AND u.carrier=2, u.id, NULL)) AS RD,
 COUNT(IF(u.status_flag=2 AND u.carrier=4, u.id, NULL)) AS RSB,
 COUNT(IF(u.status_flag=2 AND u.carrier=8, u.id, NULL)) AS RA,
 COUNT(IF(u.status_flag=2, u.id, NULL)) AS RTOTAL,
 COUNT(IF(u.status_flag=4 AND u.carrier=2, u.id, NULL)) AS WD,
 COUNT(IF(u.status_flag=4 AND u.carrier=4, u.id, NULL)) AS WSB,
 COUNT(IF(u.status_flag=4 AND u.carrier=8, u.id, NULL)) AS WA,
 COUNT(IF(u.status_flag=4, u.id, NULL)) AS WTOTAL
 FROM TMP
  LEFT JOIN tUserRegistLogF u
   ON DDATE=DATE(u.date_of_transaction)
  GROUP BY DMON WITH ROLLUP
";

        my $aryref = $dbh->selectall_arrayref($sql);

        #*********************************
        # 一時テーブルの削除
        #*********************************
        $sql = "DROP TABLE IF EXISTS TMP;";
        $dbh->do($sql);

        $obj->{LoopMember} = $#{$aryref};
        if (1 > $obj->{LoopMember}) {
            $obj->{ERRORMSG} = '集計データがありません。';
            $obj->{IfNoData} = 1;
        } else {
            for (my $i = 0; $i <= $obj->{LoopMember}; $i++) {
                if ($#{$aryref}==$i) {
                     $obj->{TRD}     = $aryref->[$i]->[2];
                     $obj->{TRSB}    = $aryref->[$i]->[3];
                     $obj->{TRA}     = $aryref->[$i]->[4];
                    $obj->{TRTOTAL}  = $aryref->[$i]->[5];
                     $obj->{TWD}     = $aryref->[$i]->[6];
                     $obj->{TWSB}    = $aryref->[$i]->[7];
                     $obj->{TWA}     = $aryref->[$i]->[8];
                     $obj->{TWTOTAL} = $aryref->[$i]->[9];
                }
                else {
                     $obj->{RD}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[2];
                     $obj->{RSB}->[$aryref->[$i]->[1]-1]    = $aryref->[$i]->[3];
                     $obj->{RA}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[4];
                     $obj->{RTOTAL}->[$aryref->[$i]->[1]-1] = $aryref->[$i]->[5];
                     $obj->{WD}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[6];
                     $obj->{WSB}->[$aryref->[$i]->[1]-1]    = $aryref->[$i]->[7];
                     $obj->{WA}->[$aryref->[$i]->[1]-1]     = $aryref->[$i]->[8];
                     $obj->{WTOTAL}->[$aryref->[$i]->[1]-1] = $aryref->[$i]->[9];
                }
            }

            $obj->{IfData} = 1;

            #*********************************
            # 対象月の日・曜日の生成 こちらに移動
            #*********************************
            my $calender = $self->createMonthTable ($sYear, $sMonth);
            map { $obj->{$_} = $calender->{$_} } keys %{ $calender };
        }
        $obj->{sYEAR}  = $sYear;
        $obj->{sMONTH} = $sMonth;
        $obj->{pMONTH} = $sMonth - 1;
        $obj->{nMONTH} = $sMonth + 1;
        $obj->{IfToPreviousMonth} = 1 < $sMonth  ? 1 : 0;
        $obj->{IfToNextMonth}     = 12 > $sMonth ? 1 : 0;
        #*********************************
        # IfActionブロックを有効にする
        #*********************************
        $obj->{IfAction} = 1;
    }

    return ($obj);
}


#******************************************************
# @access    public
# @desc        会員数を出す
# @return    
#******************************************************
sub countMember {
    my $self = shift;
    my $q = $self->query();

    my $obj = {};

    my $sql ="
SELECT 
 COUNT(IF(status_flag=2 AND sex=2 AND carrier=2,mid,NULL)) AS 'MDR',
 COUNT(IF(status_flag=2 AND sex=2 AND carrier=4,mid,NULL)) AS 'MSR',
 COUNT(IF(status_flag=2 AND sex=2 AND carrier=8,mid,NULL)) AS 'MAR',
 COUNT(IF(status_flag=2 AND sex=4 AND carrier=2,mid,NULL)) AS 'WDR',
 COUNT(IF(status_flag=2 AND sex=4 AND carrier=4,mid,NULL)) AS 'WSR',
 COUNT(IF(status_flag=2 AND sex=4 AND carrier=8,mid,NULL)) AS 'WAR',
 COUNT(IF(status_flag=2 AND sex=1 AND carrier=2,mid,NULL)) AS 'UDR',
 COUNT(IF(status_flag=2 AND sex=1 AND carrier=4,mid,NULL)) AS 'USR',
 COUNT(IF(status_flag=2 AND sex=1 AND carrier=8,mid,NULL)) AS 'UAR',
 COUNT(IF(status_flag=2 AND carrier=2,mid,NULL)) AS 'TDR',
 COUNT(IF(status_flag=2 AND carrier=4,mid,NULL)) AS 'TSR',
 COUNT(IF(status_flag=2 AND carrier=8,mid,NULL)) AS 'TAR',
 COUNT(IF(status_flag=2 AND sex=4,mid,NULL)) AS 'TWR',
 COUNT(IF(status_flag=2 AND sex=2,mid,NULL)) AS 'TMR',
 COUNT(IF(status_flag=2 AND sex=1,mid,NULL)) AS 'TUR',
 COUNT(IF(status_flag=2, mid, NULL)) AS 'TR',
 COUNT(IF(status_flag=4 AND sex=2 AND carrier=2,mid,NULL)) AS 'MDW',
 COUNT(IF(status_flag=4 AND sex=2 AND carrier=4,mid,NULL)) AS 'MSW',
 COUNT(IF(status_flag=4 AND sex=2 AND carrier=8,mid,NULL)) AS 'MAW',
 COUNT(IF(status_flag=4 AND sex=4 AND carrier=2,mid,NULL)) AS 'WDW',
 COUNT(IF(status_flag=4 AND sex=4 AND carrier=4,mid,NULL)) AS 'WSW',
 COUNT(IF(status_flag=4 AND sex=4 AND carrier=8,mid,NULL)) AS 'WAW',
 COUNT(IF(status_flag=4 AND sex=1 AND carrier=2,mid,NULL)) AS 'UDW',
 COUNT(IF(status_flag=4 AND sex=1 AND carrier=4,mid,NULL)) AS 'USW',
 COUNT(IF(status_flag=4 AND sex=1 AND carrier=8,mid,NULL)) AS 'UAW',
 COUNT(IF(status_flag=4 AND carrier=2,mid,NULL)) AS 'TDW',
 COUNT(IF(status_flag=4 AND carrier=4,mid,NULL)) AS 'TSW',
 COUNT(IF(status_flag=4 AND carrier=8,mid,NULL)) AS 'TAW',
 COUNT(IF(status_flag=4 AND sex=4,mid,NULL)) AS 'TWW',
 COUNT(IF(status_flag=4 AND sex=2,mid,NULL)) AS 'TMW',
 COUNT(IF(status_flag=4 AND sex=1,mid,NULL)) AS 'TUW',
 COUNT(IF(status_flag=4, mid, NULL)) AS 'TW'
 FROM JKZ_WAF.tMemberM;
";

    my $dbh = $self->getDBConnection();
    $dbh->do('USE JKZ_WAF');
    my $hashref = $dbh->selectrow_hashref ($sql);
    map { $obj->{$_} = $hashref->{$_} } keys %{ $hashref };

    ## 率を出す
## 会員
    $obj->{RTAR} = MyClass::WebUtil::Round((($obj->{TAR} / $obj->{TR}) * 100), 2);
    $obj->{RTSR} = MyClass::WebUtil::Round((($obj->{TSR} / $obj->{TR}) * 100), 2);
    $obj->{RTDR} = MyClass::WebUtil::Round((($obj->{TDR} / $obj->{TR}) * 100), 2);

    $obj->{RMAR} = MyClass::WebUtil::Round((($obj->{MAR} / $obj->{TMR}) * 100), 2);
    $obj->{RMSR} = MyClass::WebUtil::Round((($obj->{MSR} / $obj->{TMR}) * 100), 2);
    $obj->{RMDR} = MyClass::WebUtil::Round((($obj->{MDR} / $obj->{TMR}) * 100), 2);

    $obj->{RWAR} = MyClass::WebUtil::Round((($obj->{WAR} / $obj->{TWR}) * 100), 2);
    $obj->{RWSR} = MyClass::WebUtil::Round((($obj->{WSR} / $obj->{TWR}) * 100), 2);
    $obj->{RWDR} = MyClass::WebUtil::Round((($obj->{WDR} / $obj->{TWR}) * 100), 2);

    $obj->{RUAR} = MyClass::WebUtil::Round((($obj->{UAR} / $obj->{TUR}) * 100), 2);
    $obj->{RUSR} = MyClass::WebUtil::Round((($obj->{USR} / $obj->{TUR}) * 100), 2);
    $obj->{RUDR} = MyClass::WebUtil::Round((($obj->{UDR} / $obj->{TUR}) * 100), 2);

##退会
    $obj->{RTAW} = MyClass::WebUtil::Round((($obj->{TAW} / $obj->{TW}) * 100), 2);
    $obj->{RTSW} = MyClass::WebUtil::Round((($obj->{TSW} / $obj->{TW}) * 100), 2);
    $obj->{RTDW} = MyClass::WebUtil::Round((($obj->{TDW} / $obj->{TW}) * 100), 2);

    $obj->{RMAW} = MyClass::WebUtil::Round((($obj->{MAW} / $obj->{TMW}) * 100), 2);
    $obj->{RMSW} = MyClass::WebUtil::Round((($obj->{MSW} / $obj->{TMW}) * 100), 2);
    $obj->{RMDW} = MyClass::WebUtil::Round((($obj->{MDW} / $obj->{TMW}) * 100), 2);

    $obj->{RWAW} = MyClass::WebUtil::Round((($obj->{WAW} / $obj->{TWW}) * 100), 2);
    $obj->{RWSW} = MyClass::WebUtil::Round((($obj->{WSW} / $obj->{TWW}) * 100), 2);
    $obj->{RWDW} = MyClass::WebUtil::Round((($obj->{WDW} / $obj->{TWW}) * 100), 2);

    $obj->{RUAW} = MyClass::WebUtil::Round((($obj->{UAW} / $obj->{TUW}) * 100), 2);
    $obj->{RUSW} = MyClass::WebUtil::Round((($obj->{USW} / $obj->{TUW}) * 100), 2);
    $obj->{RUDW} = MyClass::WebUtil::Round((($obj->{UDW} / $obj->{TUW}) * 100), 2);

    return ($obj);
}



#******************************************************
# @access    public
# @desc        プルダウン
# @return    
#******************************************************
sub _createPeriodPullDown {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    my ($this_year, $this_month) = split(/-/, MyClass::WebUtil::GetTime(6));
    my @years   = (($this_year-1), $this_year, ($this_year+1));
    my @months  = (1..12); 
    $this_month = int($this_month);
    $obj->{years}  = $q->popup_menu(-name=>"year", -values=>[@years], -default=>$this_year);
    $obj->{months} = $q->popup_menu(-name=>"month", -values=>[@months], -default=>$this_month);

    return ($obj);
}


1;

__END__
