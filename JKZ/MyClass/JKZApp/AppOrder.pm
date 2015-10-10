#******************************************************
# @desc      商品注文管理クラス
# @package   MyClass::JKZApp::AppOrder
# @access    public
# @author    Iwahase Ryo
# @create    2010/02/12
# @version   1.00
#******************************************************
package MyClass::JKZApp::AppOrder;

use 5.008005;
our $VERSION = '1.00';
use strict;

use Data::Dumper;

use base qw(MyClass::JKZApp);

use MyClass::JKZDB::OrderData;
use MyClass::JKZDB::OrderDetail;
use MyClass::JKZDB::NOrderDetail;
use MyClass::JKZDB::Member;
use MyClass::JKZDB::Product;



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
    !defined($self->query->param('action')) ? $self->action('orderTopMenu') : $self->action();
    $self->SUPER::dispatch();
}


sub orderTopMenu {
    my $self = shift;
    $self->action('orderTopMenu');
    return;
}


#******************************************************
# @access    public
# @desc      受注処理
# @param    
#******************************************************
sub searchOrder {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    my $dbh  = $self->getDBConnection();


    my %condition = ();
    $condition{columnslist} = ['ordernum', 'guid', 'owid', 'orderstatus_flag', 'used_point', 'family_name', 'first_name', 'order_date'];

    #*************************
    # 検索条件生成
    #*************************
    my @searchquery;
    ## 検索条件の内容
    my @searchquerymessage;
    my ($ordernum, $owid, $orderstatus_flag,);

    my $cookie_name = $self->{cfg}->param('COOKIE_NAME') . 'searchcondition';

    my $record_limit    = 50;
    my $offset          = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $MAXREC_SQL = "SELECT COUNT(ordernum) FROM JKZ_WAF.tOrderDetailF ";

    ## 全共通のSQL カラムは id ordernum orderstatus_flag owid product_id qty point product_name family_name first_name
    my $BASE_SQL = "SELECT
 df.id, df.ordernum, df.orderstatus_flag, df.owid, df.product_id, df.qty, df.point,
 p.product_name,
 o.family_name, o.first_name, o.order_date
 FROM tOrderDataF o, tOrderDetailF df LEFT JOIN tProductM p
  ON df.product_id=p.product_id
 WHERE 
  df.ordernum = o.ordernum
";

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
         # 注文番号
         #*************************
        if ($q->param('ordernum')) {
            $ordernum = $q->param('ordernum');
            ( push(@searchquery, 'df.ordernum = ?') && push(@{ $condition{placeholder} }, $ordernum) );
            push(@searchquerymessage, "注文番号：[ $ordernum ]");
        } else {
            push @searchquerymessage, "注文番号：[ 指定なし ]";
        }

         #*************************
         # 会員ID
         #*************************
        if ($q->param('owid')) {
            $owid = $q->param('owid');
            ( push(@searchquery, 'df.owid = ?') && push(@{ $condition{placeholder} }, $owid) );
            push(@searchquerymessage, "会員ID：[ $owid ]");
        } else {
            push @searchquerymessage, "会員ID：[ 指定なし ]";
        }

         #*************************
         # 商品ID
         #*************************
        if ($q->param('product_id')) {
            my @ary_product_id;
            my $product_id_placeholder;
            my @param = $q->param('product_id');
            if (0 < $#param) {
                #$ary_product_id        = join(',', @param);
                @ary_product_id         = @param;
                $product_id_placeholder = ',?' x $#ary_product_id;
            }
            else {
                my $product_id          = $param[0];
                $product_id         =~ s/^[\s|,]+//g;
                $product_id         =~ s/[\s|,]+$//g;
                $product_id         =~ s/[\s|,]+/,/g;
                @ary_product_id        = split(/,/, $product_id);
                $product_id_placeholder = ',?' x $#ary_product_id;
            }

            push(@searchquery, sprintf("df.product_id IN(?%s)", $product_id_placeholder));

            push(@{ $condition{placeholder} }, @ary_product_id);

            push(@searchquerymessage, sprintf("商品ID：[ %s ]", join(' ', @ary_product_id)));

        } else {
            push @searchquerymessage, "商品ID：[ 指定なし ]";
        }

         #*************************
         # 状態 1 未処理・新規 2 確認済・処理中 4 発送待・処理待ち 8 発送済・処理完了 16 キャンセル
         # 現在使用しているステータス値は 1 8 
         #*************************
        if ($q->param('orderstatus_flag')) {
            #map { $orderstatus_flag += 2 ** $_ } $q->param('orderstatus_flag');
            map { $orderstatus_flag += $_ } $q->param('orderstatus_flag');
            unless (9 == $orderstatus_flag) {
                push(@searchquery, 'df.orderstatus_flag = ?');
                push(@{ $condition{placeholder} }, $orderstatus_flag);
                push( @searchquerymessage, ( 1 == $orderstatus_flag ? "状態：[ <font style='color:#ff0000;'>新規・未処理</font> ]" : 8 == $orderstatus_flag ? "状態：[ 発送済・処理完了 ]" : "状態：[ 未確定ステータス ]" ) );
            }
            if (9 <= $orderstatus_flag) {
                push(@searchquery, 'df.orderstatus_flag & ?');
                push(@{ $condition{placeholder} }, $orderstatus_flag);
            }
#                push( @searchquerymessage, (2 == $status_flag ? "状態：[ 会員 ]" : "会員状態：[ 退会会員 ]") );
#            } else {
#                push @searchquerymessage, "状態：[ 指定無し ]";
#            }
        }




        #*************************
        # 注文日 期間
        #*************************
        if ($q->param('year_from') eq '') {
            push @searchquerymessage, "注文日時下限：[ 指定なし ]";
        } else {
            my $from_yyyymmdd = sprintf("%04d-%02d-%02d", $q->param('year_from'), $q->param('month_from'), $q->param('date_from'));
            ( push(@searchquery , "order_date >= ?") && push(@{ $condition{placeholder} }, $from_yyyymmdd) );
            push @searchquerymessage, "注文日時下限：[ $from_yyyymmdd ]";
        }
        if ($q->param('year_to') eq ''){
            push @searchquerymessage, "注文日時上限：[ 指定なし ]";
        } else {
            my $to_yyyymmdd = sprintf("%04d-%02d-%02d", $q->param('year_to'), $q->param('month_to'), $q->param('date_to'));
            ( push(@searchquery , "order_date <= ?") && push(@{ $condition{placeholder} }, $to_yyyymmdd) );
            push @searchquerymessage, "注文日時上限：[ $to_yyyymmdd ]";
        }

        $obj->{SEARCHQUERYMESSAGE} = join('　', @searchquerymessage);


        $condition{whereSQL} = sprintf "%s", join(' AND ', @searchquery);

        my @ORDERBY = ('o.order_date', 'df.orderstatus_flag', 'p.product_id',);

        $condition{orderbySQL} = sprintf("%s ", $ORDERBY[$q->param('order_by')-1]);
#$condition{orderbySQL} = " df.ordernum DESC";

        #$MAXREC_SQL .= sprintf(" %s%s", (0 < @searchquery ? "WHERE " : ""),join(' AND ', @searchquery));
        $MAXREC_SQL .= sprintf(" %s", join(' AND ', @searchquery));

        my $cookiesql = join(' AND ', @searchquery);
        $cookiesql   .= sprintf("::%s", $obj->{SEARCHQUERYMESSAGE});
        $cookiesql   .= sprintf("\, %s", $condition{orderbySQL});
        $cookiesql   .= "\,@{ $condition{placeholder} }" if defined(@{ $condition{placeholder} });

        $self->{cookie} = $self->query->cookie(
                            -name  => $cookie_name,
                            -value => $cookiesql,
                            -path  =>    '/',
                          );

    }

        #$condition{orderbySQL} = 'ordernum DESC';
        $condition{limitSQL} = "$offset, $condition_limit";

