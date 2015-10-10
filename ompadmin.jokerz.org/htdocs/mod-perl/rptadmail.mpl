# 初期設定 -----------------------------------------------#

use strict;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(/home/vhosts/JKZ);
use MyClass::WebUtil;
use MyClass::UsrWebDB;
#use JKZ::WebEnvConf qw ($HASHTB $HASHURL);
use lib qw(/home/vhosts/JKZ/extlib/common);
require "r_html.pl";
require "get_nowdata.pl";
require "show_msg.pl";
require "errdebmsg.pl";
require "server_state.pl";


#**********************************
# 広告管理テーブルのハッシュを参照
# WebEnvConfは使用しない
# 暫定対応 2010/01/31
#**********************************
my $HASHTB = {
		KARA_MAIL		=>	'1MP.tKaraMailF',
		MEMBER			=>	'1MP.tMemberM',
		USERIMAGE		=>	'1MP.tUserImageM',
	## ここからは管理専用DB
		ADCONTENTS		=>	'1MP.tAdcontents',
		ADINFO			=>	'1MP.tAdinfo',
		ADMAIL			=>	'1MP.tAdmail',
		#####@このテーブルは何回目の配信か数字が末尾につくadmailmanage1 admailmanage3 とか
		ADMAILMANAGE	=>	'1MP.tAdmailmanage',
		ADMAILSETTING	=>	'1MP.tAdmailsetting',
		ADSETMAIL		=>	'1MP.tAdsetmail',
		BANNER			=>	'1MP.tBannerDataM',
		BANNERDATA		=>	'1MP.tBannerDataF',
		LINKCONT		=>	'1MP.tLinkcontents',
		MAILCONF		=>	'1MP.tMailConf',
		MAILTYPE		=>	'1MP.tMailType',
		MEMINFO			=>	'1MP.tMemberInfo',
		MEMINTRINFO		=>	'1MP.tMemberIntrInfo',
		REGTYPE			=>	'1MP.reg_type',
		REGERR			=>	'1MP.tRegErr',
	## ここから下はlogdataデータベース
		ERRORMAIL		=>	'HP_logdata.tErrorMailF',
		BANNERCOUNT		=>	'HP_logdata.tBannerCountF_',
		BANNERCLICK		=>	'HP_logdata.tBannerClickF_',
};




my $form = CGI->new();
my @pairs;
my $k;
my $page=1;
my $admailno=0;
my $db;
my $sth="";
my $rec;
my $senddate;
my $basedate;
my $subject;
my $contents;
my $table;
my $sendcnt;
my $errcnt;
my $today;
my $chkdate;
my $dispdate;
my $dateflag;
my $sethour;
my $setcont;
my $stha;
my $sthc;
my $start;

my $cnt;
my $list;
my $max;
my $listnum;
my $maxpage;
my $startpos;
my $offset;
my $dba;
my $reca;
my $limit;

my $sendngcnt;

#****************************
# 渡された値を変数へセット
#****************************
if ($ENV{'REQUEST_METHOD'} eq 'POST') {
	#****************************
	# パラメータの値を取得
	#****************************
	$page=$form->param("page");
}
else {
	if($ENV{'QUERY_STRING'} ne ""){
	    @pairs = split(/&/,$ENV{'QUERY_STRING'});
	
		#****************************
		# パラメータの値を取得
		#****************************
		($k,$page) = split(/=/,$pairs[0]);
	}
}

my @URL=("/app.mpl",'戻る');

#****************************
# DBをチェック
#****************************

$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');
#****************************
# SQLを実行
#****************************
=pod
my $chksql = "SELECT admailno, senddate, sendend, status, client, 
IF(
  (sendd=1 AND sendj=0 AND sende=0 AND sendo=0),
  subjectd,IF((sendd=0 AND sendj=1 AND sende=0 AND sendo=0),
  subjectj,IF((sendd=0 AND sendj=0 AND sende=1 AND sendo=0), subjecte, subjecto))
 ) AS subject, 
 IF(
 (sendd=1 AND sendj=0 AND sende=0 AND sendo=0),contentsd,
  IF(
  (sendd=0 AND sendj=1 AND sende=0 AND sendo=0), contentsj,IF((sendd=0 AND sendj=0 AND sende=1 AND sendo=0), contentse, contentso)
  )
 ) AS contents 
 FROM  tAdmail ORDER BY admailno DESC";
