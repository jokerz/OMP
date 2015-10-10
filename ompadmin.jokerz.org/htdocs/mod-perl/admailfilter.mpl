
use strict;

use CGI::Carp qw(fatalsToBrowser);

#use lib qw(/home/vhosts/JKZ);
#use lib qw(/home/vhosts/dev.up-stair.jp/extlib/common);
use lib qw(/home/vhosts/JKZ);
use Goku::SiteSettings;
use Goku::Output qw(DumpAndExit);
use Data::Dumper;

my $cgi = new CGI;
my %cookie = $cgi->cookie(-name => 'form_cookie');
my %html_form; #HTMLのFORMの一部分 テンプレート対応のため
my $dmpstr;
$dmpstr = Dumper(\%cookie);

#キャリアのFORM作成
my $ca = $CARRIER{'docomo'};
$html_form{'carr'} =
"<input type=checkbox name=\"fca\" value=\"$ca\"";
if($cookie{'fca'} & (2 ** $ca)){
	$html_form{'carr'} .= " checked";
}
$html_form{'carr'} .= '>NTTドコモ' . "\n";
$ca = $CARRIER{'voda'};
$html_form{'carr'} .=
"<input type=checkbox name=\"fca\" value=\"$ca\"";
if($cookie{'fca'} & (2 ** $ca)){
	$html_form{'carr'} .= " checked";
}
$html_form{'carr'} .= '>ボーダフォン' . "\n";
$ca = $CARRIER{'ezweb'};
$html_form{'carr'} .=
"<input type=checkbox name=\"fca\" value=\"$ca\"";
if($cookie{'fca'} & (2 ** $ca)){
	$html_form{'carr'} .= " checked";
}
$html_form{'carr'} .= '>EZweb' . "\n";
$ca = $CARRIER{'other'};
$html_form{'carr'} .=
"<input type=checkbox name=\"fca\" value=\"$ca\"";
if($cookie{'fca'} & (2 ** $ca)){
	$html_form{'carr'} .= " checked";
}
$html_form{'carr'} .= '>その他' . "\n";
undef $ca;

#エラー回数のFORM作成
$html_form{'mail_err'} =
"<input type=text name=\"fsme\" value=\"$cookie{'fsme'}\" size=5 maxlength=4>" .
' ～ ' . "\n";
$html_form{'mail_err'} .=
 "<input type=text name=\"feme\" value=\"$cookie{'feme'}\" size=5 maxlength=4>\n";

#会員種別のFORM作成
$html_form{'mem_type'} =
"<input type=checkbox name=\"ftmem\" value=\"1\"";
if($cookie{'ftmem'}==1){
	$html_form{'mem_type'} .= " checked";
}
$html_form{'mem_type'} .= '>仮会員' . "\n";
$html_form{'mem_type'} .=
"<input type=checkbox name=\"frmem\" value=\"1\"";
if($cookie{'frmem'}==1){
	$html_form{'mem_type'} .= " checked";
}
$html_form{'mem_type'} .= '>会員' . "\n";

print "Content-type: text/html; charset=Shift_JIS\n\n";
print << "END_OF_HTML";
<html><head>
<link rel="stylesheet" type="text/css" href="/style.css" />
<script type="text/javascript" src="../js/jkl-form.js" charset="Shift_JIS"></script>
<script type="text/javascript" src="../js/jkl-calender.js" charset="Shift_JIS"></script>
</script>
<script>
<!--
var form1 = new JKL.Form("setwhere");
var cal1 = new JKL.Calender("cal_frsdate","setwhere","frsdate");
if ( ! cal1.getFormValue() ) cal1.setFormValue();
cal1.setStyle( "frame_color", "#3333CC" );

var cal2 = new JKL.Calender("cal_fredate","setwhere","fredate");
if ( ! cal2.getFormValue() ) cal2.setFormValue();
cal2.setStyle( "frame_color", "#CC3333" );

var cal3 = new JKL.Calender("cal_fdsdate","setwhere","fdsdate");
if ( ! cal3.getFormValue() ) cal3.setFormValue();
cal3.setStyle( "frame_color", "#3333CC" );