$BASE_SQL .= sprintf(" AND %s ORDER BY %s LIMIT %s",  join(' AND ', @searchquery), $condition{orderbySQL}, $condition{limitSQL});


        #*********************************
        ## ページ数表示リンクのナビ
        #*********************************
        my @navilink;
        my $maxrec = $dbh->selectrow_array($MAXREC_SQL, undef, @{ $condition{placeholder} });

        ## レコード数が1ページ上限数より多い場合
        if ($maxrec > $record_limit) {

            my $url = 'app.mpl?app=AppOrder;action=searchOrder;search=1';

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

        my $aryref = $dbh->selectall_arrayref($BASE_SQL, { Columns => {} }, @{ $condition{placeholder} });

        $obj->{LoopSearchOrderList} = ( $#{ $aryref } >= $record_limit ) ? $#{ $aryref }-1 : $#{ $aryref };
        if (0 <= $obj->{LoopSearchOrderList}) {
            map {
                foreach my $key (%{ $aryref->[$_] }) {
                    $obj->{$key}->[$_] = $aryref->[$_]->{$key};
                }

               $obj->{order_date}->[$_] = MyClass::WebUtil::formatDateTimeSeparator($obj->{order_date}->[$_], {sepfrom => '-', septo => '/', offset => 2, limit => 14});

## orderstatus_flagは1は未発送 8は完了
                $obj->{IfNotDelivered}->[$_] = 1 if 1 == $obj->{orderstatus_flag}->[$_];
                $obj->{IfDelivered}->[$_] = 1 if 8 == $obj->{orderstatus_flag}->[$_];
                $obj->{orderstatus_flagImages}->[$_]  = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{orderstatus_flag}->[$_]-1));
$obj->{cssstyle}->[$_] = (0 == $_ %2) ? 'focusodd' : 'focuseven';
            } 0..$obj->{LoopSearchOrderList};

           $obj->{hit_record} = $obj->{LoopSearchOrderList}+1;
           $obj->{IfSearchResultExists} = 1;
        }
	else {
        $obj->{IfSearchResultNotExists} = 1 if 0 > $obj->{LoopSearchOrderList};
        $obj->{IfSearchExecuted} = 1;
    }

    return $obj;

}


