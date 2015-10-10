
use strict;
use CGI::Carp qw(fatalsToBrowser);

use lib qw(/home/vhosts/JKZ);
use MyClass::WebUtil;
use MyClass::UsrWebDB;
use Data::Dumper;
use Goku::SiteSettings;
use Goku::Area;
use Goku::Output qw(ShowMsg);
use Goku::StrConv qw(ConvSJIS ReplaceHTML ReplaceHiddenData 
					 ReplaceHTMLTextArea);
use Goku::SetWhere;

my $admailno=0;
my $subjectd="";
my $contentsd="";
my $maild="";
my $subjectj="";
my $contentsj="";
my $mailj="";
my $subjecte="";
my $contentse="";
my $maile="";
my $subjecto="";
my $contentso="";
my $mailo="";
my $fsitelist="1";
my $message="";


my ($db, $sth, $row, $ret, $sql);

my $fromstr;
my $whrstr;

my $rec;
my $back=0;
my @work;
my @fslist;
my @crr;
my @income;
my @job;
my @mar;
my @area;
my @sex;
my $cnt=0;

my @URL=("/app.mpl",'戻る');


#############################
# ﾊﾟﾗﾒｰﾀの値を取得
#############################
my $cgi = CGI->new();
my %cookie;
my $clear = $cgi->param('clear'); #クッキークリアフラグ
unless($clear){
	#クリアフラグたたってないなら
	#クッキー取得
	%cookie = $cgi->cookie(-name => 'form_cookie');
}

my @fca = $cgi->param('fca'); #キャリア選択一覧
my $fca; #キャリア選択(ビットコード)
my $fsme = $cgi->param('fsme'); #エラー回数下限
my $feme = $cgi->param('feme'); #エラー回数上限
my $ftmem = $cgi->param('ftmem'); #仮会員
my $frmem = $cgi->param('frmem'); #会員
my $fspoint = $cgi->param('fspoint'); #ポイント下限
my $fepoint = $cgi->param('fepoint'); #ポイント下限
my @frsex = $cgi->param('frsex'); #性別
my $frsex; #性別(ビット)
my $frsage = $cgi->param('frsage'); #年齢下限
my $freage = $cgi->param('freage'); #年齢下限
my $fbsmonth = $cgi->param('fbsmonth'); #誕生日月　下限
my $fbsday = $cgi->param('fbsday'); #誕生日日 下限
my $fbemonth = $cgi->param('fbemonth'); #誕生日月　上限
my $fbeday = $cgi->param('fbeday'); #誕生日日　上限
my @frincome = $cgi->param('frincome'); #年収
my $frincome; #年収(ビット)
my @frjob = $cgi->param('frjob'); #職業
my $frjob; #職業(ビット)
my @frmar = $cgi->param('frmar'); #既婚未婚
my $frmar; #既婚(ビット)
my @frarea = $cgi->param('frarea'); #県名
my $frarea; #県名(ビット)
my $frsyear = $cgi->param('frsyear'); #登録日付年　下限
my $frsmonth = $cgi->param('frsmonth'); #登録日付月　下限
my $frsday = $cgi->param('frsday'); #登録日付日　下限
my $freyear = $cgi->param('freyear'); #登録日付年 上限
my $fremonth = $cgi->param('fremonth');#登録日付月 上限
my $freday = $cgi->param('freday');#登録日付日 上限
my $client = $cgi->param('client');#クライアント名
my $from = $cgi->param('from'); #送信者アドレス
unless($from){ $from = $SITE_DEFAULT_FROM; }
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

#############################
# DBをチェック
#############################
$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');

sub db_error_exit
{
	#DBエラーによる緊急脱出
	my @msgs = @_;
	ShowMsg(@msgs);
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	exit;
}

sub param_error_exit
{
	#パラメーターエラーの出力
	my @msgs = @_;
	ShowMsg(@msgs);
	exit;
}

#############################
# 検索条件を作成
#############################
my $where;
#クッキーの上書きが発生する
Goku::SetWhere::CreateWhere($cgi, \$whrstr, \$where, \%cookie);


MyClass::WebUtil::warnMSG_LINE (\$where, __LINE__);

#############################
# 最新のメール回数を取得
#############################
if($admailno == 0){
	$sth=$db->prepare("select max(admailno) from 1MP.tAdmail;");
	$row=$sth->execute ();
	if(!defined($row) || $row!=1){
		&db_error_exit('広告メール作成','情報の取得に失敗しました',1,@URL);
	}
	if($sth->rows>0){
		$rec=$sth->fetchrow_arrayref;
		$admailno=$rec->[0]+1;
	}else{
		$admailno=1;
	}
	$sth->finish ();
}