=cut
#$sth=$db->prepare("SELECT admailno, 
#                          senddate,
#                          sendend,
#                          status,
#                          client,
#                          IF((sendd=1 AND sendj=0 AND sende=0 AND sendo=0), subjectd,IF((sendd=0 AND sendj=1 AND sende=0 AND sendo=0), subjectj,IF((sendd=0 AND sendj=0 AND sende=1 AND sendo=0), subjecte, subjecto))) AS subject,
#                          IF((sendd=1 AND sendj=0 AND sende=0 AND sendo=0), contentsd,IF((sendd=0 AND sendj=1 AND sende=0 AND sendo=0), contentsj,IF((sendd=0 AND sendj=0 AND sende=1 AND sendo=0), contentse, contentso))) AS contents,
#                          condition
#                   FROM admail ORDER BY admailno DESC;");

## Modified 2008/07/03
my $chksql = "SELECT admailno, senddate, sendend, status, client,
 IF(
  (sendd > 0),subjectd,
   IF((sendj>0), subjectj,
    IF((sende>0), subjecte, subjecto)
   )
 ) AS subject, 
 IF(
 (sendd > 0),contentsd,
  IF(
   (sendj > 0), contentsj,
   IF((sende > 0), contentse, contentso)
  )
 ) AS contents 
 FROM  tAdmail ORDER BY admailno DESC";
$sth = $db->prepare ($chksql);
$sth->execute ();

if(!$sth){
	&ShowMsg('送信履歴','情報の取得に失敗しました',1, @URL);
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	ModPerl::Util::exit();
}

if($sth->rows==0){
	#表示するメール回数がないのでエラーとする
	&ShowMsg('送信履歴','表示する情報がありません',1,@URL);
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	ModPerl::Util::exit();
}

$max=$sth->rows;
$list=$sth->fetchall_arrayref();

#****************************
# 回数の最大数を取得
#****************************

$listnum = 15;
$maxpage=int($max / $listnum);
if($max % $listnum){
	$maxpage++;
}

if($maxpage == 0){
	#追加と管理トップへ戻るのみを表示
	&ShowMsg('送信履歴','広告メール情報はありません',1, @URL);
	ModPerl::Util::exit();
}

#****************************
# ページ番号から表示する回数を取得
#****************************
$startpos=($page-1)*$listnum;


#****************************
#広告メールの送信DBをオープン
#****************************
$dba = MyClass::UsrWebDB::connect();
$dba->do('set names sjis');

#****************************
# 共通部分の出力
#****************************
my @caption = ('No.', 'クライアント名', '配信条件', 'タイトル', '本文', '送信日時', '送信終了日時', '状態', '送信失敗件数', '送信件数',);
print $form->header(-charset=>'shift_jis');
print $form->start_html (
					-encoding=>'Shift_JIS',
					-head=>$form->meta({-http_equiv=>'Content-Type', -content=>'text/html', -charset=>'Shift_JIS'}),
					-lang=>"ja",-title=>"送信履歴",
					-style=>{-src=>'/css/style.css',-code=>''},
	);
#print qq(<script src="/js/cms_header.js" type="text/JavaScript"></script>);
#print $form->a({-href=>"/mod-perl/downloadadmail.mpl",-target=>"_blank"},"ダウンロード") . $form->br ();
print $form->start_multipart_form(-action=>"/mod-perl/downloadadmail.mpl",-target=>"_blank");
print $form->image_button(-src=>"/images/download04.gif");
print $form->end_multipart_form();

print "<TABLE BORDER=\"0\" cellspacing=\"1\" bgcolor=\"#666666\" width=\"100%\">\n";
print $form->Tr($form->td({-bgcolor=>"#eeeaff", -align=>"center"},\@caption));