#******************************************************
# @access    public
# @desc      注文詳細
# @param    
#******************************************************
sub detailOrder {
    my $self = shift;
    my $q    = $self->query();
    my ($ordernum, $id) = split(/:/, $q->param('ordernum'));
    my $obj  = {};

=pod
    my $sql  = "SELECT d.order_date, df.point AS product_point, df.qty,SUM(df.point*df.qty) AS goukei, p.product_name 
  FROM JKZ_WAF.tOrderDataF d, JKZ_WAF.tOrderDetailF df, tProductM p
   WHERE (d.ordernum=? AND d.ordernum=df.ordernum) AND p.product_id=df.product_id
 GROUP BY d.ordernum;
";
=cut
    my $sql;
    my $dbh  = $self->getDBConnection();
    my $orderdata = MyClass::JKZDB::OrderData->new($dbh);
    $orderdata->executeSelect({whereSQL => 'ordernum=?', placeholder=>[$ordernum]});
    map { $obj->{$_} = $orderdata->{columns}->{$_} } keys %{ $orderdata->{columns} };

    $obj->{prefectureDescription}  = $self->fetchOneValueFromConf('PREFECTURE', log($obj->{prefecture}) / log(2));
    
=pod

    $sql = "SELECT * FROM tOrderDataF where ordernum=?";

=cut
    $sql = "SELECT df.owid, df.ordernum, df.orderstatus_flag, df.product_id, df.qty, df.point, df.deliver_date,
  p.product_name FROM tOrderDetailF df LEFT JOIN tProductM p
  ON df.product_id=p.product_id
  WHERE df.ordernum=? AND df.id=?;";


    my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $ordernum, $id);

    $obj->{LoopOrderList} = $#{ $aryref };
no strict 'refs';
    if (0 <= $#{$aryref}) {
        $obj->{IfExistsOrder} = 1;


        map {
            my $i = $_;
            foreach my $key (keys %{ $aryref->[$i] }) {
                $obj->{$key}->[$i] = $aryref->[$i]->{$key};
            }

            $obj->{sum_point}->[$i] = $obj->{point}->[$i] * $obj->{qty}->[$i];
            $obj->{IfNotDelivered}->[$i] = 1 if 1 == $obj->{orderstatus_flag}->[$i];
            $obj->{IfDelivered}->[$i]    = 1 if 8 == $obj->{orderstatus_flag}->[$i];
            $obj->{order_date}->[$i] = MyClass::WebUtil::formatDateTimeSeparator($obj->{order_date}, {sepfrom => '-', septo => '/', offset => 2, limit => 14});
#            $obj->{point}->[$i]      = MyClass::WebUtil::insertComma($obj->{point}->[$i]);
#            $obj->{goukei}->[$i]     = MyClass::WebUtil::insertComma($obj->{goukei}->[$i]);
        } 0..$obj->{LoopOrderList};


       ## orderstatus_flagは1は未発送 8は完了 今回は商品ごとに注文状態を管理するので上記ループで
       #$obj->{IfNotDelivered} = 1 if 1 == $obj->{orderstatus_flag};
       #$obj->{IfDelivered} = 1 if 8 == $obj->{orderstatus_flag};

    }
    else {
        $obj->{IfNotExistsOrder} = 1;
    }

$obj->{DUMP} = Dumper($obj);

    return $obj;
}


#******************************************************
# @access    public
# @desc      注文状態更新
# @param    
#******************************************************
sub updateStatus {
    my $self     = shift;
    my $q        = $self->query();

    ## Getでの処理は受け付けない
    #if (!$q->MethPost()) {
    #    $self->action('orderTopMenu');
    #    return $self->orderTopMenu();
    #}

    my $ordernum     = $q->param('ordernum');
    my $id           = $q->param('id');
    my $orderstatus  = $q->param('orderstatus');
    my $deliver_date = ( 8 == $orderstatus ) ? MyClass::WebUtil::GetTime(10) : '';
    my $dbh = $self->getDBConnection();
    my $status = MyClass::JKZDB::OrderDetail->new($dbh);

    $status->updateStatus({ordernum => $ordernum, id => $id, orderstatus_flag => $orderstatus , deliver_date => $deliver_date});

    $self->action('orderTopMenu');
    return $self->orderTopMenu();

}


1;
__END__