var cal4 = new JKL.Calender("cal_fdedate","setwhere","fdedate");
if ( ! cal4.getFormValue() ) cal4.setFormValue();
cal4.setStyle( "frame_color", "#CC3333" );
//-->
</script>
</head>
<body topmargin="10">
<!-- ヘッダー -->
<div id="head">
	<h1>OMP システム　管理者画面</h1>
</div>
<!-- //ヘッダー -->

<!-- メニュー縦バージョン -->
<script src="/js/cms_leftmenu.js" type="text/JavaScript"></script>

	<div id="main">
		<!-- タイトル -->
		<div class="screen_title">
			<h2>メール配信管理</h2>
		</div>
		<div id="list">
<fieldset><legend align="left"><img src="/images/arrow.gif" /> <font size="-2">メール配信管理</font><img src="/images/arrow.gif" />条件指定 &nbsp;&nbsp;</legend>
<table border=0 cellpadding=6 cellspacing=1 bgcolor=#999999 width=100% align="center">
<form action="addadmail.mpl" name="setwhere" method="post" id="setwhere">
<tr>
<td nowrap bgcolor=#eeeaff align=center colspan=3>送信条件指定</td>
</tr>
<tr>
<td bgcolor=#eeeaff colspan="2" width="18%">キャリア</td>
<td bgcolor=#ffffff>
<input type=checkbox name="fca" value="1" CHECKED class="box" id="fca1"><label for="fca1">&nbsp;NTTドコモ&nbsp;</label>
<input type=checkbox name="fca" value="2" CHECKED class="box" id="fca2"><label for="fca2">&nbsp;SOFTBANK&nbsp;</label>
<input type=checkbox name="fca" value="3" CHECKED class="box" id="fca3"><label for="fca3">&nbsp;AU&nbsp;</label>
<input type=checkbox name="fca" value="0" CHECKED class="box" id="fca0"><label for="fca0">&nbsp;その他&nbsp;</label>
</td>
</tr>
<tr>
<td bgcolor=#eeeaff colspan="2">メールエラー回数</td>
<td bgcolor=#ffffff>
<input type=text name="fsme" value="" size=5 maxlength=4> ～ 
<input type=text name="feme" value="" size=5 maxlength=4>
</td>
</tr>
<tr>
<td bgcolor=#eeeaff colspan=2>会員種別</td>
<td bgcolor=#ffffff>
<!-- Modified 2008/05/21 -->
<!-- BEGIN
<input type=checkbox class="box" name="frmem" value="2" checked id="frmem0"><label FOR="frmem0">&nbsp;仮会員&nbsp;</label>
<input type=checkbox class="box" name="frmem" value="1" checked id="frmem1"><label FOR="frmem1">&nbsp;会員&nbsp;</label>
END -->
<input type=checkbox class="box" name="frmem" value="1" checked id="frmem0"><label FOR="frmem0">&nbsp;仮会員&nbsp;</label>
<input type=checkbox class="box" name="frmem" value="2" checked id="frmem1"><label FOR="frmem1">&nbsp;会員&nbsp;</label>
</td>
</tr>
<tr>
<td bgcolor=#eeeaff colspan="2">登録日時</td>
<td bgcolor=#ffffff>
<input type="text" name="frsdate" value="" size=12 maxlength=12
 onClick="cal1.write(); cal2.hide();"
 onChange="cal1.getFormValue(); cal1.hide();">
<span id="cal_frsdate"></span>
　　　　　～　　　　　
<input type="text" name="fredate" value="" size=12 maxlength=12
 onClick="cal2.write(); cal1.hide();"