for($offset=0, $cnt=$startpos; $cnt<$max && $offset<$listnum; $cnt++, $offset++){
	print "<TR bgcolor=\"#ffffff\">\n";
	$admailno= $list->[$cnt][0];
	print "<TD>" . $admailno . "</TD>\n";
	$setcont=&ReplaceHTML($list->[$cnt][4]);
	print "<TD>" . $setcont . "</TD>\n";
	$setcont=&ReplaceHTML($list->[$cnt][7]);
	print "<TD>" . $setcont . "</TD>\n";
	$setcont=&ReplaceHTML($list->[$cnt][5]);
	print "<TD>" . $setcont . "</TD>\n";
	$setcont=&ReplaceHTML($list->[$cnt][6]);
	print "<TD>" . $setcont. "</TD>\n";

	if(defined($list->[$cnt][1])){
		$limit = $list->[$cnt][1];
		$limit =~ s/\-/\//gi;
	}
	else{
		$limit = '　';
	}
	print "<TD>" . $limit . "</TD>\n";
	if(defined($list->[$cnt][2])){
		$limit = $list->[$cnt][2];
		$limit =~ s/\-/\//gi;
	}
	else{
		$limit = '　';
	}
	print "<TD>" . $limit . "</TD>\n";

### メールスケジューリング
	if($list->[$cnt][3] == 4){
		print "<TD>" . '送信予約中止' . "</TD>\n";
	}
	elsif($list->[$cnt][3] == 3){
		print "<TD>" . '送信予約' . "\n";

		# 予約中止キー表示
		print "<FORM ACTION=\"/mod-perl/chkdel_admail.cgi\" method=post>\n";
		print "<INPUT TYPE=HIDDEN name=id value=" . $admailno . ">\n";
		print "<INPUT TYPE=SUBMIT value=\"" . '送信中止' . "\">\n";
		print "</FORM>\n";
		print "</TD>\n";
	}
	elsif($list->[$cnt][3] == 2){
		print "<TD>" . '送信待ち' . "</TD>\n";
	}
	elsif($list->[$cnt][3] == 1){
		print "<TD>" . '送信中' . "</TD>\n";
	}
	elsif($list->[$cnt][3] == -1){
		print "<TD>" . '送信失敗' . "</TD>\n";
	}
	elsif($list->[$cnt][3] == 9){
		print "<TD>" . '送信失敗' . "</TD>\n";
	}
	else{
		print "<TD>" . '　' . "</TD>\n";
	}

	if( $list->[$cnt][3]==0 ) {
		$table="tAdmailmanage" . $admailno;
		$sendngcnt=0;
		$sendcnt=0;

		#送信失敗件数をカウントする
		$stha=$dba->prepare("SELECT COUNT(*) FROM $table WHERE admailno='$admailno' AND send_status!=1;");
		$stha->execute;
		if($stha->rows!=0){
			$reca=$stha->fetchrow_arrayref;
			if($reca->[0]>0){
				$sendngcnt=$reca->[0];
			}
		}
		$stha->finish;
		#送信件数をカウントする
		$stha=$dba->prepare("SELECT COUNT(*) FROM $table WHERE admailno='$admailno';");

		$stha->execute;
		if($stha->rows!=0){
			$reca=$stha->fetchrow_arrayref;
			if($reca->[0]>0){
				$sendcnt=$reca->[0];
			}
		}
		$stha->finish ();
	}
	else {
		$sendngcnt = '　';
		$sendcnt = '　';
	}

	print "<TD>" . $sendngcnt . "</TD>\n";
	print "<TD>" . $sendcnt . "</TD>\n";
	print "</TR>\n";
}

$dba->disconnect ();
undef($dba);

print "</TABLE><P>\n";

print "<TABLE><TR>\n";

if($page > 1){
	# 前ページへを表示
	print qq(<TD><FORM ACTION="$ENV{SCRIPT_NAME}" method="post">);
	print "<INPUT TYPE=HIDDEN name=page value=" . ($page-1) . ">\n";
	print "<INPUT TYPE=SUBMIT value=\"" . '前ページへ' . "\">\n";
	print "</FORM></TD>\n";
}
if($page<$maxpage){
	# 次ページへを表示
	print qq(<TD><FORM ACTION="$ENV{SCRIPT_NAME}" method="post">)
		. qq(<INPUT TYPE=HIDDEN name="page" value=) . ($page+1) . '>'
		. qq(<INPUT TYPE=SUBMIT value="次ページへ">)
		. qq(</FORM></TD>)
		;
}
print "</TR></TABLE>\n";
print "<a href=\"javascript:window.close()\">" . '閉じる' . "</a>\n";
print "</BODY>\n";
print "</HTML>\n";

$sth->finish ();
$db->disconnect ();
undef($db);

ModPerl::Util::exit();
