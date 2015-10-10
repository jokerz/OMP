
use strict;
use CGI::Carp qw(fatalsToBrowser);
#use lib qw(/home/vhosts/dev.up-stair.jp/extlib/common);
#use lib qw(/home/vhosts/JKZ);
use MyClass::UsrWebDB;
use Goku::SiteSettings;
use Goku::Output qw(ShowMsg);
use Data::Dumper;

my $form = CGI->new ();
my @pairs;
my $k;
my $listnum=0;
my $filterid="";
my $filterurl="";
my $page=1;
my $db;
my $sql;
my $where;
my $max;
my $maxpage;
my $startpos;
my $list;
my $offset;
my $count;
my $id;
my $del;
my $adurl;
my $rec;
my $seturl;
my $sth="";
my $sthc="";
my $cnt;

my $now;
my $adname;
my $point;
my $limit;

my $sitekind;
my $commoncond;


sub GetNowDateTime{
	my ($db, $sth, $rec, $date, $time, $today);
	
	($db) = @_;
	$sth=$db->prepare("SELECT CURDATE(), CURTIME();");
	$sth->execute;
	
	$rec=$sth->fetchrow_arrayref;
	$date=$rec->[0];
	$time=$rec->[1];
	
	$today=$date . " " . $time;
	return $today;
}1;

#############################
# 渡された値を変数へセット
#############################
if ($ENV{'REQUEST_METHOD'} eq 'POST') {
	$page=$form->param("page");
}
else {
	if($ENV{'QUERY_STRING'} ne ""){
	    @pairs = split(/&/,$ENV{'QUERY_STRING'});
	
		#############################
		# パラメータの値を取得
		#############################
		($k,$page) = split(/=/,$pairs[0]);
	}
}

my @ADM=("/app.mpl","管理Top");

#############################
# DBをチェック
#############################
my $dbinfo = {
	dbaccount	=> "dbmaster",
	dbpasswd	=> "h2g8p200",
	dbname		=> "1MP",
};
$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');
$now = GetNowDateTime($db);

#############################
# 広告コード数を取得
#############################
$sql="select adid, adname, adpoint, adlimit, delad, urld, urlj, urle, 
urlo from tAdinfo order by adid desc;";

$sth=$db->prepare($sql);
$sth->execute;
if(!$sth){
	ShowMsg('広告コード情報一覧','情報の取得に失敗しました',1,@ADM);
	$sth->finish;
	$db->disconnect;
	undef($db);
	exit;
}

$max=$sth->rows;

#############################
# 総ページ数を算出
#############################
$listnum = 20;
$maxpage=int($max / $listnum);
if($max % $listnum){
	$maxpage++;
}

if($maxpage == 0){
	#表示するデータがなし
	ShowMsg('広告コード情報一覧','広告コード情報がありません',1,@ADM);
	$sth->finish;
	$db->disconnect;
	undef($db);
	exit;
}

#############################
# ページ番号から表示する位置を取得
#############################
$startpos=($page-1)*$listnum;

#############################
# 共通部分の出力
#############################
$list=$sth->fetchall_arrayref;

print $form->header(-charset=>'shift_jis');

print <<_HTML_HEADER_;
<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html
	PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/Dtd/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
<meta http-equiv="content-type" content="application/xhtml+xml;charset=Shift_JIS" />
<meta name="Pragma" content="no-cache" />
<title>広告コード情報編集</title>
<link rel="stylesheet" href="/style.css" type="text/css" charset="Shift_JIS" />
<link rel="stylesheet" type="text/css" href="build/fonts/fonts-min.css" />
<script src="/js/popuphint.js" type="text/javascript"></script>
</head>
<body class="yui-skin-sam">
<div id="base"><!-- ---------------------------------------------------------------------------- -->
	<!-- ヘッダー -->
	<div id="head">
		<h1>UPSTAIR システム　管理者画面</h1>
	</div>

	<!-- ■■■■■■■■■■■■■■ メニュー BEGIN ■■■■■■■■■■■■■■■■-->
   	<div id="side">
		<script src="/js/cms_leftmenu.js" type="text/JavaScript"></script>
	</div>

	<div id="main"><!-- ---------------------------------------------------------------------------- -->
		<!-- パンくず -->
		<div id="pankuzu">
			<a href="/app.mpl">トップ</a>＞広告管理＞<strong>メール広告一覧</strong>
		</div>
		<!-- タイトル -->
		<div class="screen_title">
			<h2>広告管理</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>