onChange="cal2.getFormValue(); cal2.hide();">
<span id="cal_fredate"></span>
</td></tr>
<td bgcolor=#eeeaff rowspan=10 width=3%>会員登録状態</td>
<td bgcolor=#eeeaff>残高ポイント</td>
<td bgcolor=#ffffff>
<input type=text name="fspoint" value="" size=5 maxlength=5> ～ 
<input type=text name="fepoint" value="" size=5 maxlength=5></td>
</tr>
<tr>
<td bgcolor=#eeeaff>性別</td>
<td bgcolor=#ffffff>
<input type=checkbox class="box"  name="frsex" value="0" checked id="frsex0"><label FOR="frsex0">&nbsp;秘密&nbsp;</label>
<input type=checkbox class="box"  name="frsex" value="1" checked id="frsex1"><label FOR="frsex1">&nbsp;男性&nbsp;</label>
<input type=checkbox class="box"  name="frsex" value="2" checked id="frsex2"><label FOR="frsex2">&nbsp;女性&nbsp;</label>
</td>
</tr>
<tr>
<td bgcolor=#eeeaff>年齢</td>
<td bgcolor=#ffffff>
<input type=text name="frsage" value="" size="4" maxlength="3"> ～ 
<input type=text name="freage" value=""size="4" maxlength="3">
</td>
</tr>
<tr>
<td bgcolor=#eeeaff>誕生日</td>
<td bgcolor=#ffffff>
<select name="fbsmonth" size="1">
<option selected>01
<option>02
<option>03

<option>04
<option>05
<option>06
<option>07
<option>08
<option>09
<option>10
<option>11
<option>12
</select>/
<select name="fbsday" size="1">
<option selected>01
<option>02
<option>03
<option>04
<option>05
<option>06

<option>07
<option>08
<option>09
<option>10
<option>11
<option>12
<option>13
<option>14
<option>15
<option>16
<option>17
<option>18
<option>19
<option>20
<option>21
<option>22
<option>23

<option>24
<option>25
<option>26
<option>27
<option>28
<option>29
<option>30
<option>31
</select> ～ 
<select name="fbemonth" size="1">
<option>01
<option>02
<option>03
<option>04
<option>05
<option>06

<option>07
<option>08
<option>09
<option>10
<option>11
<option selected>12
</select>/
<select name="fbeday" size="1">
<option>01
<option>02
<option>03
<option>04
<option>05
<option>06
<option>07
<option>08
<option>09

<option>10
<option>11
<option>12
<option>13
<option>14
<option>15
<option>16
<option>17
<option>18
<option>19
<option>20
<option>21
<option>22
<option>23
<option>24
<option>25
<option>26

<option>27
<option>28
<option>29
<option>30
<option selected>31
</select>
</td>
</tr>
<!-- Modified 2008/05/21 BEGIN -->
<!--
<tr>
<td bgcolor=#eeeaff>年収</td>
<td bgcolor=#ffffff>
<input type=checkbox class="box"  name="frincome" value="0" checked id="i0" /><label FOR="i0">&nbsp;秘密&nbsp;</label>
<input type=checkbox class="box"  name="frincome" value="1" checked id="i1" /><label FOR="i1">&nbsp;～299万円&nbsp;</label>
<input type=checkbox class="box"  name="frincome" value="2" checked id="i2" /><label FOR="i2">&nbsp;300万円～499万円&nbsp;</label>
<input type=checkbox class="box"  name="frincome" value="3" checked id="i3" /><label FOR="i3">&nbsp;500万円～999万円&nbsp;</label>
<input type=checkbox class="box"  name="frincome" value="4" checked id="i4" /><label FOR="i4">&nbsp;1000万円～&nbsp;</label>
</td>
</tr>
-->

