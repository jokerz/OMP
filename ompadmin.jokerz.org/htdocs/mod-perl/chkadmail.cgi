#!/usr/bin/perl -w
# 初期設定 -----------------------------------------------#

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Net::SMTP;
#use lib qw(../../common);
#use lib qw(/home/httpd/WebDB);
use lib qw(/home/vhosts/JKZ/extlib/common);
use lib qw(/home/vhosts/JKZ);
use MyClass::UsrWebDB;
use Data::Dumper;
use Goku::SiteSettings;
use Goku::Area;
use Goku::Output qw(ShowMsg);
use Goku::StrConv qw(ConvSJIS ReplaceHTML ReplaceHiddenData 
					 ReplaceHTMLTextArea ReplaceMailSubject 
					 ReplaceAdMailContents );
my $cgi = new CGI;
my %cookie = $cgi->cookie(-name=>'form_cookie');

my $admailno = $cgi->param('admailno');
my $from = $cgi->param('from');
my $client = $cgi->param('client');

my $subjectd = $cgi->param('subjectd');
my $contentsd = $cgi->param('contentsd');
my $maild = $cgi->param('maild');

my $subjectj = $cgi->param('subjectj');
my $contentsj = $cgi->param('contentsj');
my $mailj = $cgi->param('mailj');

my $subjecte = $cgi->param('subjecte');
my $contentse = $cgi->param('contentse');
my $maile = $cgi->param('maile');

my $subjecto = $cgi->param('subjecto');
my $contentso = $cgi->param('contentso');
my $mailo = $cgi->param('mailo');

