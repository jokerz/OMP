#******************************************************
# @desc      商品管理クラス(カテゴリも同居)
# @package   MyClass::JKZApp::AppProduct
# @access    public
# @author    Iwahase Ryo
# @create    2010/01/15
# @update    2010/01/21  fetchSmallCategoryメソッド追加
# @version   1.00
#******************************************************
package MyClass::JKZApp::AppProduct;

use 5.008005;
our $VERSION = '1.00';
use strict;

use base qw(MyClass::JKZApp);

use MyClass::JKZDB::Category;
use MyClass::JKZDB::SubCategory;
use MyClass::JKZDB::SmallCategory;
use MyClass::JKZDB::Product;
use MyClass::JKZDB::ProductImage;
use MyClass::JKZDB::ProductSwf;
use MyClass::JKZDB::ProductDecoTmplt;

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
    !defined($self->query->param('action')) ? $self->action('productTopMenu') : $self->action();
    $self->SUPER::dispatch("IfAppProduct");
}


#******************************************************
# @access    public
# @desc        商品管理トップメニュー
# @desc        だけど、基本的に検索はデフォルトで必要だから、searchProductメソッド内で呼び出す
# @param    
#******************************************************
sub productTopMenu {
    my $self = shift;

    my $memcached = $self->initMemcachedFast();
    my $obj = $memcached->get("JKZ_WAFCountProductCategory");
    if (!$obj) {
        my $dbh = $self->getDBConnection();
        ($obj->{validCategory}, $obj->{invalidCategory}, $obj->{totalCategory})          = $dbh->selectrow_array("SELECT COUNT(IF(status_flag=2,category_id,NULL)) AS validCategory, COUNT(IF(status_flag=1,category_id,NULL)) AS invalidCategory, COUNT(category_id) AS totalCategory FROM JKZ_WAF.tCategoryM;");
        ($obj->{validSubCategory}, $obj->{invalidSubCategory}, $obj->{totalSubCategory}) = $dbh->selectrow_array("SELECT COUNT(IF(status_flag=2,subcategory_id,NULL)) AS validSubCategory, COUNT(IF(status_flag=1,subcategory_id,NULL)) AS invalidSubCategory, COUNT(subcategory_id) AS totalSubCategory FROM JKZ_WAF.tSubCategoryM;");
        ($obj->{validProduct}, $obj->{invalidProduct}, $obj->{totalProduct})             = $dbh->selectrow_array("SELECT COUNT(IF(status_flag=2,product_id,NULL)) AS validProduct, COUNT(IF(status_flag=1,product_id,NULL)) AS invalidProduct, COUNT(product_id) AS totalProduct FROM JKZ_WAF.tProductM;");

        my $sql = "SELECT s.category_name, s.subcategory_name, s.subcategory_id,
 COUNT(IF(p.status_flag=2, p.product_id, NULL)) AS ACNT,
 COUNT(IF(p.status_flag=1, p.product_id, NULL)) AS ANCNT,
 COUNT(p.product_id) AS CNT
 FROM tSubCategoryM s, tProductM p
 WHERE s.subcategory_id=p.subcategorym_id GROUP BY s.subcategory_id;";


        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} });
        $obj->{LoopProductList} = $#{$aryref};
=pod
        foreach my $cnt (0..$#{$aryref}) {
            map { $obj->{$_}->[$cnt] = $aryref->[$cnt]->{$_} } keys %{ $aryref };
            $obj->{cssstyle}->[$cnt] = 0 != $cnt % 2 ? 'focusodd' : 'focuseven';
            0 < $obj->{ACNT}->[$cnt]  ? $obj->{IfExistsACNT}->[$cnt]  = 1 : $obj->{IfNotExistsACNT}->[$cnt]  = 1;
            0 < $obj->{ANCNT}->[$cnt] ? $obj->{IfExistsANCNT}->[$cnt] = 1 : $obj->{IfNotExistsANCNT}->[$cnt] = 1;
        }