<tr>
<td bgcolor=#eeeaff>HPカテゴリ</td>
<td bgcolor=#ffffff>
<input type=checkbox class="box" name="frHPCategory" value="0" checked id="HP0" /><label FOR="HP0">個人&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="1" checked id="HP1" /><label FOR="HP1">友達/友情&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="2" checked id="HP2" /><label FOR="HP2">学校&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="3" checked id="HP3" /><label FOR="HP3">小説/創作&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="4" checked id="HP4" /><label FOR="HP4">イラスト/絵&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="5" checked id="HP5" /><label FOR="HP5">写真/アート&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="6" checked id="HP6" /><label FOR="HP6">漫画/アニメ&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="7" checked id="HP7" /><label FOR="HP7">音楽&nbsp;</label>
<br />
<input type=checkbox class="box" name="frHPCategory" value="8" checked id="HP8" /><label FOR="HP8">趣味全般&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="9" checked id="HP9" /><label FOR="HP9">グルメ&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="10" checked id="HP10" /><label FOR="HP10">動物/ペット&nbsp;</label>
<input type=checkbox class="box" name="frHPCategory" value="11" checked id="HP11" /><label FOR="HP11">家族&nbsp;</label>
</td>
</tr>
<tr>
<td bgcolor=#eeeaff>系統</td>
<td bgcolor=#ffffff>
<input type=checkbox class="box"  name="frpersonality" value="0" checked id="p0" /><label FOR="p0" />&nbsp;普通系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="1" checked id="p1" /><label FOR="p1" />&nbsp;ギャル系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="2" checked id="p2" /><label FOR="p2" />&nbsp;姫系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="3" checked id="p3" /><label FOR="p3" />&nbsp;お嬢系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="4" checked id="p4" /><label FOR="p4" />&nbsp;キレイ目系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="5" checked id="p5" /><label FOR="p5" />&nbsp;かわいい系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="6" checked id="p6" /><label FOR="p6" />&nbsp;ゴージャス系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="7" checked id="p7" /><label FOR="p7" />&nbsp;萌え系&nbsp;</label>
<br />
<input type=checkbox class="box"  name="frpersonality" value="8" checked id="p8" /><label FOR="p8" />&nbsp;おとなしめ系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="9" checked id="p9" /><label FOR="p9" />&nbsp;癒し系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="10" checked id="p10" /><label FOR="p10" />&nbsp;さわやか系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="11" checked id="p11" /><label FOR="p11" />&nbsp;ギャグ系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="12" checked id="p12" /><label FOR="p12" />&nbsp;体育会系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="13" checked id="p13" /><label FOR="p13" />&nbsp;いかつい系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="14" checked id="p14" /><label FOR="p14" />&nbsp;ギャル男系&nbsp;</label>
<br />
<input type=checkbox class="box"  name="frpersonality" value="15" checked id="p15" /><label FOR="p15" />&nbsp;ホスト系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="16" checked id="p16" /><label FOR="p16" />&nbsp;ジャニーズ系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="17" checked id="p17" /><label FOR="p17" />&nbsp;硬派系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="18" checked id="p18" /><label FOR="p18" />&nbsp;ヤンキー系&nbsp;</label>
<input type=checkbox class="box"  name="frpersonality" value="19" checked id="p19" /><label FOR="p19" />&nbsp;アキバ系&nbsp;</label>
</td>
</tr>
<tr>
<td bgcolor=#eeeaff>血液型</td>
<td bgcolor=#ffffff>
<input type=checkbox class="box"  name="frbloodtype" value="1" checked id="b1" /><label FOR="b1" />&nbsp;Ａ&nbsp;</label>
<input type=checkbox class="box"  name="frbloodtype" value="2" checked id="b2" /><label FOR="b2" />&nbsp;ＡＢ&nbsp;</label>
<input type=checkbox class="box"  name="frbloodtype" value="3" checked id="b3" /><label FOR="b3" />&nbsp;Ｂ&nbsp;</label>
<input type=checkbox class="box"  name="frbloodtype" value="4" checked id="b4" /><label FOR="b4" />&nbsp;Ｏ&nbsp;</label>
</td>
</tr>

<tr>
<td bgcolor=#eeeaff>職業</td>
<td bgcolor=#ffffff>

<!-- Modified 2008/05/21 END -->

