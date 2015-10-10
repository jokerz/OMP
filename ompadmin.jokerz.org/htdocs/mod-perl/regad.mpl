#!/usr/bin/perl -w
# 初期設定 -----------------------------------------------#

use strict;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(/home/vhosts/JKZ/extlib/common);
use lib qw(/home/vhosts/JKZ);
use MyClass::UsrWebDB;
use Goku::SiteSettings;
use Goku::Output qw(ShowMsg);
use Goku::StrConv qw(ConvSJIS ReplaceFieldValue);
use Data::Dumper;

my $q = CGI->new();

#########################
#  広告メール掲載・アクセス集計のパラメータ
#########################

my $buffer;
my @pairs;
my $k;
my $page=1;
my $id="";
my $adname="";
my $urld="";
my $urlj="";
my $urle="";
my $urlo="";
my $limityear="";
my $limitmonth="";
my $limitday="";
my $limithour="";
my $limitmin="";
my $nolimit="";
my @work;
my $point=0;
my $delad=0;
my $update=0;
my $limit;

my $db;
my $dba;
my $sth="";
my $stha="";

my $setid;
my $rec;
my $commoncond;
my $s_cnt;
my $cnt;
my $cond;
my $row;

my $mailcnt=0;
my $access=0;
my $publish=0;
my $rst_num=0;
my $num=0;
my $rst_csl=0;
my $resetinfo=0;
my $find=0;

my $table;
my @adcount_tables=();

#############################
# 渡された値を変数へｾｯﾄ
#############################
if ($ENV{'REQUEST_METHOD'} eq 'POST') {
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    @pairs = split(/&/,$buffer);
}
else {
	if($ENV{'QUERY_STRING'} ne ""){
	    @pairs = split(/&/,$ENV{'QUERY_STRING'});
	}
}
#############################
# ﾊﾟﾗﾒｰﾀの値を取得
#############################
my $pcnt;
my @pwork;

if ($pwork[0] =~ /^rst(\d+)$/i){
		if(defined($pwork[1])){
			$rst_num=$1;
		}
	}

## Modified 2008/07/03
#my %QueryCGI = $q->Vars ();
#map { "\$$_" = $QueryCGI{$_} } keys %QueryCGI;


## Modified  不足パラメータ追加 2008/10/14
$setid  = $q->param('setid');
$point  = $q->param('point');


$urld	= $q->param('urld');
$urlj	= $q->param('urlj');
$urle	= $q->param('urle');
$urlo	= $q->param('urlo');
$id		= $q->param('id');
$page	= $q->param('page');
$adname	= $q->param('adname');
$limityear	= $q->param('limityear');
$limitmonth = $q->param('limitmonth');
$limitday	= $q->param('limitday');
$limithour	= $q->param('limithour');
$nolimit	= $q->param('nolimit');
$delad		= $q->param('delad');
$update		= $q->param('update');
$commoncond = $q->param('commoncond');
$resetinfo	= $q->param('resetinfo');
$mailcnt	= $q->param('mailcnt');
$publish	= $q->param('publish');
$access		= $q->param('access');



## Modified 2008/10/14
my @URL = ("/mod-perl/editad.mpl?page=$page&id=$id", '←戻る');
my @LIST = ("/mod-perl/rptad.mpl?page=$page", '←戻る');

#############################
# パラメータの値をチェック
#############################
if(grep($_ eq '', ($urld, $urlj, $urle, $urlo)) ){
	#URLが不正 どれか1つでも空ならば
	ShowInfo ('URLが不正です');
	ModPerl::Util::exit ();
}