=cut
        map {
            my $cnt = $_;
            foreach my $key (keys %{ $aryref }) {
                $obj->{$key}->[$cnt] = $aryref->[$cnt]->{$key};
            }
            $obj->{cssstyle}->[$cnt] = 0 != $cnt % 2 ? 'focusodd' : 'focuseven';
            0 < $obj->{ACNT}->[$cnt]  ? $obj->{IfExistsACNT}->[$cnt]  = 1 : $obj->{IfNotExistsACNT}->[$cnt]  = 1;
            0 < $obj->{ANCNT}->[$cnt] ? $obj->{IfExistsANCNT}->[$cnt] = 1 : $obj->{IfNotExistsANCNT}->[$cnt] = 1;

        } 0..$obj->{LoopProductList};

        $memcached->add("JKZ_WAFCountProductCategory", $obj, 600);
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        商品カテゴリリスト
# @param    
#******************************************************
sub fetchCategory {
    my $self = shift;

    my $memcached = $self->initMemcachedFast();
    my $obj       = $memcached->get("JKZ_WAFAppCategorylist");
    if (!$obj) {
        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');

        my $cmsCategorylist = MyClass::JKZDB::Category->new($dbh);
        $cmsCategorylist->executeSelectList();
        map { $obj->{$_} = $cmsCategorylist->{columnslist}->{$_} } keys %{$cmsCategorylist->{columnslist}};

        $memcached->add("JKZ_WAFAppCategorylist", $obj, 600);

        undef($cmsCategorylist);
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc      商品サブカテゴリリスト
# @param    
#******************************************************
sub fetchSubCategory {
    my $self = shift;

    my $memcached = $self->initMemcachedFast();
    my $obj = $memcached->get("JKZ_WAFAppSubcategorylist");

    if (!$obj) {
        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');

        my $cmsSubCategorylist = MyClass::JKZDB::SubCategory->new($dbh);
        #$cmsSubCategorylist->executeSelectList({limitstr    => "$offset, $condition_limit"});
        $cmsSubCategorylist->executeSelectList();
        map { $obj->{$_} = $cmsSubCategorylist->{columnslist}->{$_} } keys %{$cmsSubCategorylist->{columnslist}};

        #$memcached->add($cached_off_limit, $obj, 600);
        $memcached->add("JKZ_WAFAppSubcategorylist", $obj, 600);

        undef($cmsSubCategorylist);
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc      商品小カテゴリリスト
# @param    
#******************************************************
sub fetchSmallCategory {
    my $self = shift;

    my $memcached = $self->initMemcachedFast();
    my $obj = $memcached->get("JKZ_WAFAppSmallcategorylist");

    if (!$obj) {
        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');

        my $cmsSmallCategorylist = MyClass::JKZDB::SmallCategory->new($dbh);
        #$cmsSubCategorylist->executeSelectList({limitstr    => "$offset, $condition_limit"});
        $cmsSmallCategorylist->executeSelectList();
        map { $obj->{$_} = $cmsSmallCategorylist->{columnslist}->{$_} } keys %{$cmsSmallCategorylist->{columnslist}};

        #$memcached->add($cached_off_limit, $obj, 600);
        $memcached->add("JKZ_WAFAppSmallcategorylist", $obj, 600);

        undef($cmsSmallCategorylist);
    }

    return $obj;
}

#************************************************************************************************************
# @desc        商品データ関連
#************************************************************************************************************

#******************************************************
# @access    public
# @desc        商品一覧
# @param    
#******************************************************
sub viewProductList {
    my $self = shift;

    my $q = $self->query();
    my $record_limit    = 20;
    my $offset          = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $obj = {};

    my $dbh = $self->getDBConnection();

        ## 全レコード件数SQL
=pod
        my $MAXREC_SQL = "SELECT
 COUNT(p.product_id)
 FROM JKZ_WAF.tProductM p
 LEFT JOIN JKZ_WAF.tCategoryM c ON p.categorym_id=POW(2,c.category_id)
";
=cut
        my $MAXREC_SQL = "SELECT
 COUNT(p.product_id)
 FROM JKZ_WAF.tProductM p
 LEFT JOIN JKZ_WAF.tCategoryM c ON p.categorym_id=c.category_id
";

    my @navilink;

    my $maxrec = $dbh->selectrow_array($MAXREC_SQL);

    ## レコード数が1ページ上限数より多い場合
    if ($maxrec > $record_limit) {

    my $url = '/app.mpl?app=AppProduct;action=viewProductList';

    ## 前へページの生成
        if (0 == $offset) { ## 最初のページの場合
            push(@navilink, "<font size=-1>&lt;&lt;前</font>&nbsp;");
        } else { ## 2ページ目以降の場合
            push(@navilink, $self->genNaviLink($url, "<font size=-1>&lt;&lt;前</font>&nbsp;", $offset - $record_limit));
        }

    ## ページ番号生成
        for (my $i = 0; $i < $maxrec; $i += $record_limit) {

            my $pageno = int ($i / $record_limit) + 1;

            if ($i == $offset) { ###現在表示してるﾍﾟｰｼﾞ分
                push (@navilink, '<font size=+1>' . $pageno . '</font>');
            } else {
                push (@navilink, $self->genNaviLink($url, $pageno, $i));
            }
        }

    ## 次へページの生成
        if (($offset + $record_limit) > $maxrec) {
            push (@navilink, "&nbsp;<font size=-1>次&gt;&gt;</font>");
        } else {
            push (@navilink, $self->genNaviLink($url, "&nbsp;<font size=-1>次&gt;&gt;</font>", $offset + $record_limit));
        }

        @navilink = map{ "$_\n" } @navilink;

        $obj->{pagenavi} = sprintf("<font size=-1>[全%s件 / %s件\表\示]</font><br />", $maxrec, $record_limit) . join(' ', @navilink);
    }

    my $ProductList = MyClass::JKZDB::Product->new($dbh);
    $ProductList->executeSelectList({
        orderbySQL => 'registration_date DESC',
        limitSQL   => "$offset, $condition_limit",
    });

    $obj->{LoopProductList} = ($record_limit == $ProductList->countRecSQL()) ? $record_limit-1 : $ProductList->countRecSQL();
    if (0 <= $ProductList->countRecSQL()) {
        $obj->{IfExistsProductList} = 1;
        map {

            my $i = $_;
            foreach my $key (keys %{ $ProductList->{columnslist} }) {
                $obj->{$key}->[$i] = $ProductList->{columnslist}->{$key}->[$i];
            }
            $obj->{status_flagDescription}->[$i] = $self->fetchOneValueFromConf('STATUS', ($obj->{status_flag}->[$i]-1));
            $obj->{status_flagImages}->[$i]      = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$i]-1));
            $obj->{description}->[$i]            = MyClass::WebUtil::escapeTags($obj->{description}->[$i]);
            $obj->{registration_date}->[$i]      =~ s!-!/!g;
            $obj->{registration_date}->[$i]      = substr($obj->{registration_date}->[$i] , 2, 9);

        } 0..$obj->{LoopProductList};

        $obj->{rangeBegin} = ($offset+1);
        $obj->{rangeEnd}   = ($obj->{rangeBeginCT}+$obj->{LoopProductList});

        if ($record_limit == $obj->{LoopProductList}) {
            $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
            $obj->{IfNextData}   = 1;
        }
        if ($record_limit <= $offset) {
            $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
            $obj->{IfPreviousData}   = 1;
        }
    }
    else {
        $obj->{IfNotExistsProductList} = 1;
    }

    return  $obj;
}


#******************************************************
# @access    public
# @desc        商品検索/商品管理デフォルト表示
# @param    
#******************************************************
sub searchProduct {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    ## 検索フォーム内のカテゴリループと検索結果の商品ループで属性名がかぶるから検索フォームにはs_を付与
    my $skey = 's_';

#***************************
# カテゴリリスト
#***************************
    my $categorylist = $self->getCategoryFromObjectFile();
    $obj->{LoopCategoryList}  = $#{ $categorylist } - 1;
    map {
        $obj->{$skey . 'category_id'}->[$_]   = $categorylist->[$_+1]->{'category_id'};
        $obj->{$skey . 'category_name'}->[$_] = $categorylist->[$_+1]->{'category_name'};
    } 0..$obj->{LoopCategoryList};

#***************************
# サブカテゴリリスト
#***************************
    my $subcategorylist = $self->getSubCategoryFromObjectFile();
    $obj->{LoopSubCategoryList} = $#{ $subcategorylist } - 1;
    map {
        my $i = $_;
        $obj->{$skey . 'subcategory_id'}->[$i] = $subcategorylist->[$i+1]->{'subcategory_id'};
        $obj->{$skey . 'subcategory_name'}->[$i] = $subcategorylist->[$i+1]->{'subcategory_name'};
    } 0..$obj->{LoopSubCategoryList};

#***************************
# 小カテゴリリスト
#***************************
    my $smallcategorylist = $self->getSmallCategoryFromObjectFile();
    $obj->{LoopSmallCategoryList} = $#{ $smallcategorylist } - 1;
    map {
        my $i = $_;
        $obj->{$skey . 'smallcategory_id'}->[$i] = $smallcategorylist->[$i+1]->{'smallcategory_id'};
        $obj->{$skey . 'smallcategory_name'}->[$i] = $smallcategorylist->[$i+1]->{'smallcategory_name'};
    } 0..$obj->{LoopSmallCategoryList};

    my @charge_flag = $self->fetchArrayValuesFromConf('CHARGE_FLAG');
    $obj->{LoopChargeFlagList} = $#charge_flag;
    map {

     $obj->{$skey . 'charge_flag'}->[$_] = $_;
     $obj->{$skey . 'charge_flag_name'}->[$_] = $charge_flag[$_];

    } 0..$obj->{LoopChargeFlagList};

    my $pulldown = $self->createPeriodPullDown({year=>"years", month=>"months", date=>"dates", range=>"-2,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
    $pulldown = $self->createPeriodPullDown({year=>"toyears", month=>"tomonths", date=>"todates", range=>"-2,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};

    if ($q->param('search') and 'searchProduct' eq $q->param('action')) {
        my $record_limit    = 20;
        my $offset          = $q->param('off') || 0;
        my $condition_limit = $record_limit+1;

        ## 共通SQL部分
        my $SQL = "SELECT
 p.product_id,
 p.status_flag,
 p.charge_flag,
 p.point_flag,
 p.latest_flag,
 p.recommend_flag,
 LEFT(p.product_name, 30) AS product_name,
 p.categorym_id,
 p.subcategorym_id,
 LEFT(p.description, 30) AS description,
 p.tanka,
 p.point,
 p.registration_date,
 LEFT(sc.category_name, 8) AS category_name,
 LEFT(sc.subcategory_name, 8) AS subcategory_name,
 LEFT(sc.smallcategory_name, 8) AS smallcategory_name
 FROM JKZ_WAF.tProductM p LEFT JOIN JKZ_WAF.tSmallCategoryM sc ON p.smallcategorym_id=sc.smallcategory_id
";

        ## 全レコード件数SQL
        my $MAXREC_SQL = "SELECT
 COUNT(p.product_id)
 FROM JKZ_WAF.tProductM p
 LEFT JOIN JKZ_WAF.tCategoryM c ON p.categorym_id=c.category_id
";

        ## placeholderの初期化
        my @placeholder;

        ## Modified パラメータに検索があり、かつGETの場合はリンクからの遷移のためクッキーを参照 2009/05/29 BEGIN
        #***************************
        ## 検索条件SQLの生成
        #***************************
        if ($q->MethGet() && defined($q->param('off'))) {
            my $cookie = $q->cookie('JKZ_WAFCMSsearchProduct');
        ## SQL文をくっきーにカンマで区切って格納するとSQL文のPOW(2,←このカンマで検索失敗するからセミコロンに変更) 2010/02/10
        ## 下記563行目付近と連動
            #my ($whereSQL, $orderbySQL, $holder) = split (/,/, $cookie);
            my ($whereSQL, $orderbySQL, $holder) = split (/;/, $cookie);
            @placeholder = split(/ /, $holder) if $holder;
            $SQL .= sprintf(" WHERE %s", $whereSQL) if "" ne $whereSQL;
            $SQL .= $orderbySQL;
            $MAXREC_SQL .= sprintf(" WHERE %s", $whereSQL) if "" ne $whereSQL;

        }
        else {

            my @whereSQL;
            my ($product_id, $sum_status_flag, $sum_charge_flag, $sum_point_flag, $sum_latest_flag, $sum_recommend_flag, $sum_categoryid, $sum_subcategory_id, $sum_smallcategory_id);
            map { $sum_status_flag      += $_ } $q->param('status_flag');
            map { $sum_charge_flag      += 2 ** $_ } $q->param('charge_flag');
            map { $sum_point_flag       += $_ } $q->param('point_flag');
            map { $sum_latest_flag      += $_ } $q->param('latest_flag');
            map { $sum_recommend_flag   += $_ } $q->param('recommend_flag');
            map { $sum_categoryid       += 2 ** $_ } $q->param('category_id') if $q->param('category_id');
            map { $sum_subcategory_id   += 2 ** $_ } $q->param('subcategory_id') if $q->param('subcategory_id');
            map { $sum_smallcategory_id += 2 ** $_ } $q->param('smallcategory_id') if $q->param('samllcategory_id');

            #*********************************
            # 商品コード検索条件SQLの生成
            #*********************************
            if ($q->param('product_id')) {
                $product_id = $q->param('product_id');
                push(@whereSQL, 'p.product_id = ?');
                push(@placeholder, $product_id);
            }

            #*********************************
            # 状態検索条件SQLの生成
            #*********************************
            if (3 > $sum_status_flag && 0 < $sum_status_flag) {
                push(@whereSQL, 'p.status_flag = ?');
                push(@placeholder, $sum_status_flag);
            }

            #*********************************
            # コンテンツの販売・配信検索条件SQLの生成
            # 現状は1=無料 2=pointで販売 4=現金で販売なので合計が７
            #*********************************
            if (7 > $sum_charge_flag && 0 < $sum_charge_flag) {
                push(@whereSQL, 'p.charge_flag & ?');
                push(@placeholder, $sum_charge_flag);
            }

            #*********************************
            # 新着表示検索条件SQLの生成 20100301に条件追加 
            #*********************************
=pod
            if (3 > $sum_latest_flag && 0 < $sum_latest_flag) {
                push(@whereSQL, 'p.latest_flag = ?');
                push(@placeholder, $sum_latest_flag);
            }
=cut
            if (7 > $sum_latest_flag && 0 < $sum_latest_flag) {
                push(@whereSQL, 'p.latest_flag & ?');
                push(@placeholder, $sum_latest_flag);
            }

            #*********************************
            # おすすめ表示検索条件SQLの生成
            #*********************************
            if (3 > $sum_recommend_flag && 0 < $sum_recommend_flag) {
                push(@whereSQL, 'p.recommend_flag = ?');
                push(@placeholder, $sum_recommend_flag);
            }

            #*********************************
            # ポイント還元検索条件SQLの生成
            #*********************************
            if (3 > $sum_point_flag && 0 < $sum_point_flag) {
                push(@whereSQL, 'p.point_flag = ?');
                push(@placeholder, $sum_point_flag);
            }

            #*********************************
            # 全文検索条件SQLの生成
            #*********************************
            if ($q->param('keyword')) {
                my ($keyword, $exclusion, $multicondition);
                $obj->{Skeyword}  = $q->param('keyword');
                $obj->{Sexlusion} = $q->param('exclusion');
            ## Modified 上のはタイプミスっぽいのんで  2009
                $obj->{Sexclusion}= $q->param('exclusion');

                #*********************************
                # キーワードが複数の場合でAND検索時はスペースを+に置き換え
                #*********************************
                ## 全角スペースはカンマに変換
                $keyword = MyClass::WebUtil::convertSZSpace2C($q->param('keyword'));
                2 == $q->param('opt') ? $keyword =~ s!,! \+!g : $keyword =~ s!,! !g;

                #*********************************
                # 除外ｷｰﾜｰどの処理
                # 除外ｷｰﾜｰどがある場合は-()でくくる
                #*********************************
                $exclusion = $q->param('exclusion') ? ' -(' . $q->param('exclusion') . ')' : undef;

                #*********************************
                # マルチセクション全文検索構文生成
                #*********************************
                $multicondition = sprintf("*W1,2 %s%s ", $keyword, $exclusion);
                push(@whereSQL, 'MATCH(p.product_name, p.description_detail) AGAINST(? IN BOOLEAN MODE)');
                push(@placeholder, $multicondition);
            }

            #*********************************
            # カテゴリ検索条件SQLの生成 ビット演算に対応 2010/01/15
            #*********************************
            if (0 < $sum_categoryid) {
                push(@whereSQL, "POW(2, p.categorym_id) & ?");
                push(@placeholder, $sum_categoryid);
            }

            #*********************************
            # サブカテゴリ索条件SQLの生成
            #*********************************
            if ( 0 < $sum_subcategory_id ) {
                push(@whereSQL, "POW(2, p.subcategorym_id) & ?");
                push(@placeholder, $sum_subcategory_id);
            }

            #*********************************
            # 小カテゴリ索条件SQLの生成
            #*********************************
            if ( 0 < $sum_smallcategory_id ) {
                push(@whereSQL, "POW(2, p.smallcategorym_id) & ?");
                push(@placeholder, $sum_smallcategory_id);
            }

            #*********************************
            # 期間指定検索条件SQLの生成
            #*********************************
            if ($q->param('period_flag')) {
                push(@whereSQL, "DATE_FORMAT(p.registration_date, \"%Y-%m-%d\") BETWEEN ? AND ?");
                push(@placeholder, sprintf("%04d-%02d-%02d", $q->param('years'),$q->param('months'),$q->param('dates')));
                push(@placeholder, sprintf("%04d-%02d-%02d", $q->param('toyears'), $q->param('tomonths'), $q->param('todates')));
            }

            my @ORDERBY = ('p.registration_date', 'p.product_id', 'p.status_flag', 'p.categorym_id',);
            my $orderbystr = $ORDERBY[$q->param('orderby')-1];

            #*********************************
            # SQLの生成
            #*********************************
            $SQL .= sprintf(" %s%s", (0 < @whereSQL ? "WHERE " : ""), join(' AND ', @whereSQL));
            $SQL .= " ORDER BY $orderbystr DESC";

            $MAXREC_SQL .= sprintf(" %s%s", (0 < @whereSQL ? "WHERE " : ""), join(' AND ', @whereSQL));

            ## 初回の検索時だけクッキーに検索条件挿入
            my $cookie_name = 'JKZ_WAFCMSsearchProduct';
            my $cookiesql   = join(' AND ', @whereSQL);
    ## カンマで区切るとSQL文と衝突するからセミコロンに変更 2010/02/10
            $cookiesql .= sprintf("\; ORDER BY %s DESC", $orderbystr);
            $cookiesql .= "\;@placeholder" if 0 < @placeholder;

            $self->{cookie} = $self->query->cookie(
                        -name  => $cookie_name,
                        -value => $cookiesql,
                        -path  =>    '/',
                        );

        }

        #*********************************
        ## SQL生成完了
        #*********************************
        $SQL .= " LIMIT $offset, $condition_limit;";

        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');
        #*********************************
        # SENNAのmultisectionを有効にする
        #*********************************
        $dbh->do('SET SESSION senna_2ind=ON;');

    #*********************************
    ## ページ数表示リンクのナビ
    #*********************************
        my @navilink;

        my $maxrec = $dbh->selectrow_array($MAXREC_SQL, undef, @placeholder);

        ## レコード数が1ページ上限数より多い場合
        if ($maxrec > $record_limit) {

        my $url = 'app.mpl?app=AppProduct;action=searchProduct;search=1';

        ## 前へページの生成
            if (0 == $offset) { ## 最初のページの場合
                push(@navilink, "<font size=-1>&lt;&lt;前</font>&nbsp;");
            } else { ## 2ページ目以降の場合
                push(@navilink, $self->genNaviLink($url, "<font size=-1>&lt;&lt;前</font>&nbsp;", $offset - $record_limit));
            }

        ## ページ番号生成
            for (my $i = 0; $i < $maxrec; $i += $record_limit) {

                my $pageno = int ($i / $record_limit) + 1;

                if ($i == $offset) { ###現在表示してるﾍﾟｰｼﾞ分
                    push (@navilink, '<font size=+1>' . $pageno . '</font>');
                } else {
                    push (@navilink, $self->genNaviLink($url, $pageno, $i));
                }
            }

        ## 次へページの生成
            if (($offset + $record_limit) > $maxrec) {
                push (@navilink, "&nbsp;<font size=-1>次&gt;&gt;</font>");
            } else {
                push (@navilink, $self->genNaviLink($url, "&nbsp;<font size=-1>次&gt;&gt;</font>", $offset + $record_limit));
            
            }

            @navilink = map{ "$_\n" } @navilink;

            $obj->{pagenavi} = sprintf("<font size=-1>[全%s件 / %s件\表\示]</font><br />", $maxrec, $record_limit) . join(' ', @navilink);
        }

        my $aryref = $dbh->selectall_arrayref($SQL, { Columns => {} }, @placeholder);

        $obj->{LoopSearchList} = ($record_limit == $#{$aryref}) ? $record_limit-1 : $#{$aryref};
        if (0 <= $#{$aryref}) {
            $obj->{IfExistsSearchList} = 1;
            map {
                my $i = $_;
                foreach my $key (keys %{ $aryref }) {
                    $obj->{$key}->[$i] = $aryref->[$i]->{$key};
                }
                $obj->{status_flagDescription}->[$i] = $self->fetchOneValueFromConf('STATUS', ($obj->{status_flag}->[$i]-1));
                $obj->{status_flagImages}->[$i]      = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$i]-1));
                $obj->{latest_flagImages}->[$i]      = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{latest_flag}->[$i]-1));
                $obj->{recommend_flagImages}->[$i]   = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{recommend_flag}->[$i]-1));
                $obj->{description}->[$i]            = MyClass::WebUtil::escapeTags($obj->{description}->[$i]);
                $obj->{registration_date}->[$i]      =~ s!-!/!g;
                $obj->{registration_date}->[$i]      = substr($obj->{registration_date}->[$i] ,2, 9);

                $obj->{cssstyle}->[$i] = ( 0 == $i % 2 ) ? 'focusodd' : 'focuseven';
            } 0..$obj->{LoopSearchList};

#******************************
# 次へ、前へだけのページングの場合
#******************************
## Modified 2009/06/19
=pod
            $obj->{rangeBegin}    = ($offset+1);
            $obj->{rangeEnd}    = ($obj->{rangeBeginCT}+$obj->{LoopSearchList});

            if ($record_limit == $#{$aryref}) {
                $obj->{offsetTOnext}= (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
                $obj->{IfNextData}    = 1;
            }
            if ($record_limit <= $offset) {
                $obj->{offsetTOprevious}= ($offset - $condition_limit + 1);
                $obj->{IfPreviousData}    = 1;
            }
=cut
        }
        else {
            $obj->{IfNotExistsSearchList} = 1;
        }
        $obj->{IfSearchExecuted} = 1;
    }

    return  $obj;
}