sub ContentsCheck($$$$) {
	my ($db, $body, $count, $crr) = @_;
	my @msg = ('その他の送信内容が不正です',
			   'NTTドコモの送信内容が不正です',
			   'SoftBankの送信内容が不正です',
			   'AUの送信内容が不正です');
	#送信件数と、中身の確認
	if(0 == $count){return 'OK';}
	if($body eq "" && $count!=0){
	
		return $msg[$crr];
	}
	#広告コードの確認
	my ($sth, $row, $rec);
	my $list = $body;
	while ( $list=~ /$KEY_ADID/i) {
		my $key = $1;
		$sth=$db->prepare("
 select delad, adlimit ,unix_timestamp(adlimit) - unix_timestamp(now())
 from 1MP.tAdinfo where adid=$key;");
		$row=$sth->execute;
		if(!defined($row) || $row!=1){
			$sth->finish;
			return '不正な広告IDが含まれている可能性があります'
		}
		$rec=$sth->fetchrow_arrayref;
		if($rec->[0] == 1){
			$sth->finish;
			return '使用不可の広告IDが含まれている可能性があります';
		}
		if($rec->[1] ne "0000-00-00 00:00:00" && $rec->[2] < 0){
			$sth->finish;
			return '期限切れの広告IDが含まれている可能性があります';
		}
		$sth->finish;
		$list =$'; #'
	}
	return 'OK';
}1;

sub ShowInfo{
	#単にエラーをHTML出力し、脱出するだけ
    print "Content-type: text/html; charset=Shift_JIS\n\n";
    print "<HTML><HEAD>\n";
    print "<TITLE>" . '広告メール送信確認' . "</TITLE>\n";
    print "</HEAD><BODY>\n";
    print $_[0] . "<BR>\n";
	print "</BODY></HTML>";
}1;

#テストメール送信
sub SendTestMail($$$$$$){
	my ($admailno, $to, $from, $subject, $body, $crr) = @_;
	$subject = ReplaceMailSubject($subject, $crr);

	my($sp, $header);
	unless($sp = Net::SMTP->new('192.168.10.10')){
		return 0;
	}

	$header = Goku::StrConv::GetMailHeader(
		$subject, $from, $to, $crr, undef);
	#いきなりBASE64したものが欲しい
	$body = Goku::StrConv::GetTestMailBody($admailno,$body, $crr);
	$sp->mail($from);
	$sp->to($to);
	$sp->data();
	$sp->datasend($header);
	$sp->datasend("\n");
	$sp->datasend($body);
	$sp->dataend();
	$sp->quit();

warn Dumper ($sp);

	return 1;
};

#テストメール送信時の動き
#各種パラメーターのチェック
if($admailno ==0){
	#メール回数が不正
	ShowInfo('メール回数が不正です');
	exit;
}
if($client eq ""){
	#クライアント名が不正
	ShowInfo('クライアント名が不正です');
	exit;
}
if($from eq ""){
	#送信元メールアドレスが不正
	ShowInfo('送信元メールアドレスが不正です');
	exit;
}

##テストメール送信
##だるいソースだから誰か直して
if(defined $cgi->param('t_send_d') ){
	if($maild !~ /^([A-Z0-9\_\.\~\?\-\/]+)@([A-Z0-9\_\.\~\-]+)$/i){
		ShowInfo('DoCoMoテストメール送信先メールアドレスが不正です');
		exit;
	}
	if(SendTestMail($admailno, $maild, $from, $subjectd, $contentsd, 1)){
		ShowInfo('DoCoMoテストメール送信しました');
		exit;
	}else{
		ShowInfo('DoCoMoテストメール送信に失敗しました');
		exit;
	}
}
if(defined $cgi->param('t_send_j') ){
	if($mailj !~ /^([A-Z0-9\_\.\~\?\-\/]+)@([A-Z0-9\_\.\~\-]+)$/i){
		ShowInfo('SoftBankテストメール送信先メールアドレスが不正です');
		exit;
	}
	if(SendTestMail($admailno, $mailj, $from, $subjectj, $contentsj, 2)){
		ShowInfo('SoftBankテストメール送信しました');
		exit;
	}else{
		ShowInfo('SoftBankテストメール送信に失敗しました');
		exit;
	}
}
if(defined $cgi->param('t_send_e') ){
	if($maile !~ /^([A-Z0-9\_\.\~\?\-\/]+)@([A-Z0-9\_\.\~\-]+)$/i){
		ShowInfo('AUテストメール送信先メールアドレスが不正です');
		exit;
	}
	if(SendTestMail($admailno, $maile, $from, $subjecte, $contentse, 3)){
		ShowInfo('AUテストメール送信しました');
		exit;
	}else{
		ShowInfo('AUテストメール送信に失敗しました');
		exit;
	}
}
if(defined $cgi->param('t_send_o') ){
	if($mailo !~ /^([A-Z0-9\_\.\~\?\-\/]+)@([A-Z0-9\_\.\~\-]+)$/i){
		ShowInfo('その他テストメール送信先メールアドレスが不正です');
		exit;
	}
	if(SendTestMail($admailno, $mailo, $from, $subjecto, $contentso, 0)){
		ShowInfo('その他テストメール送信しました');
		exit;
	}else{
		ShowInfo('その他テストメール送信に失敗しました');
		exit;
	}
}


#DB接続
my($db, $sth, $row, $rec);
$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');
#先につないでおかないと動かない　直してくだちゃい
my @msg =( ContentsCheck($db, $contentsd, $cookie{sendmemd}, 1),
		   ContentsCheck($db, $contentsj, $cookie{sendmemj}, 2),
		   ContentsCheck($db, $contentse, $cookie{sendmeme}, 3),
		   ContentsCheck($db, $contentso, $cookie{sendmemo}, 0));
if(@msg = grep $_ ne 'OK', @msg){
	#どれかでエラーが発生した 且つOKは間引く
	$db->disconnect;
	undef($db);
	ShowInfo(join '<br>',@msg);
	exit;
}
$db->disconnect;
undef($db);

#値がまともであれば、クッキーに追加
$cookie{'from'} = $from;
$cookie{'client'} = $client;
$cookie{'subjectd'} = $subjectd;
$cookie{'contentsd'} = $contentsd;
$cookie{'subjectj'} = $subjectj;
$cookie{'contentsj'} = $contentsj;
$cookie{'subjecte'} = $subjecte;
$cookie{'contentse'} = $contentse;
$cookie{'subjecto'} = $subjecto;
$cookie{'contentso'} = $contentso;
my $form_cookie = $cgi->cookie(-name => 'form_cookie',
							   -value => \%cookie);

#############################
# 確認画面の表示
#############################
print $cgi->header(-type => 'text/html',
			 -charset => 'Shift_JIS',
			 -cookie => $form_cookie);
print << "END_OF_HERE_DOC";
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
			<a href="/app.mpl">トップ</a>＞広告管理＞<strong>メール広告メール確認</strong>
		</div>
		<!-- タイトル -->
		<div class="screen_title">
			<h2>広告管理</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

<!--
				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>
-->

<form action="/mod-perl/regadmail.cgi" method="post">
<input type="hidden" name="admailno" value="$admailno">

<!--<table border=0 cellpadding=3 cellspacing=1 bgcolor=#000000 width=720 align="center">-->
<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">
<tr>
<th nowrap bgcolor="#eeeaff" align="center" colspan="3">第${admailno}回メールマガジン確認画面</th>
</tr>

<tr>
<td bgcolor="#ffffff" colspan=3>$cookie{'msg_where'}</td>
<tr>
<td bgcolor="#eeeaff" colspan=2 width=30%>クライアント名</td>
<td bgcolor="#ffffff">$client</td>
</tr>
<tr>
<td bgcolor="#eeeaff" colspan=2>送信元メールアドレス</td>
<td bgcolor="#ffffff">$from</td>
</tr>
<tr>
<td bgcolor="#eeeaff" rowspan=3>NTTドコモ</td>
<td bgcolor="#eeeaff">送信対象者数</td>
<td bgcolor="#ffffff">$cookie{'sendmemd'}人</td>
</tr>
<tr>
<td bgcolor="#eeeaff" width=15%>タイトル</td>
<td bgcolor="#ffffff">$subjectd</td>
</tr>
<tr>
<td bgcolor="#eeeaff">本文</td>
<td bgcolor="#ffffff">$contentsd</td>
</tr>
<tr>
<td bgcolor="#eeeaff" rowspan=3>ボーダフォン</td>
<td bgcolor="#eeeaff">送信対象者数</td>
<td bgcolor="#ffffff">$cookie{'sendmemj'}人</td>
</tr>
<tr>
<td bgcolor="#eeeaff">タイトル</td>
<td bgcolor="#ffffff">$subjectj</td>
</tr>
<tr>
<td bgcolor="#eeeaff">本文</td>
<td bgcolor="#ffffff">$contentsj</td>
</tr>
<tr>
<td bgcolor="#eeeaff" rowspan=3>EZweb</td>
<td bgcolor="#eeeaff">送信対象者数</td>
<td bgcolor="#ffffff">$cookie{'sendmeme'}人</td>
</tr>
<tr>
<td bgcolor="#eeeaff">タイトル</td>
<td bgcolor="#ffffff">$subjecte</td>
</tr>
<tr>
<td bgcolor="#eeeaff">本文</td>
<td bgcolor="#ffffff">$contentse</td>
</tr>
<td bgcolor="#eeeaff" rowspan=3>その他</td>
<td bgcolor="#eeeaff">送信対象者数</td>
<td bgcolor="#ffffff">$cookie{'sendmemo'}人</td>
</tr>
<tr>
<td bgcolor="#eeeaff">タイトル</td>
<td bgcolor="#ffffff">$subjecto</td>
</tr>
<tr>
<td bgcolor="#eeeaff">本文</td>
<td bgcolor="#ffffff">$contentso</td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="3">
<input type="hidden" name="admailno" value="$admailno" />
<center>
  <input type="submit" name="sub_send" value="　送信　" />
</center>
</td>
</tr>
</table>
</form>
<br>
<a href="/mod-perl/rptad.mpl?page=1" target="_blank">広告ID表\示</a><p>
<a href="/mod-perl/rptadmail.mpl?page=1" target="_blank">送信履歴</a>

		</div>

	</div><!-- ---------------------------------------------------------------------------- -->

	<!-- コピーライト -->
	<div id="copy">
		<div class="line"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
		(c)UP-STAIR 2009 All Rights Reserved
	</div>

</div>

</body>
</html>
END_OF_HERE_DOC
exit;