<!-- Modified 2008/05/21 BEGIN -->
<!-- BEGIN
<input type=checkbox class="box"  name="frjob" value="0" checked id="j0"><label FOR="j0">&nbsp;その他&nbsp;</label>
<input type=checkbox class="box"  name="frjob" value="1" checked id="j1"><label FOR="j1">&nbsp;学生&nbsp;</label>
<input type=checkbox class="box"  name="frjob" value="2" checked id="j2"><label FOR="j2">&nbsp;会社員&nbsp;</label>
<input type=checkbox class="box"  name="frjob" value="3" checked id="j3"><label FOR="j3">&nbsp;フリーター&nbsp;</label>
<input type=checkbox class="box"  name="frjob" value="4" checked id="j4"><label FOR="j4">&nbsp;主婦&nbsp;</label>
<input type=checkbox class="box"  name="frjob" value="5" checked id="j5"><label FOR="j5">&nbsp;自営業&nbsp;</label>
END -->
<!-- Modified 2008/05/21 END -->
<input type=checkbox class="box" name="frjob" value="0" checked id="j0" /><label FOR="j0">&nbsp;小学生&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="1" checked id="j1" /><label FOR="j1">&nbsp;中学生&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="2" checked id="j2" /><label FOR="j2">&nbsp;高校生&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="3" checked id="j3" /><label FOR="j3">&nbsp;専門学校生&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="4" checked id="j4" /><label FOR="j4">&nbsp;大学生&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="5" checked id="j5" /><label FOR="j5">&nbsp;大学院生&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="6" checked id="j6" /><label FOR="j6">&nbsp;浪人生&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="7" checked id="j7" /><label FOR="j7">&nbsp;フリーター&nbsp;</label>
<br />
<input type=checkbox class="box" name="frjob" value="8" checked id="j8" /><label FOR="j8">&nbsp;ニート&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="9" checked id="j9" /><label FOR="j9">&nbsp;夢追人&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="10" checked id="j10" /><label FOR="j10">&nbsp;自営業&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="11" checked id="j11" /><label FOR="j11">&nbsp;職人&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="12" checked id="j12" /><label FOR="j12">&nbsp;営業・事務&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="13" checked id="j13" /><label FOR="j13">&nbsp;医療・保健&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="14" checked id="j14" /><label FOR="j14">&nbsp;教育・福祉&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="15" checked id="j15" /><label FOR="j15">&nbsp;公務員&nbsp;</label>
<br />
<input type=checkbox class="box" name="frjob" value="16" checked id="j16" /><label FOR="j16">&nbsp;サービス&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="17" checked id="j17" /><label FOR="j17">&nbsp;法務&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="18" checked id="j18" /><label FOR="j18">&nbsp;経営&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="19" checked id="j19" /><label FOR="j19">&nbsp;マスコミ・芸能\ &nbsp;</label>
<input type=checkbox class="box" name="frjob" value="20" checked id="j20" /><label FOR="j20">&nbsp;芸術・デザイン&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="21" checked id="j21" /><label FOR="j21">&nbsp;技術・理工&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="22" checked id="j22" /><label FOR="j22">&nbsp;国際・貿易&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="23" checked id="j23" /><label FOR="j23">&nbsp;主婦&nbsp;</label>
<input type=checkbox class="box" name="frjob" value="24" checked id="j24" /><label FOR="j24">&nbsp;その他&nbsp;</label>

</td>
</tr>

<!-- Modified 2008/05/21 BEGIN -->
<!--
<tr>
<td bgcolor=#eeeaff>結婚</td>
<td bgcolor=#ffffff>
<input type=checkbox class="box"  name="frmar" value="0" checked id="frmar0"><label FOR="frma0">&nbsp;秘密&nbsp;</label>
<input type=checkbox class="box"  name="frmar" value="1" checked id="frmar1"><label FOR="frma1">&nbsp;未婚&nbsp;</label>
<input type=checkbox class="box"  name="frmar" value="2" checked id="frmar2"><label FOR="frma2">&nbsp;既婚&nbsp;</label>
</td>
</tr>
-->
<!-- Modified 2008/05/21 END -->

<tr>
<td bgcolor=#eeeaff>地域</td>
<td bgcolor=#ffffff>
<input type=checkbox class="box" name="frarea" value="1" id="area1" checked><label FOR="area1">&nbsp;北海道&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="2" id="area2" checked><label FOR="area2">&nbsp;青森&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="3" id="area3" checked><label FOR="area3">&nbsp;岩手&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="4" id="area4" checked><label FOR="area4">&nbsp;宮城&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="5" id="area5" checked><label FOR="area5">&nbsp;秋田&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="6" id="area6" checked><label FOR="area6">&nbsp;山形&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="7" id="area7" checked><label FOR="area7">&nbsp;福島&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="8" id="area8" checked><label FOR="area8">&nbsp;茨城&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="9" id="area9" checked><label FOR="area9">&nbsp;栃木&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="10" id="area10" checked><label FOR="area10">&nbsp;群馬&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="11" id="area11" checked><label FOR="area11">&nbsp;埼玉&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="12" id="area12" checked><label FOR="area12">&nbsp;千葉&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="13" id="area13" checked><label FOR="area13">&nbsp;東京&nbsp;</label>