#******************************************************
# @access    public
# @desc        商品詳細/編集
# @param    
#******************************************************
sub detailProduct {
    my $self = shift;

    my $q = $self->query();
    $q->autoEscape(0);

    my $obj = {};

    defined($q->param('md5key')) ? $obj->{IfConfirmProductForm} = 1 : $obj->{IfModifyProductForm} = 1;

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    ## こちらの評価を先にする。パブリッシュするため
    if ($obj->{IfConfirmProductForm}) {
        $obj->{product_id}         = $q->param('product_id');
        $obj->{status_flag}        = $q->param('status_flag');
        $obj->{latest_flag}        = $q->param('latest_flag');
        $obj->{recommend_flag}     = $q->param('recommend_flag');
        $obj->{charge_flag}        = 2 ** $q->param('charge_flag');
        $obj->{point_flag}         = $q->param('point_flag');
        $obj->{product_name}       = $q->escapeHTML($q->param('product_name'));
        $obj->{product_code}       = MyClass::WebUtil::formatToNumberAlphabet($q->param('product_code'));
        $obj->{description}        = $q->escapeHTML($q->param('description'));
        $obj->{description_detail} = $q->escapeHTML($q->param('description_detail'));
        #$obj->{tmplt_id}            = $q->param('tmplt_id');
        $obj->{genka}              = $q->param('genka') || 0;
        $obj->{tanka}              = $q->param('tanka') || 0;
        $obj->{tanka_notax}        = $q->param('tanka_notax') || 0;
        $obj->{teika}              = $q->param('teika') || 0;
        $obj->{point}              = $q->param('point') || 0;
        $obj->{stock}              = $q->param('stock') || 0;


        ($obj->{tmplt_id}, $obj->{DecodedSummary}) = split(/;/, $q->param('tmplt_id'));
        $obj->{DecodedSummary} = $q->unescape($obj->{DecodedSummary});

        ( $obj->{categorym_id}, $obj->{subcategorym_id}, $obj->{smallcategorym_id}, $obj->{DecodedCategoryName}, $obj->{DecodedSubCategoryName}, $obj->{DecodedSmallCategoryName} ) = split(/;/, $q->param('allcategory_id'));

        $obj->{DecodedCategoryName}    = $q->unescape($obj->{DecodedCategoryName});
        $obj->{DecodedSubCategoryName} = $q->unescape($obj->{DecodedSubCategoryName});
        $obj->{DecodedSmallCategoryName} = $q->unescape($obj->{DecodedSmallCategoryName});

        my $publish = $self->PUBLISH_DIR() . '/admin/' . $obj->{md5key};
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

        ## 商品の状態
        2 == $obj->{status_flag}    ? $obj->{IfStatusFlagIsActive}      = 1 : $obj->{IfStatusFlagIsNotActive}    = 1;

        ## 新着表示の状態
        2 == $obj->{latest_flag}    ? $obj->{IfLatestFlagIsActive}      = 1 :
        4 == $obj->{latest_flag}    ? $obj->{IfLatestOnTopFlagIsActive} = 1 :
                                      $obj->{IfLatestFlagIsNotActive}   = 1 ;
        ## オススメ表示の状態
        2 == $obj->{recommend_flag} ? $obj->{IfRecommendFlagIsActive}   = 1 : $obj->{IfRecommendFlagIsNotActive} = 1;

        ## ポイント還元の状態
        2 == $obj->{point_flag}     ? $obj->{IfPointFlagIsActive}       = 1 : $obj->{IfPointFlagIsNotActive}     = 1;

        ## 課金種別
        2 == $obj->{charge_flag}    ? $obj->{IfChargeFlagIs315}         = 1 : $obj->{IfChargeFlagIsFree}         = 1;
        $obj->{CHARGE_STATUS} = $self->fetchOneValueFromConf('MEMBER_STATUS', ($q->param('charge_flag') - 1));
    }
    elsif ($obj->{IfModifyProductForm}) {
        my $product_id = $q->param('product_id');

        my $dbh = $self->getDBConnection();
        my $cmsProduct = MyClass::JKZDB::Product->new($dbh);
        if (!$cmsProduct->executeSelect({whereSQL => "product_id=?", placeholder => [$product_id,]})) {
            $obj->{DUMP} = "データの取得失敗のまき";
        } else {
            map { $obj->{$_} = $cmsProduct->{columns}->{$_} } keys %{$cmsProduct->{columns}};
            $obj->{description} = $q->escapeHTML($obj->{description});
            $obj->{description_detail} = $q->escapeHTML($obj->{description_detail});
            2 == $obj->{status_flag}    ? $obj->{IfStatusFlagIsActive}    = 1 : $obj->{IfStatusFlagIsNotActive}    = 1;
            
            2 == $obj->{latest_flag}    ? $obj->{IfLatestFlagIsActive}      = 1 :
            4 == $obj->{latest_flag}    ? $obj->{IfLatestOnTopFlagIsActive} = 1 :
                                          $obj->{IfLatestFlagIsNotActive}   = 1 ;
            
            2 == $obj->{recommend_flag} ? $obj->{IfRecommendFlagIsActive} = 1 : $obj->{IfRecommendFlagIsNotActive} = 1;
            2 == $obj->{point_flag}     ? $obj->{IfPointFlagIsActive}     = 1 : $obj->{IfPointFlagIsNotActive}     = 1;
            2 == $obj->{charge_flag}    ? $obj->{IfChargeFlagIs315}       = 1 : $obj->{IfChargeFlagIsFree}         = 1;
        }
        undef($cmsProduct);

        #*********************************
        # 全サブカテゴリリスト取得 category_id;subcategory_id;EncodedCategoryName;EncodedSubCategoryName
        #*********************************

        $self->setDBCharset('SJIS');

     ## ここは全データが存在するsamllcategoryからデータ取得に変更
        my $smallcategorylist = $self->getSmallCategoryFromObjectFile();
        $obj->{LoopAllCategoryList} = $#{ $smallcategorylist } - 1;
        map {
            my $i = $_;
            $obj->{category_id}->[$i]               = $smallcategorylist->[$i+1]->{'category_id'};
            $obj->{category_name}->[$i]             = $smallcategorylist->[$i+1]->{'category_name'};
            $obj->{subcategory_id}->[$i]            = $smallcategorylist->[$i+1]->{'subcategory_id'};
            $obj->{subcategory_name}->[$i]          = $smallcategorylist->[$i+1]->{'subcategory_name'};
            $obj->{smallcategory_id}->[$i]          = $smallcategorylist->[$i+1]->{'smallcategory_id'};
            $obj->{smallcategory_name}->[$i]        = $smallcategorylist->[$i+1]->{'smallcategory_name'};
            $obj->{EncodedCategoryName}->[$i]       = $q->escape($obj->{category_name}->[$i]);
            $obj->{EncodedSubCategoryName}->[$i]    = $q->escape($obj->{subcategory_name}->[$i]);
            $obj->{EncodedSmallCategoryName}->[$i]  = $q->escape($obj->{smallcategory_name}->[$i]);
            $obj->{IfSelectedSmallCategoryID}->[$i] = 1 if $obj->{smallcategory_id}->[$i] == $obj->{smallcategorym_id};
        } 0..$obj->{LoopAllCategoryList};

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
                $obj->{EncodedSummary}->[$i]     = $q->escape($obj->{summary}->[$i]);
                ## 商品マスタのtmplt_idとテンプレートリストデータのtmplt_idが一致したら選択フラグを立てる
                $obj->{IfSelectedMasterID}->[$i] = 1 if $obj->{tmplt_id}->[$i] == $obj->{tmplt_id};
            }
        }

        #*********************************
        # 画像情報の取得
        #*********************************
        my $Image = MyClass::JKZDB::ProductImage->new($dbh);
        if ($Image->checkRecord($product_id)) {
            $obj->{IfExistsImageData} = 1;
        } else {
            $obj->{IfNotExistsImageData} = 1;
        }
        #*********************************
        # 画像情報の取得
        #*********************************
        my $ImageList = MyClass::JKZDB::ProductImage->new($dbh);
        $ImageList->executeSelectList ({
            whereSQL	=> 'productm_id=?',
            placeholder	=> ["$product_id"]
        });
        $obj->{LoopImageList} = $ImageList->countRecSQL();
        if ( 0 <= $obj->{LoopImageList}) {
            for (my $i = 0; $i <= $obj->{LoopImageList}; $i++) {
                map { $obj->{$_}->[$i] = $ImageList->{columnslist}->{$_}->[$i] } keys %{$ImageList->{columnslist}};
                $obj->{subcategory_id}->[$i] = $obj->{subcategorym_id};
                ## まだループがあるとき
                unless ($i == $obj->{LoopImageList}) {
                ## 2個の場合
                    $obj->{TRBEGIN}->[$i] = (0 == $i % 2 ) ? '<tr>' : '';
                    $obj->{TREND}->[$i]   = (0 == $i % 2 ) ? '' : '</tr>';
               } else { ## 最終ループで終わりのとき
                   ## 2個の場合
                   $obj->{TRBEGIN}->[$i] = (0 == $i % 2 ) ? '<tr>' : '';
                   $obj->{TREND}->[$i]   = (0 == $i % 2 ) ? '<td><br /></td></tr>' : '</tr>';
               }
            }
         }
         undef($ImageList);

    ## ビット値を元に戻しておく
        ## 今回はbitではないのでそのままでOK 2010/1/17
        #my $log_category_id = (log($obj->{categorym_id}) / log(2));

    #*********************************
    # subcategory 1-5は決め内。順に 絵文字 プチデコ デコメ デコメテンプレート 待ちうけflash
    #*********************************
        if (5 < $obj->{subcategorym_id}) {
            $obj->{IfNormalProdcut} = 1;
        }
        #*********************************
        # デコメテンプレートの場合
        #*********************************
        elsif (4 == $obj->{subcategorym_id}) {

            $obj->{IfDecoTmpltProduct} = 1;
            my $cmsDecoTmplt = MyClass::JKZDB::ProductDecoTmplt->new($dbh);

            if (!$cmsDecoTmplt->getSpecificValuesSQL({ columns  => ['file_size_docomo', 'file_size_softbank', 'file_size_au',],
                                                    whereSQL    => 'productm_id=?',
                                                    placeholder => [$product_id],})
            ) {
                $obj->{IfNotExistsDecoTmpltFile} = 1;
            }
            else {
                $obj->{IfExistsDecoTmpltFile} = 1;
                map { $obj->{$_} = $cmsDecoTmplt->{columns}->{$_} } keys %{ $cmsDecoTmplt->{columns} };
            }
        }
        elsif (5 == $obj->{subcategorym_id}) {
            $obj->{IfSwfProduct} = 1;
            #*********************************
            # flash情報の取得 暫定処理
            #*********************************
            my $sql = "SELECT mime_type, file_size, height, width FROM JKZ_WAF.tProductSwf WHERE productm_id=? AND id=1;";
            $obj->{IfExistsFlashData} = 1 if ($obj->{mime_type}, $obj->{file_size}, $obj->{height}, $obj->{width}) = $dbh->selectrow_array($sql, undef, $product_id);
            unless ($obj->{IfExistsFlashData}) { $obj->{IfNotExistsFlashData} = 1; }
        }
        elsif (0 < $obj->{subcategorym_id} && 4 > $obj->{subcategorym_id}) {
        #*********************************
        # デコメ・プチデコ・絵文字の場合
        #*********************************
            $obj->{IfDecoPDecoEmojiProduct} = 1;
        }
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        商品新規登録画面
# @param    
#******************************************************
sub registProduct {
    my $self = shift;

    my $q = $self->query();
    $q->autoEscape(0);
    my $obj = {};

    defined($q->param('md5key')) ? $obj->{IfConfirmProductForm} = 1 : $obj->{IfRegistProductForm} = 1;

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    ## こちらの評価を先にする。パブリッシュするため
    if ($obj->{IfConfirmProductForm}) {

        ($obj->{tmplt_id}, $obj->{DecodedSummary}) = split(/;/, $q->param('tmplt_id'));
        ( $obj->{categorym_id}, $obj->{subcategorym_id}, $obj->{smallcategorym_id}, $obj->{DecodedCategoryName}, $obj->{DecodedSubCategoryName}, $obj->{DecodedSmallCategoryName} ) = split(/;/, $q->param('allcategory_id'));

        ## ここで必須項目のチェック(カテゴリ・サブカテゴリとテンプレートが選択されてればOK)
        #$obj->{IfProductNameIsEmpty}   = 1 if "" eq $obj->{product_name};
        #$obj->{IfCategoryIsNotSelected} = 1 if 1 > $obj->{tmplt_id};
        #$obj->{IfTemplateIsNotSelected} = 1 if 1 > $obj->{categorym_id};
        $obj->{IfProductNameIsEmpty}   = 1 if "" eq $q->param('product_name');
        $obj->{IfCategoryIsNotSelected} = 1 if 1 > $obj->{categorym_id};
        $obj->{IfTemplateIsNotSelected} = 1 if 1 > $obj->{tmplt_id};

        $obj->{IfRequirementNotFilled}  = 1 if 0 < ($obj->{IfProductNameIsEmpty} + $obj->{IfCategoryIsNotSelected} + $obj->{IfTemplateIsNotSelected});
        #$obj->{IfRequirementNotFilled}  = 1 if 1 > ($obj->{tmplt_id} + $obj->{categorym_id});

    ## IfRequirementNotFilledフラグがたっている場合は処理終了。たっていなければ必須項目は問題ないのIfRequirementFilledをたてて処理続行
        return $obj if 1 == $obj->{IfRequirementNotFilled};

        $obj->{DecodedSummary}           = $q->unescape($obj->{DecodedSummary});
        $obj->{categorym_id}             = $obj->{categorym_id};
        $obj->{DecodedCategoryName}      = $q->unescape($obj->{DecodedCategoryName});
        $obj->{DecodedSubCategoryName}   = $q->unescape($obj->{DecodedSubCategoryName});
        $obj->{DecodedSmallCategoryName} = $q->unescape($obj->{DecodedSmallCategoryName});
        $obj->{status_flag}              = $q->param('status_flag');
        $obj->{latest_flag}              = $q->param('latest_flag');
        $obj->{charge_flag}              = 2 ** $q->param('charge_flag');
        $obj->{point_flag}               = $q->param('point_flag');
        $obj->{product_name}             = $q->escapeHTML($q->param('product_name'));
        $obj->{product_code}             = MyClass::WebUtil::formatToNumberAlphabet($q->param('product_code'));
        $obj->{description}              = $q->escapeHTML($q->param('description'));
        $obj->{description_detail}       = $q->escapeHTML($q->param('description_detail'));
        $obj->{genka}                    = $q->param('genka') || 0;
        $obj->{tanka}                    = $q->param('tanka') || 0;
        $obj->{tanka_notax}              = $q->param('tanka_notax') || 0;
        $obj->{teika}                    = $q->param('teika') || 0;
        $obj->{point}                    = $q->param('point') || 0;
        $obj->{stock}                    = $q->param('stock') || 0;

        my $publish = $self->PUBLISH_DIR() . '/admin/' . $obj->{md5key};
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

        2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;

        #2 == $obj->{latest_flag} ? $obj->{IfLatestFlagIsActive} = 1 : $obj->{IfLatestFlagIsNotActive} = 1;
        2 == $obj->{latest_flag}    ? $obj->{IfLatestFlagIsActive}      = 1 :
        4 == $obj->{latest_flag}    ? $obj->{IfLatestOnTopFlagIsActive} = 1 :
                                      $obj->{IfLatestFlagIsNotActive}   = 1 ;

        2 == $obj->{point_flag}  ? $obj->{IfPointFlagIsActive}  = 1 : $obj->{IfPointFlagIsNotActive}  = 1;
        $obj->{CHARGE_STATUS} = $self->fetchOneValueFromConf('MEMBER_STATUS', ($q->param('charge_flag') - 1));

        $obj->{IfRequirementFilled} = 1;

    }
    elsif ($obj->{IfRegistProductForm}) {
        #*********************************
        # 全サブカテゴリリスト取得 category_id;subcategory_id;EncodedCategoryName;EncodedSubCategoryName
        #*********************************
        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');

        my $smallcategorylist = $self->getSmallCategoryFromObjectFile();
        $obj->{LoopAllCategoryList} = $#{ $smallcategorylist } - 1;
        map {
            my $i = $_;
            $obj->{category_id}->[$i]              = $smallcategorylist->[$i+1]->{'category_id'};
            $obj->{category_name}->[$i]            = $smallcategorylist->[$i+1]->{'category_name'};
            $obj->{subcategory_id}->[$i]           = $smallcategorylist->[$i+1]->{'subcategory_id'};
            $obj->{subcategory_name}->[$i]         = $smallcategorylist->[$i+1]->{'subcategory_name'};
            $obj->{smallcategory_id}->[$i]         = $smallcategorylist->[$i+1]->{'smallcategory_id'};
            $obj->{smallcategory_name}->[$i]       = $smallcategorylist->[$i+1]->{'smallcategory_name'};
            $obj->{EncodedCategoryName}->[$i]      = $q->escape($obj->{category_name}->[$i]);
            $obj->{EncodedSubCategoryName}->[$i]   = $q->escape($obj->{subcategory_name}->[$i]);
            $obj->{EncodedSmallCategoryName}->[$i] = $q->escape($obj->{smallcategory_name}->[$i]);
        } 0..$obj->{LoopAllCategoryList};

        #*********************************
        # テンプレートリストを取得
        #*********************************
        my $tmpltobj = $self->fetchTmplt();
        $obj->{LoopTmpltMasterList} = $#{$tmpltobj->{tmplt_id}};
        if (0 <= $obj->{LoopTmpltMasterList}) {
            for (my $i = 0; $i <= $obj->{LoopTmpltMasterList}; $i++) {
                map { $obj->{$_}->[$i] = $tmpltobj->{$_}->[$i] } qw(tmplt_id summary);
                $obj->{EncodedSummary}->[$i] = $q->escape($obj->{summary}->[$i]);
                ## Modified 2010/02/25
                $obj->{IfTmpltID12}->[$i] = 1 if 12 == $obj->{tmplt_id}->[$i] ;
            }
        }
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        商品情報更新/新規登録
# @param    
#******************************************************
sub modifyProduct {
    my $self = shift;

    my $q = $self->query();
    my $obj = {};

    if (!$q->MethPost()) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG18");
    }

    my $updateData = {
        product_id         => undef,
        status_flag        => undef,
        charge_flag        => undef,
        point_flag         => undef,
        latest_flag        => undef,
        recommend_flag     => undef,
        product_name       => undef,
        product_code       => undef,
        categorym_id       => undef,
        subcategorym_id    => undef,
        smallcategorym_id  => undef,
        description        => undef,
        description_detail => undef,
        genka              => undef,
        tanka              => undef,
        tanka_notax        => undef,
        teika              => undef,
        tmplt_id           => undef,
        point              => undef,
        stock              => undef,
    };

    my $publish = $self->PUBLISH_DIR() . '/admin/' . $q->param('md5key');
    eval {
        my $publishobj = MyClass::WebUtil::publishObj( { file=>$publish } );
        map { exists($updateData->{$_}) ? $updateData->{$_} = $publishobj->{$_} : "" } keys%{$publishobj};
        if (1 > $updateData->{product_id}) {
            $updateData->{product_id} = -1;
            $obj->{IfRegistProduct} = 1;
        } else {
            $obj->{IfModifyProduct} = 1;
        }
    };
    ## パブリッシュオブジェクトの取得失敗の場合
    if ($@) {

    } else {
        my $dbh = $self->getDBConnection();
        my $cmsProduct = MyClass::JKZDB::Product->new($dbh);
        ## autocommit設定をoffにしてトランザクション開始
        my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);

        eval {
            $cmsProduct->executeUpdate($updateData);
            ## 新規の場合にproduct_idが何かをわかるように mysqlInsertIDSQLはcommitの前で取得
            $obj->{product_id_is} = $obj->{IfRegistProduct} ? $cmsProduct->mysqlInsertIDSQL() : $updateData->{product_id};

            $dbh->commit();
            $obj->{product_name}    = $updateData->{product_name};
            $obj->{product_code}    = $updateData->{product_code};

            $obj->{categorym_id}    = $updateData->{categorym_id};
            $obj->{subcategorym_id} = $updateData->{subcategorym_id};

            ## シリアライズオブジェクトの破棄
            MyClass::WebUtil::clearObj($publish);
        };
        ## 失敗のロールバック
        if ($@) {
            $dbh->rollback();
            $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG20");
            $obj->{IfFailExecuteUpdate} = 1;
        } else {
            ## キャッシュから古いデータをなくすため全て削除
            $self->flushAllFromCache();

            $obj->{IfSuccessExecuteUpdate} = 1;

            (4 == $obj->{subcategorym_id})
                ? $obj->{IfDecoTmpltProduct} = 1
                : (5 == ( log($obj->{categorym_id}) / log(2) ))
                ? $obj->{IfSwfProduct} = 1
                : $obj->{IfDecoPDecoEmojiProduct} = 1
            ;
        }
        ## autocommit設定を元に戻す
        MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
        undef($cmsProduct);
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        コンテンツの登録状態を一括変更
#            状態・新着・新着Toｐ・オススメ
# @param    int changeProductStatusTo
#            1  状態を無効にする
#            2  有効にする
#            3  Toｐ表示を有効にする
#
#
# @param    product_id status_flag  product_id status_flag latest_flag recommend_flag の4つ値が；で区切り
#       new status
#******************************************************
sub changeProductStatus {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    my @TYPE_OF_STATUS    = $self->fetchArrayValuesFromConf("NAME_FOR_STATUS");
    my @FLAG_NAMES        = $self->fetchArrayValuesFromConf("COLUNM_NAME_FOR_STATUS");

    defined($q->param('md5key')) ? $obj->{IfUpdateCompleted} = 1 : $obj->{IfConfirm} = 1;

    if  (!defined($q->param('md5key'))) {

        ## 項目が選択されていない場合はエラー
        unless ( 0 < $q->param('changeProductStatusTo') || $q->param('product_id_statatus_flag') ) {
            $obj->{IfError}   = 1;
            $obj->{ERROR_MSG} = "対象IDと状態変更内容を選択してください";
            return $obj;
        }
        if (!$q->MethPost()) {
            $obj->{IfError}   = 1;
            $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG18");
            return $obj;
        }

        my ( $key_value, $key_status_value ) = split(/;/, $q->param('changeProductStatusTo'));
        my $config_name_jp    = 'STATUS_NAME_FOR_' . $TYPE_OF_STATUS[$key_value-1] . '_JP';
        $obj->{CONFIGNAME_JP} = $config_name_jp;
        my $column_name       = $FLAG_NAMES[$key_value-1];
        my @STATUS_NAME_JP    = $self->fetchArrayValuesFromConf($config_name_jp);
        my $newstatus_name_jp = $STATUS_NAME_JP[$key_status_value-1];


        my @productparam = $q->param('product_id_statatus_flag');
        $obj->{LoopProductList} = $#productparam;
        for (0..$#productparam) {
            ( $obj->{product_id}->[$_], $obj->{status_flag}->[$_], $obj->{latest_flag}->[$_], $obj->{recommend_flag}->[$_] ) = split(/;/, $productparam[$_]);
        ## 実際の更新の値
            $obj->{newstatus}->[$_]     = $key_status_value;

        ## たなんる出力用の値
            $obj->{statusnamenow}->[$_] = $STATUS_NAME_JP[( $obj->{$column_name}->[$_] - 1 )];
            $obj->{newstatusname}->[$_] = $newstatus_name_jp;
        }
        $obj->{key_value} = $key_value;
        $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
        ## オブジェクト生成
        my $publish = $self->PUBLISH_DIR() . '/admin/' . $obj->{md5key};
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

    }
    else {
        $obj->{IfUpdateCompleted} = 1;

        my $publish = $self->PUBLISH_DIR() . '/admin/' . $q->param('md5key');
        my $publishobj;
        eval {
            $publishobj = MyClass::WebUtil::publishObj( { file=>$publish } );
        };
        ## パブリッシュオブジェクトの取得失敗の場合
        if ($@) {

        } else {
            my $dbh = $self->getDBConnection();
            my $cmsProduct = MyClass::JKZDB::Product->new($dbh);
            ## 配列のインデックスで値を取得して更新

            my $tmphash = {};

            for(0..$#{$publishobj->{product_id}}) {
                $tmphash->{product_id} = $publishobj->{product_id}->[$_];
                $tmphash->{$FLAG_NAMES[$publishobj->{key_value} - 1]} = $publishobj->{newstatus}->[$_];
warn "\n ----- \n product_id : columname : newstatus [",  $tmphash->{product_id}, " : ", $FLAG_NAMES[$publishobj->{key_value} - 1], " : ", $tmphash->{$FLAG_NAMES[$publishobj->{key_value} - 1]}, " ] \n -------";
warn Dumper($tmphash);
               $obj->{DUMP} .= $cmsProduct->executeUpdate($tmphash);
            }

            ## シリアライズオブジェクトの破棄
            MyClass::WebUtil::clearObj($publish);
            ## キャッシュから古いデータをなくすため全て削除 2009/06/08
            $self->flushAllFromCache();
        }
    }

    #******************************************************
    # コンテンツ検索フォーム
    #******************************************************
    my $skey = 's_';
    my $categorylist = $self->fetchCategory();
    $obj->{LoopCategoryList}  = $#{$categorylist->{category_id}};
    for (my $i =0; $i <= $obj->{LoopCategoryList}; $i++) {
        map { $obj->{$skey . $_}->[$i] = $categorylist->{$_}->[$i] } keys %{$categorylist};
    }

    my $pulldown = $self->createPeriodPullDown({year=>"years", month=>"months", date=>"dates", range=>"-2,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};
    $pulldown = $self->createPeriodPullDown({year=>"toyears", month=>"tomonths", date=>"todates", range=>"-2,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{$pulldown};

    return $obj;

}


#************************************************************************************************************
# @desc        商品カテゴリデータ関連
#************************************************************************************************************

#******************************************************
# @access    public
# @desc      商品カテゴリ一覧
# @param    
#******************************************************
sub viewCategoryList {
    my $self = shift;
    my $q    = $self->query();

    my $record_limit    = 30;
    my $offset          = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $obj = {};

    my $categorylist = $self->fetchCategory($condition_limit, $offset);
    $obj->{LoopCategoryList} = $#{$categorylist->{category_id}};
    if (0 <= $obj->{LoopCategoryList}) {
        $obj->{IfExistsCategoryList} = 1;
        for (my $i =0; $i <= $obj->{LoopCategoryList}; $i++) {
            map { $obj->{$_}->[$i] = $categorylist->{$_}->[$i] } keys %{$categorylist};
            $obj->{status_flagDescription}->[$i] = $self->fetchOneValueFromConf('STATUS', ($obj->{status_flag}->[$i]-1));
            $obj->{status_flagImages}->[$i]      = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$i]-1));
            $obj->{description}->[$i]            = MyClass::WebUtil::escapeTags($obj->{description}->[$i]);
            $obj->{registration_date}->[$i]      =~ s!-!/!g;
            $obj->{registration_date}->[$i]      = substr($obj->{registration_date}->[$i] ,2, 9);
        }
        $obj->{rangeBegin} = ($offset+1);
        $obj->{rangeEnd}   = ($obj->{rangeBeginCT}+$obj->{LoopCategoryList});

        if ($record_limit == $obj->{LoopCategoryList}) {
            $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
            $obj->{IfNextData}   = 1;
        }
        if ($record_limit <= $offset) {
            $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
            $obj->{IfPreviousData}   = 1;
        }
    }
    else {
        $obj->{IfNotExistsCategoryList} = 1;
    }

    return  $obj;
}


#******************************************************
# @access    public
# @desc        商品中カテゴリ一覧
# @param    
#******************************************************
sub viewSubCategoryList {
    my $self = shift;
    my $q    = $self->query();

    my $record_limit    = 30;
    my $offset          = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $obj = {};

    my $subcategorylist = $self->fetchSubCategory($condition_limit, $offset);
    $obj->{LoopSubCategoryList}  = $#{$subcategorylist->{subcategory_id}};
    if (0 <= $obj->{LoopSubCategoryList}) {
        $obj->{IfExistsSubCategoryList} = 1;
        for (my $i =0; $i <= $obj->{LoopSubCategoryList}; $i++) {
            map { $obj->{$_}->[$i] = $subcategorylist->{$_}->[$i] } keys %{$subcategorylist};
            $obj->{status_flagDescription}->[$i] = $self->fetchOneValueFromConf('STATUS', ($obj->{status_flag}->[$i]-1));
            $obj->{status_flagImages}->[$i]      = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$i]-1));
            $obj->{description}->[$i]            = MyClass::WebUtil::escapeTags($obj->{description}->[$i]);
            $obj->{registration_date}->[$i]      =~ s!-!/!g;
            $obj->{registration_date}->[$i]      = substr($obj->{registration_date}->[$i] ,2, 9);
        }
        $obj->{rangeBegin} = ($offset+1);
        $obj->{rangeEnd}   = ($obj->{rangeBeginCT}+$obj->{LoopSubCategoryList});

        if ($record_limit == $obj->{LoopSubCategoryList}) {
            $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
            $obj->{IfNextData}   = 1;
        }
        if ($record_limit <= $offset) {
            $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
            $obj->{IfPreviousData}   = 1;
        }
    }
    else {
        $obj->{IfNotExistsSubCategoryList} = 1;
    }

    return  $obj;
}