<!--
		<div id="menu_yoko">
			<ul>
				<li><a href="/mod-perl/editad.mpl?page=1;id=0">広告コード登録 </a></li>
				<li><a href="/mod-perl/rptad.mpl?page=1">広告コード一覧 </a></li>
				<li><a href="/mod-perl/addadmail.mpl?clear=1">メール配信 </a></li>
				<li><a href="/mod-perl/rptadmail.mpl?page=1" target="blank">メール送信履歴</a></li>
			</ul>
		</div>
-->
_HTML_HEADER_


print qq(<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">);
print qq(<tr><th align="center" colspan="5">メール広告コード情報一覧</th></tr>);
print "<tr>\n";
print "<th>" . '広告コード' . "</th>\n";
print "<th>" . '名称' . "</th>\n";
print "<th>" . 'url' . "</th>\n";
print "<th>" . '追加ポイント' . "</th>\n";
print "<th>" . '状態' . "</th>\n";
print "</tr>\n";

for($offset=0, $cnt=$startpos; $cnt<$max && $offset<$listnum; $cnt++, $offset++){
	my $pos;
	$pos = 0;
	$id=$list->[$cnt][$pos];
	$adname=$list->[$cnt][++$pos];
	$point=$list->[$cnt][++$pos];
	$limit=$list->[$cnt][++$pos];
	if($limit eq "0000-00-00 00:00:00"){
		$limit = "";
	}
	$del=$list->[$cnt][++$pos];
	$adurl=$list->[$cnt][++$pos] . '<br>' . $list->[$cnt][++$pos] . '<br>' . $list->[$cnt][++$pos] . '<br>' . $list->[$cnt][++$pos];

	#広告掲載数を取得
	$sthc=$db->prepare("SELECT DISTINCT adid, COUNT(admailno) 
	                   FROM tAdsetmail 
	                   WHERE adid=$id 
	                   GROUP BY adid;");
	$sthc->execute;
	$count=0;
	if($sthc && $sthc->rows==1){
		$rec = $sthc->fetchrow_arrayref;
		$count=$rec->[1];
	}
	$sthc->finish;


	#表の表示
	print "<tr class=\"focus\"><td><a href=\"/mod-perl/editad.mpl?page=$page&id=$id\">$id</a></td>\n";
	print "<td>$adname</td>\n";
	print "<td>$adurl</td>\n";
	print "<td>$point</td>\n";
	if( $del == 1){
		print "<td>" . '無効' . "</td>\n";
	}
	elsif($limit ne "" && $limit lt $now){
		print "<td>" . '期限切れ' . "</td>\n";
	}
	else{
		print "<td>" . '有効' . "</td>\n";
	}
	print "</tr>\n";
}
print "</table>\n";
$sth->finish ();
$db->disconnect ();
undef($db);

print "<table><tr>\n";
if($page > 1){
	#前ページを表示
	print "<td><form action=\"/mod-perl/rptad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"" . ($page-1) . "\">\n";
	print "<input type=\"submit\" value=\"" . '前ページへ' . "\"></td></form>";
}
if($page < $maxpage){
	#次ページを表示
	print "<td><form action=\"/mod-perl/rptad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"" . ($page+1) . "\">\n";
	print "<input type=\"submit\" value=\"" . '次ページへ' . "\"></td></form>";
}
print "</tr></table>\n";

print <<_HTML_FOOTER_;
		</div>

	</div><!-- ---------------------------------------------------------------------------- -->

	<!-- コピーライト -->
	<div id="copy">
		<div class="line"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
		(c)UP-STAIR 2009 All Rights Reserved
	</div>

</div>
_HTML_FOOTER_

print $form->end_html();

ModPerl::Util::exit();