<input type=checkbox class="box" name="frarea" value="14" id="area14" checked><label FOR="area14">&nbsp;神奈川&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="15" id="area15" checked><label FOR="area15">&nbsp;新潟&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="16" id="area16" checked><label FOR="area16">&nbsp;富山&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="17" id="area17" checked><label FOR="area17">&nbsp;石川&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="18" id="area18" checked><label FOR="area18">&nbsp;福井&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="19" id="area19" checked><label FOR="area19">&nbsp;山梨&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="20" id="area20" checked><label FOR="area20">&nbsp;長野&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="21" id="area21" checked><label FOR="area21">&nbsp;岐阜&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="22" id="area22" checked><label FOR="area22">&nbsp;静岡&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="23" id="area23" checked><label FOR="area23">&nbsp;愛知&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="24" id="area24" checked><label FOR="area24">&nbsp;三重&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="25" id="area25" checked><label FOR="area25">&nbsp;滋賀&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="26" id="area26" checked><label FOR="area26">&nbsp;京都&nbsp;</label>

<input type=checkbox class="box" name="frarea" value="27" id="area27" checked><label FOR="area27">&nbsp;大阪&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="28" id="area28" checked><label FOR="area28">&nbsp;兵庫&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="29" id="area29" checked><label FOR="area29">&nbsp;奈良&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="30" id="area30" checked><label FOR="area30">&nbsp;和歌山&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="31" id="area31" checked><label FOR="area31">&nbsp;鳥取&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="32" id="area32" checked><label FOR="area32">&nbsp;島根&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="33" id="area33" checked><label FOR="area33">&nbsp;岡山&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="34" id="area34" checked><label FOR="area34">&nbsp;広島&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="35" id="area35" checked><label FOR="area35">&nbsp;山口&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="36" id="area36" checked><label FOR="area36">&nbsp;徳島&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="37" id="area37" checked><label FOR="area37">&nbsp;香川&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="38" id="area38" checked><label FOR="area38">&nbsp;愛媛&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="39" id="area39" checked><label FOR="area39">&nbsp;高知&nbsp;</label>

<input type=checkbox class="box" name="frarea" value="40" id="area40" checked><label FOR="area40">&nbsp;福岡&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="41" id="area41" checked><label FOR="area41">&nbsp;佐賀&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="42" id="area42" checked><label FOR="area42">&nbsp;長崎&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="43" id="area43" checked><label FOR="area43">&nbsp;熊本&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="44" id="area44" checked><label FOR="area44">&nbsp;大分&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="45" id="area45" checked><label FOR="area45">&nbsp;宮崎&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="46" id="area46" checked><label FOR="area46">&nbsp;鹿児島&nbsp;</label>
<input type=checkbox class="box" name="frarea" value="47" id="area47" checked><label FOR="area47">&nbsp;沖縄&nbsp;</label>
<input value="全○" type="button" onclick="form1.selectAllOptions('frarea',true);">
<input value="全×" type="button" onclick="form1.selectAllOptions('frarea',false);">
</td>
</tr>
<tr>
<td bgcolor="white" colspan=3 align=center>
<input type="submit" name="memserch" value="  OK  " style="width:50%;">
</tr>
</table>
</form>
</fieldset>
		</div>
	<!-- フッター・コピーライト -->
	<div class="foot"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
	<div id="copy"><span class="copy_right">(c)UP-STAIR 2008 All Rights Reserved</span></div>
	<!-- //コピーライト -->
</div>
	</div>
</body>
</html>
END_OF_HTML