#******************************************************
# @access    public
# @desc        商品小カテゴリ一覧
# @param    
#******************************************************
sub viewSmallCategoryList {
    my $self = shift;
    my $q    = $self->query();

    my $record_limit    = 30;
    my $offset          = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $obj = {};

    my $smallcategorylist = $self->fetchSmallCategory($condition_limit, $offset);
    $obj->{LoopSmallCategoryList}  = $#{$smallcategorylist->{smallcategory_id}};
    if (0 <= $obj->{LoopSmallCategoryList}) {
        $obj->{IfExistsSmallCategoryList} = 1;
        for (my $i =0; $i <= $obj->{LoopSmallCategoryList}; $i++) {
            map { $obj->{$_}->[$i] = $smallcategorylist->{$_}->[$i] } keys %{$smallcategorylist};
            $obj->{status_flagDescription}->[$i] = $self->fetchOneValueFromConf('STATUS', ($obj->{status_flag}->[$i]-1));
            $obj->{status_flagImages}->[$i]      = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$i]-1));
            $obj->{description}->[$i]            = MyClass::WebUtil::escapeTags($obj->{description}->[$i]);
            $obj->{registration_date}->[$i]      =~ s!-!/!g;
            $obj->{registration_date}->[$i]      = substr($obj->{registration_date}->[$i] ,2, 9);
        }
        $obj->{rangeBegin} = ($offset+1);
        $obj->{rangeEnd}   = ($obj->{rangeBeginCT}+$obj->{LoopSmallCategoryList});

        if ($record_limit == $obj->{LoopSmallCategoryList}) {
            $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
            $obj->{IfNextData}   = 1;
        }
        if ($record_limit <= $offset) {
            $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
            $obj->{IfPreviousData}   = 1;
        }
    }
    else {
        $obj->{IfNotExistsSmallCategoryList} = 1;
    }

    return  $obj;
}