#############################
# 送信対象者数を取得
#############################
#my $sql =
#"select carrier, count(id_no) from HP_general.tMemberM left join HP_management.error_mail on
# tMemberM.mailaddr = error_mail.error_mailaddr $where group by carrier;";
my $sql =
"select carrier, count(owid) from 1MP.tMemberM left join 1MP.error_mail on
 tMemberM.mobilemailaddress = error_mail.error_mailaddr $where group by carrier;";

$sth = $db->prepare($sql);
$row = $sth->execute ();
if(!defined($row) || $row==0){
	&db_error_exit(
		'広告メール作成',
		"指定された条件では送信対象者がいません: $sql",1,@URL
		);
}

my ($sendmemd, $sendmemj, $sendmeme, $sendmemo) = (0,0,0,0);
while($rec=$sth->fetchrow_arrayref){
	if($rec->[0] == 2 ** $CARRIER{'docomo'}){
		$sendmemd +=$rec->[1];
	}elsif($rec->[0] == 2 ** $CARRIER{'voda'}){
		$sendmemj +=$rec->[1];
	}elsif($rec->[0] == 2 ** $CARRIER{'ezweb'}){
		$sendmeme +=$rec->[1];
	}else{
		$sendmemo +=$rec->[1];
	}
}
$sth->finish ();
$db->disconnect ();
undef($db);
$cookie{'sendmemd'} = $sendmemd;
$cookie{'sendmemj'} = $sendmemj;
$cookie{'sendmeme'} = $sendmeme;
$cookie{'sendmemo'} = $sendmemo;

my $setcont = ReplaceHTML($whrstr);
#"<a href=\"mailreplace.cgi?site=1&kind=$MAIL_KIND{'admail'}\" target=\"_blank\">" .
=pod
my $sub_page_link =
"<a href=\"mailreplace.cgi?site=1&kind=12\" target=\"_blank\">" .
'置換可能文字列表\示' . "</a><p>\n";
$sub_page_link .=
"<a href=\"rptad.mpl?page=1\" target=\"_blank\">" .
'広告ID表\示' . "</a><br>\n";
$sub_page_link .=
"<a href=\"rptadmail.mpl?page=1\" target=\"_blank\">" .
'送信履歴' . "</a><p>\n";
=cut

my %hidden_contents = ('d' => ReplaceHiddenData($contentsd,1),
					 'v' => ReplaceHiddenData($contentsj,1),
					 'e' => ReplaceHiddenData($contentse,1),
					 'o' => ReplaceHiddenData($contentso,1));
my %send_contents = ('d' => ReplaceHTMLTextArea($contentsd),
					 'v' => ReplaceHTMLTextArea($contentsj),
					 'e' => ReplaceHTMLTextArea($contentse),
					 'o' => ReplaceHTMLTextArea($contentso));

my $hidden_fromstr = ReplaceHiddenData( $fromstr , 1 );
my $hidden_whrstr = ReplaceHiddenData( $whrstr , 1 );
my $hidden_where = ReplaceHiddenData( $where , 1 );

#############################
# 広告メールの作成ページを表示
#############################
my $form_cookie = $cgi->cookie(-name => 'form_cookie',
						  -value => \%cookie);

print $cgi->header(-type => 'text/html',
						  -charset => 'Shift_JIS',
						  -cookie => $form_cookie);

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
			<a href="/app.mpl">トップ</a>＞広告管理＞<strong>メール 広告メール作成</strong>
		</div>
		<!-- タイトル -->
		<div class="screen_title">
			<h2>広告管理</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>



<!--<table style="border: solid 1px #000000;" cellpadding="0" cellspacing="0" width="100%" align="center">-->
<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">
<tr><td style="vertical-align:top;">

<table border=0 cellpadding=2 cellspacing=1 bgcolor=#999999 width="100%" align="center">
<tr>
<th nowrap bgcolor=#eeeaff align=center colspan=3> 第${admailno}回メールマガジン </th>
</tr>

<tr>
<td bgcolor=#ffffff colspan="3">$cookie{'msg_where'}<br>
<form action="/mod-perl/admailfilter.mpl" method=post>
<input type=hidden name="admailno" value="$admailno">
<input type="submit" value="条件指定" onclick="init();" id="content" />
</form></td>
</tr>

<!--form action="/master/perl-cgi/chkadmail.cgi" method=post-->
<form action="/mod-perl/chkadmail.cgi" method=post>
<input type=hidden name="admailno" value="$admailno">

<tr>
<th colspan=2>クライアント名
</td>
<td bgcolor=#ffffff>
<input type="text" name="client" size="70" maxlength="50" value="$cookie{'client'}"></td>
</tr>