#############################
# 操作種別をチェック
#############################
if($rst_num > 0) {
	### リセット指定
	if($id != $rst_num) {
		### 実際の編集広告コードとリセット対象広告コードが異なる場合
		ShowInfo('リセット対象の広告コードが不正です');
		ModPerl::Util::exit ();
	}

	print "Content-Type: text/html; charset=Shift_JIS\n\n";
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
			<a href="/app.mpl">トップ</a>＞広告管理＞<strong>メール広告コード情報編集＜リセット＞</strong>
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

	print "<form action=\"/mod-perl/editad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=hidden name=\"id\" value=\"$id\">\n";
	print "<input type=hidden name=\"setid\" value=\"$setid\">\n";
	#print "<table border=1 cellpadding=3 cellspacing=0 width=\"100%\">\n";
print qq(<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">);
	if($resetinfo==1) {
		print "<captoin>" . '広告コード：' . $id . '　の集計値リセットを解除します。<br>宜しければ解除ボタンを押して下さい。' . "</caption>\n";
		$rst_csl=1;
	}
	else {
		print "<captoin>" . '広告コード：' . $id . '　の集計値をリセットします。<br>宜しければリセットボタンを押して下さい。' . "</caption>\n";
	}
	print "<br /><br />\n";
	print "<tr><td nowrap bgcolor=#eeeaff align=center colspan=3>";
	print '広告コード：' . $id . "\n";
	print "<br>\n";
	print 'メルマガ掲載数：' . $mailcnt . "</td></tr>\n";
	print "<tr>\n";
	print "<td bgcolor=#eeeaff colspan=2>" . '配信数' . "</td>\n";
	print "<td>" . $publish . "</td></tr>\n";
	print "<tr>\n";
	print "<td bgcolor=#eeeaff colspan=2>" . 'アクセス数' . "</td>\n";
	print "<td>" . $access . "</td></tr>\n";
	print "</td></tr>\n";
	print "<tr><td bgcolor=#eeeaff colspan=2 width=\"40%\">" . '名称' . "</td>\n";
	print "<td bgcolor=#ffffff>" . $adname . "</td></tr>\n";
	print "<tr><td bgcolor=#eeeaff rowspan=2 width=\"20%\">" . 'サイト指定' . "</td>\n";
	print "<td bgcolor=#eeeaff width=\"20%\">" . '条件' . "</td>\n";
	print "<tr><td bgcolor=#eeeaff width=\"20%\">" . '選択' . "</td>\n";
	print "<td bgcolor=#ffffff>";
	print "</td></tr>\n";
	print "<tr> \n";
	print "<td bgcolor=white colspan=3 align=center>\n";
	print "<table border=0 cellspacing=0 cellpadding=0>\n";
	print "<tr><td>\n";
	if($rst_csl==1) {
		print "<input type=\"submit\" value=\"解除\">\n";
		print "<input type=hidden name=\"reset\" value=\"0\">\n";
	}
	else {
		print "<input type=\"submit\" value=\"リセット\">\n";
		print "<input type=hidden name=\"reset\" value=\"1\">\n";
	}
	print "</td>\n";
	print "</form>\n";
	print "<td>\n";
	print "<form action=\"/mod-perl/editad.cgi\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=hidden name=\"id\" value=\"$id\">\n";
	print "<input type=hidden name=\"reset\" value=\"$resetinfo\">\n";
	print "&nbsp;&nbsp;";
	print "<input type=\"submit\" value=\"" . 'キャンセル' . "\">";
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "</table>\n";
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
	print "</body>\n";
	print "</html>\n";
	ModPerl::Util::exit();
}

#############################
# DBをチェック
#############################

$db = MyClass::UsrWebDB::connect();
$db->do("set names sjis");
#############################
# パラメータの値をチェック
#############################
if($nolimit eq ""){
	#有効期限をチェック
	#正規表現使えや
	$limit = $limityear . "-" . $limitmonth . "-" . $limitday . " " . $limithour . ":" . $limitmin . ":00";
	my $chkyear=sprintf("%04d",$limityear);
	my $chkmonth=sprintf("%02d",$limitmonth);
	my $chkday=sprintf("%02d",$limitday);
	my $chkhour=sprintf("%02d",$limithour);
	my $chkmin=sprintf("%02d",$limitmin);
	
	$sth=$db->prepare("select date_add('$limit', interval 0 day),
				      date_format(date_add('$limit', interval 0 day), '%Y'), 
					  date_format(date_add('$limit', interval 0 day), '%m'), 
					  date_format(date_add('$limit', interval 0 day), '%d'), 
					  date_format(date_add('$limit', interval 0 day), '%H'), 
					  date_format(date_add('$limit', interval 0 day), '%i');");
	$sth->execute;
	
	if(!$sth || $sth->rows == 0){
		&ShowInfo('有効期限が不正です');
		$sth->finish;
		$db->disconnect;
		undef($db);
		ModPerl::Util::exit ();
	}
	$rec=$sth->fetchrow_arrayref;
	if($rec->[0] eq ""){
		&ShowInfo('有効期限が不正です');
		$sth->finish;
		$db->disconnect;
		undef($db);
		ModPerl::Util::exit ();
	}
	if($rec->[1] ne $chkyear || $rec->[2] ne $chkmonth || $rec->[3] ne $chkday || $rec->[4] ne $chkhour || $rec->[5] ne $chkmin){
		&ShowInfo('有効期限が不正です');
		$sth->finish;
		$db->disconnect;
		undef($db);
		ModPerl::Util::exit ();
	}
	$limit = $rec->[0];
	$sth->finish;
}
else{
	$limit = "";
}

#############################
# 同一の広告IDがあるかをチェック
#############################
$sth=$db->prepare("select adid from HP_management.tAdinfo where adid = $setid;");
$sth->execute;
if(!$sth){
	#エラーが発生したので中断
	ShowInfo('広告URLの登録に失敗しました');
	$sth->finish;
	$db->disconnect;
	undef($db);
	ModPerl::Util::exit ();
}

if($sth->rows > 0 && $update == 0){
	#上書きを確認
	print "Content-type: text/html; charset=Shift_JIS\n\n";
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
			<a href="/app.mpl">トップ</a>＞広告管理＞<strong>メール広告コード情報編集＜登録＞</strong>
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

	print '広告コードの情報を上書きしてもよろしいですか？' . "\n";
	print "<p>\n";
	
	print qq(<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">);
	print "<td><form action=\"/mod-perl/regad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=hidden name=\"id\" value=\"$id\">\n";
	print "<input type=hidden name=\"setid\" value=\"$setid\">\n";
	print "<input type=hidden name=\"adname\" value=\"$adname\">\n";
	print "<input type=hidden name=\"urld\" value=\"$urld\">\n";
	print "<input type=hidden name=\"urlj\" value=\"$urlj\">\n";
	print "<input type=hidden name=\"urle\" value=\"$urle\">\n";
	print "<input type=hidden name=\"urlo\" value=\"$urlo\">\n";
	print "<input type=hidden name=\"limityear\" value=\"$limityear\">\n";
	print "<input type=hidden name=\"limitmonth\" value=\"$limitmonth\">\n";
	print "<input type=hidden name=\"limitday\" value=\"$limitday\">\n";
	print "<input type=hidden name=\"limithour\" value=\"$limithour\">\n";
	print "<input type=hidden name=\"limitmin\" value=\"$limitmin\">\n";
	print "<input type=hidden name=\"nolimit\" value=\"$nolimit\">\n";
	print "<input type=hidden name=\"point\" value=\"$point\">\n";
	print "<input type=hidden name=\"delad\" value=\"$delad\">\n";
	print "<input type=hidden name=\"update\" value=1>\n";
	print "<input type=hidden name=\"reset\" value=\"$resetinfo\">\n";
	print qq(<input type="submit" value="　上　書　" onclick="init();" id="content" />);
	print "</form></TD>\n";
	print "<td><form action=\"/mod-perl/rptad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=\"submit\" value=\"" . 'キャンセル' . "\">";
	print "</form></td>\n";
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
	
	print "</body>\n";
	print "</html>\n";
	ModPerl::Util::exit();
}

#############################
# 情報の更新
#############################
eval{
	$db->do("set autocommit = 0") || die "トランザクション開始失敗\n";
	$db->do("begin") || die "トランザクション開始失敗\n";
	
	my $sadname = ReplaceFieldValue($adname);
	#広告URLの追加
	$sth=$db->prepare("
replace into 1MP.tAdinfo (adid, adname, adpoint, adlimit, delad, urld, urlj,
urle, urlo ) values ($setid, '$sadname', $point, '$limit', $delad, '$urld',
'$urlj', '$urle', '$urlo');");
	$sth->execute || die "広告URL情報登録失敗\n";
	
	$sth->finish;
	
	#############################
	# リセット指定の場合、掲載数とアクセス数を更新
	#############################
	if($resetinfo == 1) {

		$dba = MyClass::UsrWebDB::connect();
		$dba->do("set names sjis");
		$dba->do("set autocommit=0") || die "トランザクション開始失敗\n";
		$dba->do("begin") || die "トランザクション開始失敗\n";
		
		$stha = $dba->prepare("show tables");
		$row = $stha->execute;
		if(defined($row) && $row>0) {
			$cnt=0;
			$stha->bind_columns(\$table);
			while($rec = $stha->fetchrow_arrayref){
				if($table =~ /ad\d{6}/){
					push @adcount_tables, $table;
				}
			}
		}
		
		foreach (@adcount_tables){
			# 配信数を累計掲載数種別に変更
			$dba->do("
update $_ set kind = $SUM_KIND{'publish_total'} 
where mailkind = $MAIL_KIND{'admail'} and adid=$id and 
kind = $SUM_KIND{'publich'};") || die "配信数情報更新エラー\n";
			# アクセス数を累計アクセス数種別に変更
			$dba->do("
update $_ set kind = $SUM_KIND{'access_total'} 
where mailkind = $MAIL_KIND{'admail'} adid=$id and 
kind = $SUM_KIND{'access'};") || die "アクセス数情報更新エラー\n";
		}
	}
};# end of eval

if ($@) {
    # もし、DBIがRaiseErrorでdieしたら、$@ には$DBI::errstrが入っています。
	# 登録失敗
    $db->do("rollback");
    $db->do("set autocommit=1");
	$db->disconnect;
	undef($db);
	if($resetinfo == 1) {
	    $dba->do("rollback");
	    $dba->do("set autocommit=1");
		$dba->disconnect;
		undef($dba);
	}
	ShowInfo('広告コード情報の更新に失敗しました');
	print Dumper(\$@);
	ModPerl::Util::exit();
} else {
    $db->do("commit");
    $db->do("set autocommit=1");
	$db->disconnect;
	undef($db);
	if($resetinfo == 1) {
	    $dba->do("commit");
	    $dba->do("set autocommit=1");
		$dba->disconnect;
		undef($dba);
	}
}

ShowMsg('広告コード情報編集＜登録＞','広告コード情報の更新に成功しました', 1, @LIST);
ModPerl::Util::exit();

sub ShowInfo() {
	my $message;
	($message)=@_;
	
	print "Content-type: text/html; charset=Shift_JIS\n\n";
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
   	<div id="side">
		<script src="/js/cms_leftmenu.js" type="text/JavaScript"></script>
	</div>
	<div id="main"><!-- ---------------------------------------------------------------------------- -->
		<!-- パンくず -->
		<div id="pankuzu">
			<a href="/app.mpl">トップ</a>＞広告管理＞<strong>メール広告コード情報編集＜登録＞</strong>
		</div>
		<!-- タイトル -->
		<div class="screen_title">
			<h2>広告管理</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>
_HTML_HEADER_

	print $message . "\n";
	print "<p>\n";
	
	print "<form action=\"/mod-perl/editad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=hidden name=\"id\" value=\"$id\">\n";
	print "<input type=hidden name=\"setid\" value=\"$setid\">\n";
	print "<input type=hidden name=\"adname\" value=\"$adname\">\n";
	print "<input type=hidden name=\"urld\" value=\"$urld\">\n";
	print "<input type=hidden name=\"urlj\" value=\"$urlj\">\n";
	print "<input type=hidden name=\"urle\" value=\"$urle\">\n";
	print "<input type=hidden name=\"urlo\" value=\"$urlo\">\n";
	print "<input type=hidden name=\"limityear\" value=\"$limityear\">\n";
	print "<input type=hidden name=\"limitmonth\" value=\"$limitmonth\">\n";
	print "<input type=hidden name=\"limitday\" value=\"$limitday\">\n";
	print "<input type=hidden name=\"limithour\" value=\"$limithour\">\n";
	print "<input type=hidden name=\"limitmin\" value=\"$limitmin\">\n";
	print "<input type=hidden name=\"nolimit\" value=\"$nolimit\">\n";
	print "<input type=hidden name=\"point\" value=\"$point\">\n";
	print "<input type=hidden name=\"delad\" value=\"$delad\">\n";
	print "<input type=hidden name=\"update\" value=1>\n";
	print "<input type=\"submit\" value=\"" . '戻る' . "\">";
	print "</form>\n";
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
	print "</body>\n";
	print "</html>\n";

}