#******************************************************
# @access    public
# @desc        商品カテゴリ詳細/編集
# @param    
#******************************************************
sub detailCategory {
    my $self = shift;
    my $q    = $self->query();
    $q->autoEscape(0);

    my $obj = {};

    defined($q->param('md5key')) ? $obj->{IfConfirmCategoryForm} = 1 : $obj->{IfModifyCategoryForm} = 1;

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    ## こちらの評価を先にする。パブリッシュするため
    #*********************************
    # 更新情報をシリアライズ
    #*********************************
    if ($obj->{IfConfirmCategoryForm}) {
        $obj->{category_id}        = $q->param('category_id');
        $obj->{status_flag}        = $q->param('status_flag');
        $obj->{category_name}      = $q->escapeHTML($q->param('category_name'));
        $obj->{description}        = $q->escapeHTML($q->param('description'));
        $obj->{description_detail} = $q->escapeHTML($q->param('description_detail'));
        ## 現在は未使用 2009/03/18
        #$obj->{rank}                = $q->param('rank') || 0;

        my $publish = $self->PUBLISH_DIR() . '/admin/' . $obj->{md5key};
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

        2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;

    }
    elsif ($obj->{IfModifyCategoryForm}) {
        my $category_id = $q->param('category_id');
        my $dbh         = $self->getDBConnection();
        my $cmsCategory = MyClass::JKZDB::Category->new($dbh);

        if (!$cmsCategory->executeSelect({whereSQL => "category_id=?", placeholder => [$category_id,]})) {
            $obj->{DUMP} = "データの取得失敗のまき";
        } else {
            map { $obj->{$_} = $cmsCategory->{columns}->{$_} } keys %{$cmsCategory->{columns}};
            $obj->{description}        = $q->escapeHTML($obj->{description});
            $obj->{description_detail} = $q->escapeHTML($obj->{description_detail});
            2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;
        }
        undef($cmsCategory);
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        商品サブカテゴリ詳細/編集
# @param    
#******************************************************
sub detailSubCategory {
    my $self = shift;
    my $q    = $self->query();
    $q->autoEscape(0);

    my $obj = {};

    #defined($q->param('md5key')) ? $obj->{IfConfirmSubCategoryForm} = 1 : $obj->{IfModifySubCategoryForm} = 1;
    $obj->{IfConfirmSubCategoryForm} = 1 if $q->param('md5key');
    $obj->{IfModifySCategoryForm}    = !$obj->{IfConfirmSubCategoryForm} ? 1 : 0;

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    ## こちらの評価を先にする。パブリッシュするため
    #*********************************
    # 更新情報をシリアライズ
    #*********************************
    if ($obj->{IfConfirmSubCategoryForm}) {

        ($obj->{categorym_id}, $obj->{EncodedCategoryName})    = split(/;/, $q->param('category_id'));
        $obj->{category_name}      = $q->unescape($obj->{EncodedCategoryName});
        $obj->{subcategory_id}     = $q->param('subcategory_id');
        #$obj->{categorym_id}      = $obj->{categorym_id};
        $obj->{status_flag}        = $q->param('status_flag');
        $obj->{subcategory_name}   = $q->escapeHTML($q->param('subcategory_name'));
        $obj->{category_name}      = $obj->{category_name};
        $obj->{description}        = $q->escapeHTML($q->param('description'));
        $obj->{description_detail} = $q->escapeHTML($q->param('description_detail'));
        ## 現在は未使用 2009/03/18
        #$obj->{rank}                = $q->param('rank') || 0;

        my $publish = $self->PUBLISH_DIR() . '/admin/' . $obj->{md5key};
        MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});

        2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;

    }
    elsif ($obj->{IfModifySCategoryForm}) {
        my $subcategory_id = $q->param('subcategory_id');
        my $categorym_id   = $q->param('category_id');

        my $dbh = $self->getDBConnection();
        my $cmsSubCategory = MyClass::JKZDB::SubCategory->new($dbh);
        #if (!$cmsSubCategory->executeSelect({whereSQL => "subcategory_id=? AND categorym_id=?", placeholder => [$subcategory_id, $categorym_id,]})) {
        if (!$cmsSubCategory->getSpecificValuesSQL({ columns => ["subcategory_id", "categorym_id", "subcategory_name", "status_flag", "registration_date"],whereSQL => "subcategory_id=? AND categorym_id=?", placeholder => [$subcategory_id, $categorym_id,]})) {
            $obj->{DUMP} = "データの取得失敗のまき";
        } else {

            my $categoryobj = $self->fetchCategory();
            $obj->{LoopCategoryList}  = $#{$categoryobj->{category_id}};
            for (my $i =0; $i <= $obj->{LoopCategoryList}; $i++) {
                map { $obj->{$_}->[$i] = $categoryobj->{$_}->[$i] } qw(category_id category_name);
                $obj->{EncodedCategoryName}->[$i]  = $q->escape($obj->{category_name}->[$i]);
                $obj->{IfSelectedCategoryID}->[$i] = 1 if $obj->{category_id}->[$i] == $categorym_id;
            }

            map { $obj->{$_} = $cmsSubCategory->{columns}->{$_} } keys %{$cmsSubCategory->{columns}};
            $obj->{description}        = $q->escapeHTML($obj->{description});
            $obj->{description_detail} = $q->escapeHTML($obj->{description_detail});
            2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;
        }
        undef($cmsSubCategory);
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        カテゴリ新規登録画面
# @param    
#******************************************************
sub registCategory {
    my $self = shift;
    my $q = $self->query();
    $q->autoEscape(0);
    my $obj = {};

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    if (defined($q->param('md5key'))) {
        $obj->{status_flag}        = $q->param('status_flag');
        $obj->{category_name}      = $q->escapeHTML($q->param('category_name'));
        $obj->{description}        = $q->escapeHTML($q->param('description'));
        $obj->{description_detail} = $q->escapeHTML($q->param('description_detail'));
        ## 現在は未使用 2009/03/18
        #$obj->{rank}                = $q->param('rank') || 0;
        ## 入力項目が条件を満たしてない場合はデータをパブリッシュしない。
        ## 再度新規登録フォームを表示
        if (4 > length($q->param('category_name'))) {
            $obj->{IfRegistCategoryForm} = 1;
            $obj->{ERROR_MSG}            = $self->ERROR_MSG('ERR_MSG17');
            $obj->{IfInputCheckError}    = 1;
            (2 == int($q->param('status_flag'))) ? $obj->{IfStatusflag2} = 1 : $obj->{IfStatusflag1} = 1;
        } else {
            $obj->{IfConfirmCategoryForm} = 1;
            $obj->{Ifabc} = 0;
            my $publish = $self->PUBLISH_DIR() . '/admin/' . $obj->{md5key};
            MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});
            2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;
        }
    } else {
        $obj->{IfRegistCategoryForm} = 1;
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        中カテゴリ新規登録画面
# @param    
#******************************************************
sub registSubCategory {
    my $self = shift;
    my $q = $self->query();
    $q->autoEscape(0);
    my $obj = {};

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    if (defined($q->param('md5key'))) {

        ($obj->{categorym_id}, $obj->{EncodedCategoryName})    = split(/;/, $q->param('category_id'));
        $obj->{category_name}      = $q->unescape($obj->{EncodedCategoryName});
        $obj->{status_flag}        = $q->param('status_flag');
        $obj->{subcategory_name}   = $q->escapeHTML($q->param('subcategory_name'));
        $obj->{description}        = $q->escapeHTML($q->param('description'));
        $obj->{description_detail} = $q->escapeHTML($q->param('description_detail'));
        ## 現在は未使用 2009/03/18
        #$obj->{rank}                = $q->param('rank') || 0;
        ## 入力項目が条件を満たしてない場合はデータをパブリッシュしない。
        ## 再度新規登録フォームを表示
        if (4 > length($q->param('subcategory_name'))) {
            $obj->{IfRegistSubCategoryForm} = 1;
            $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG17');
            $obj->{IfInputCheckError} = 1;
            (2 == int($q->param('status_flag'))) ? $obj->{IfStatusflag2} = 1 : $obj->{IfStatusflag1} = 1;
        } else {
            $obj->{IfConfirmSubCategoryForm} = 1;
            $obj->{Ifabc} = 0;
            my $publish = $self->PUBLISH_DIR() . '/admin/' . $obj->{md5key};
            MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});
            2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;
        }
    } else {
        $obj->{IfRegistSubCategoryForm} = 1;

        my $categoryobj = $self->fetchCategory();
        $obj->{LoopCategoryList}  = $#{$categoryobj->{category_id}};
        for (my $i =0; $i <= $obj->{LoopCategoryList}; $i++) {
            map { $obj->{$_}->[$i] = $categoryobj->{$_}->[$i] } qw(category_id category_name);
            $obj->{EncodedCategoryName}->[$i]    = $q->escape($obj->{category_name}->[$i]);
        }

    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        小カテゴリ新規登録画面
# @param    
#******************************************************
sub registSmallCategory {
    my $self = shift;
    my $q = $self->query();
    $q->autoEscape(0);
    my $obj = {};

    $obj->{md5key} = MyClass::WebUtil::createHash($self->__session_id(), 20);
    if (defined($q->param('md5key'))) {

        ( $obj->{categorym_id}, $obj->{subcategorym_id}, $obj->{EncodedCategoryName}, $obj->{EncodedSubCategoryName} )    = split(/;/, $q->param('category_id'));
        $obj->{category_name}      = $q->unescape($obj->{EncodedCategoryName});
        $obj->{subcategory_name}   = $q->unescape($obj->{EncodedSubCategoryName});
        $obj->{status_flag}        = $q->param('status_flag');
        $obj->{smallcategory_name} = $q->escapeHTML($q->param('smallcategory_name'));
        $obj->{description}        = $q->escapeHTML($q->param('description'));
        $obj->{description_detail} = $q->escapeHTML($q->param('description_detail'));
        ## 現在は未使用 2009/03/18
        #$obj->{rank}                = $q->param('rank') || 0;
        ## 入力項目が条件を満たしてない場合はデータをパブリッシュしない。
        ## 再度新規登録フォームを表示
        if (4 > length($q->param('smallcategory_name'))) {
            $obj->{IfRegistSmallCategoryForm} = 1;
            $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG17');
            $obj->{IfInputCheckError} = 1;
            (2 == int($q->param('status_flag'))) ? $obj->{IfStatusflag2} = 1 : $obj->{IfStatusflag1} = 1;
        } else {
            $obj->{IfConfirmSmallCategoryForm} = 1;
            $obj->{Ifabc} = 0;
            my $publish = $self->PUBLISH_DIR() . '/admin/' . $obj->{md5key};
            MyClass::WebUtil::publishObj({file=>$publish, obj=>$obj});
            2 == $obj->{status_flag} ? $obj->{IfStatusFlagIsActive} = 1 : $obj->{IfStatusFlagIsNotActive} = 1;
        }
    } else {
        $obj->{IfRegistSmallCategoryForm} = 1;

        my $categorysubcategorylist = $self->getSubCategoryFromObjectFile();
        $obj->{LoopCategorySubCategoryList} = $#{ $categorysubcategorylist };
        map {
            my $i = $_;
            $obj->{category_id}->[$i]              = $categorysubcategorylist->[$i+1]->{'category_id'};
            $obj->{category_name}->[$i]            = MyClass::WebUtil::convertByNKF('-s', $categorysubcategorylist->[$i+1]->{'category_name'});
            $obj->{subcategory_id}->[$i]           = $categorysubcategorylist->[$i+1]->{'subcategory_id'};
            $obj->{subcategory_name}->[$i]         = MyClass::WebUtil::convertByNKF('-s', $categorysubcategorylist->[$i+1]->{'subcategory_name'});
            $obj->{EncodedCategoryName}->[$i]      = $q->escape($obj->{category_name}->[$i]);
            $obj->{EncodedSubCategoryName}->[$i]   = $q->escape($obj->{subcategory_name}->[$i]);
        } 0..$obj->{LoopCategorySubCategoryList};
    }

    return $obj;
}

#******************************************************
# @access    public
# @desc        カテゴリ情報更新/新規登録
# @param    
#******************************************************
sub modifyCategory {
    my $self = shift;

    my $q = $self->query();
    my $obj = {};

    if (!$q->MethPost()) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG18");
    }

    my $updateData = {
        category_id        => undef,
        status_flag        => undef,
        category_name      => undef,
        description        => undef,
        description_detail => undef,
    };

    my $publish = $self->PUBLISH_DIR() . '/admin/' . $q->param('md5key');
    eval {
        my $publishobj = MyClass::WebUtil::publishObj( { file=>$publish } );
        map { exists($updateData->{$_}) ? $updateData->{$_} = $publishobj->{$_} : "" } keys%{$publishobj};
        if (1 > $updateData->{category_id}) {
            $updateData->{category_id} = -1;
            $obj->{IfRegistCategory}   = 1;
        } else {
            $obj->{IfModifyCategory}   = 1;
        }
    };
    ## パブリッシュオブジェクトの取得失敗の場合
    if ($@) {
        
    } else {
        my $dbh         = $self->getDBConnection();
        my $cmsCategory = MyClass::JKZDB::Category->new($dbh);
        my $attr_ref    = MyClass::UsrWebDB::TransactInit($dbh);

        eval {
            $cmsCategory->executeUpdate($updateData);
            $dbh->commit();
            ## 新規の場合にproduct_idが何かをわかるように
            $obj->{category_id_is} = $obj->{IfRegistCategory} ? $cmsCategory->mysqlInsertIDSQL() : $updateData->{category_id};
            $obj->{category_name}  = $updateData->{category_name};

            ## シリアライズオブジェクトの破棄
            MyClass::WebUtil::clearObj($publish);
        };
        ## 失敗のロールバック
        if ($@) {
            $dbh->rollback();
            $obj->{ERROR_MSG}           = $self->ERROR_MSG("ERR_MSG20");
            $obj->{IfFailExecuteUpdate} = 1;
        } else {
            $obj->{IfSuccessExecuteUpdate} = 1;
            ## cacheを削除する。OR新規データが表示されない。
            $self->deleteFromCache("JKZ_WAFcategorylist");
        }
        ## autocommit設定を元に戻す
        MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
        undef($cmsCategory);
    }
    return $obj;
}


#******************************************************
# @access    public
# @desc        サブカテゴリ情報更新/新規登録
# @param    
#******************************************************
sub modifySubCategory {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    if (!$q->MethPost()) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG18");
    }

    my $updateData = {
        subcategory_id     => undef,
        categorym_id       => undef,
        status_flag        => undef,
        subcategory_name   => undef,
        category_name      => undef,
        description        => undef,
        description_detail => undef,
    };

    my $publish = $self->PUBLISH_DIR() . '/admin/' . $q->param('md5key');
    eval {
        my $publishobj = MyClass::WebUtil::publishObj( { file=>$publish } );
        map { exists($updateData->{$_}) ? $updateData->{$_} = $publishobj->{$_} : "" } keys%{$publishobj};
        if (1 > $updateData->{subcategory_id}) {
            $updateData->{subcategory_id} = -1;
            $obj->{IfRegistSubCategory}   = 1;
        } else {
            $obj->{IfModifySubCategory}   = 1;
        }
    };
    ## パブリッシュオブジェクトの取得失敗の場合
    if ($@) {
        
    } else {
        my $dbh            = $self->getDBConnection();
        my $cmsSubCategory = MyClass::JKZDB::SubCategory->new($dbh);
        my $attr_ref       = MyClass::UsrWebDB::TransactInit($dbh);

        eval {
            $cmsSubCategory->executeUpdate($updateData);
            $dbh->commit();
            ## 新規の場合にproduct_idが何かをわかるように
            $obj->{subcategory_id_is}    = $obj->{IfRegistSubCategory} ? $cmsSubCategory->mysqlInsertIDSQL() : $updateData->{subcategory_id};
            ## シリアライズオブジェクトの破棄
            MyClass::WebUtil::clearObj($publish);
        };
        ## 失敗のロールバック
        if ($@) {
            $dbh->rollback();
            $obj->{ERROR_MSG}              = $self->ERROR_MSG("ERR_MSG20");
            $obj->{IfFailExecuteUpdate}    = 1;
        } else {
            $obj->{IfSuccessExecuteUpdate} = 1;
            $obj->{categorym_id}           = $updateData->{categorym_id};
            $obj->{subcategory_name}       = $updateData->{subcategory_name};
            $obj->{category_name}          = $updateData->{category_name};
            ## cacheを削除する。OR新規データが表示されない。
            #$self->flushAllFromCache();
        }

        $self->flushAllFromCache();
        ## autocommit設定を元に戻す
        MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
        undef($cmsSubCategory);

        ## オブジェクト再構築
        my $moddir = $self->CONFIGURATION_VALUE("MODULE_DIR");
        my $module = sprintf("%s/%s", $moddir, $self->CONFIGURATION_VALUE("GENERATE_SMALL_SUB_CATEGORY_LIST"));
        if (-e $module) {
            system("cd $moddir && perl $module");
        }

    }
    return $obj;
}