<tr>
<th colspan=2>送信元メールアドレス
</td>
<td bgcolor=#ffffff>
<input type="text" name="from" size="70" maxlength="50" value="$cookie{'from'}"></td>
</tr>

<tr>
<th rowspan=5>NTTドコモ</td>
<th>送信対象者数</td>
<td bgcolor=#ffffff>$cookie{'sendmemd'}人</td>
</tr>

<tr>
<th>注意事項</td>
<td bgcolor=#ffffff><font color=red>絵文字を入力する場合は、${KEY_DOCOMO_SHOW} (XXXXはS-JISコードの16進数)の形で入力してください<br>
例）晴れマーク  : ${KEY_DOCOMO_CHECK}F89F${KEY_BASE_END}</font></td>
</tr>
<tr>
<th>タイトル</td>
<td bgcolor=#ffffff>
<input type="text" name="subjectd" size="70" maxlength="136" value="$cookie{'subjectd'}"></td>
</tr>
<tr>
<th>本文</td>
<td>
<textarea name="contentsd" rows="14" cols="48">$cookie{'contentsd'}
</textarea></td>
</tr>
<tr>
<th>メールアドレス<br>(テストメール送信用)</td>
<td bgcolor=#ffffff>
<input type="text" name="maild" size="50" maxlength="100" value="$maild" /><br>
<input type="submit" name="t_send_d" value="NTTドコモ テストメール送信" onclick="init();" id="content" /> ←表\示している内容でテストメールを送信します</td>
</tr>

<tr>
<th rowspan=4>SOFTBANK</td>
<th>送信対象者数</td>
<td bgcolor=#ffffff>$cookie{'sendmemj'}人</td>
<tr>
<th>タイトル</td>
<td bgcolor=#ffffff>
<input type="text" name="subjectj" size="70" maxlength="136" value="$cookie{'subjectj'}"></td>
</tr>
<tr>
<th>本文</td>
<td><textarea name="contentsj" rows="14" cols="48">$cookie{'contentsj'}</textarea></td>
</tr>
<tr>
<th>メールアドレス<br>(テストメール送信用)</td>
<td bgcolor=#ffffff>
<input type="text" name="mailj" size="30" maxlength="100" value="$mailj" /><br>
<input type="submit" name="t_send_j" value="SOFTBANK テストメール送信" onclick="init();" id="content" />←表\示している内容でテストメールを送信します</td>
</tr>

<tr>
<th rowspan=5>AU</td>
<th>送信対象者数</td>
<td bgcolor=#ffffff>$cookie{sendmeme}人</td>
</tr>
<tr>
<th>注意事項</td>
<td bgcolor=#ffffff><font color=red>絵文字を入力する場合は、${KEY_EZWEB_SHOW} (xはアイコン番号)の形で入力してください<br>
例）晴れマーク  :  ${KEY_EZWEB_CHECK}44${KEY_BASE_END}</font><br>
</tr>
<tr>
<th>タイトル</td>
<td bgcolor=#ffffff>
<input type="text" name="subjecte" size="70" maxlength="136" value="$cookie{'subjecte'}"></td>
</tr>

<tr>
<th>本文</td>
<td bgcolor=#ffffff><textarea name="contentse" rows="14" cols="48">$cookie{'contentse'}</textarea></td>
</tr>
<tr>
<th>メールアドレス<br>(テストメール送信用)</td>
<td bgcolor=#ffffff>
<input type="text" name="maile" size="30" maxlength="100" value="$maile" /><br>
<input type="submit" name="t_send_e" value="AU テストメール送信" onclick="init();" id="content" />←表\示している内容でテストメールを送信します</td>
</tr>

<tr>
<th rowspan=4>その他</td>
<th>送信対象者数</td>
<td bgcolor=#ffffff>$cookie{'sendmemo'}人</td>
<tr>
<th>タイトル</td>
<td bgcolor=#ffffff>
<input type="text" name="subjecto" size="70" maxlength="136" value="$cookie{'subjecto'}"></td>
</tr>

<tr>
<th>本文</td>
<td><textarea name="contentso" rows="14" cols="48">$cookie{'contentso'}</textarea></td>
</tr>
<tr>
<th>メールアドレス<br>(テストメール送信用)</td>
<td bgcolor=#ffffff>
<input type="text" name="mailo" size="30" maxlength="100" value="$mailo" /><br>
<input type="submit" name="t_send_o" value="その他 テストメール送信" onclick="init();" id="content" />←表\示している内容でテストメールを送信します</td>
</tr>

<tr>
<td bgcolor="white" colspan=4><center>
<input type="submit" name="exec" value="　確　認　　画　面　" onclick="init();" id="content" />
</td>
</tr>
</table>

</td></tr></table>
</form>
<br>
</font><p>

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
_HTML_HEADER_

ModPerl::Util::exit();