#******************************************************
# @access    public
# @desc        小カテゴリ情報更新/新規登録
# @param    
#******************************************************
sub modifySmallCategory {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    if (!$q->MethPost()) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG("ERR_MSG18");
    }

    my $updateData = {
        smallcategory_id   => undef,
        categorym_id       => undef,
        subcategorym_id    => undef,
        status_flag        => undef,
        smallcategory_name => undef,
        subcategory_name   => undef,
        category_name      => undef,
        description        => undef,
        description_detail => undef,
    };

    my $publish = $self->PUBLISH_DIR() . '/admin/' . $q->param('md5key');
    eval {
        my $publishobj = MyClass::WebUtil::publishObj( { file=>$publish } );
        map { exists($updateData->{$_}) ? $updateData->{$_} = $publishobj->{$_} : "" } keys%{$publishobj};
        if (1 > $updateData->{smallcategory_id}) {
            $updateData->{smallcategory_id} = -1;
            $obj->{IfRegistSmallCategory}   = 1;
        } else {
            $obj->{IfModifySmallCategory}   = 1;
        }
    };
    ## パブリッシュオブジェクトの取得失敗の場合
    if ($@) {
        
    } else {
        my $dbh              = $self->getDBConnection();
        my $cmsSmallCategory = MyClass::JKZDB::SmallCategory->new($dbh);
        my $attr_ref         = MyClass::UsrWebDB::TransactInit($dbh);

        eval {
            $cmsSmallCategory->executeUpdate($updateData);
            $dbh->commit();
            ## 新規の場合にproduct_idが何かをわかるように
            $obj->{smallcategory_id_is}    = $obj->{IfRegistSmallCategory} ? $cmsSmallCategory->mysqlInsertIDSQL() : $updateData->{smallcategory_id};
            ## シリアライズオブジェクトの破棄
            MyClass::WebUtil::clearObj($publish);
        };
        ## 失敗のロールバック
        if ($@) {
            $dbh->rollback();
            $obj->{ERROR_MSG}              = $self->ERROR_MSG("ERR_MSG20");
            $obj->{IfFailExecuteUpdate}    = 1;
        } else {
            $obj->{IfSuccessExecuteUpdate} = 1;
            $obj->{categorym_id}           = $updateData->{categorym_id};
            $obj->{subcategorym_id}        = $updateData->{subcategorym_id};
            $obj->{smallcategory_name}     = $updateData->{subcategory_name};
            $obj->{category_name}          = $updateData->{category_name};
            $obj->{subcategory_name}       = $updateData->{subcategory_name};
            ## cacheを削除する。OR新規データが表示されない。
            #$self->flushAllFromCache();
        }

        $self->flushAllFromCache();
        ## autocommit設定を元に戻す
        MyClass::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
        undef($cmsSmallCategory);

        ## オブジェクト再構築
        my $moddir = $self->CONFIGURATION_VALUE("MODULE_DIR");
        my $module = sprintf("%s/%s", $moddir, $self->CONFIGURATION_VALUE("GENERATE_SMALL_SUB_CATEGORY_LIST"));
        if (-e $module) {
            system("cd $moddir && perl $module");
        }

    }
    return $obj;
}


1;

__END__
=pod
                ## まだループがあるとき
                unless ($i == $obj->{LoopImageList}) {
                    ## 2個の場合
                    $obj->{TRBEGIN}->[$i]    = (0 == $i % 2 ) ? '<tr>' : '';
                    $obj->{TREND}->[$i]        = (0 == $i % 2 ) ? '' : '</tr>';
                    ## 3個の場合
    #                $obj->{TR}->[$i] = (0 == ($i+1) % 3 ) ? '</tr><tr><!-- auto generated end tag and begin tag -->' : "";
                    ## 5この場合
    #                $obj->{TR}->[$i] = (0 == ($i+1) % 5 ) ? '</tr><tr><!-- auto generated end tag and begin tag -->' : "";
                } else { ## 最終ループで終わりのとき
                    ## 2個の場合
                    $obj->{TRBEGIN}->[$i]    = (0 == $i % 2 ) ? '<tr>' : '';
                    $obj->{TREND}->[$i]        = (0 == $i % 2 ) ? '<td><br /></td></tr>' : '</tr>';
                    ## 3個の場合
    #                $obj->{TR}->[$i] =
    #                    (0 == ($i+1) % 3 ) ? '</tr><!-- auto generated tr end tag -->'                         :
    #                    (2 == ($i+1) % 3 ) ? '<td></td></tr><!-- auto generated one pair of td tag tr end tag -->'         :
    #                                         '<td></td><td></td></tr><!-- auto generated two pair of td tag tr end tag -->';
                    ## 5個の場合
    #                $obj->{TR}->[$i] =
    #                    (0 == ($i+1) % 5 ) ? '</tr>'                                                                 :
    #                    (1 == ($i+1) % 5 ) ? '<td><br /></td><td><br /></td><td><br /></td><td><br /></td></tr>'    :
    #                    (2 == ($i+1) % 5 ) ? '<td><br /></td><td><br /></td><td><br /></td></tr>'                    :
    #                    (3 == ($i+1) % 5 ) ? '<td><br /></td><td><br /></td></tr>'                                    :
    #                                         '<td><br /></td></tr>'                                                     ;
                }
=cut
