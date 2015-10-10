#!/usr/bin/perl -w
# 初期設定 -----------------------------------------------#

#use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
#use lib qw(/home/httpd/WebDB);
#use lib qw(../../common);
use lib qw(/home/vhosts/JKZ/extlib/common);
use lib qw(/home/vhosts/JKZ);
use MyClass::UsrWebDB;
use Goku::SiteSettings;
use Goku::Area;
use Goku::Output qw(ShowMsg DumpAndExit);
use Goku::StrConv qw(ConvSJIS ReplaceFieldValue
					 ReplaceMailSubject 
					 ReplaceAdMailContents);

my ($db, $sth, $row, $rec);

my $send;
my $sql;

my $cgi = CGI->new();
my %cookie = $cgi->cookie(-name => 'form_cookie');
my $admailno = $cgi->param('admailno');

my @URL=("/app.mpl", '戻る');

#本文中の広告IDを探す
sub GetAddIdInArray{
	my ($body) = @_;
	my @ret = ();
	while ($body =~ /$KEY_ADID/i){
		push @ret, $1;
		$body = $'; #'
	}
	return @ret;
}

#名前のとうり
sub uniq {
   my %seen;
   grep !$seen{$_}++, @_
}

#############################
# データベース接続
#############################
$db= MyClass::UsrWebDB::connect();
$db->do('set names sjis');
#############################
# 会員情報の取得
#############################
#$sth=$db->prepare("
# select id_no from member left join error_mail on
# member.mailaddr = error_mail.error_mailaddr
# $cookie{'sql_where'};");
$sth=$db->prepare("select owid from 1MP.tMemberM  $cookie{'sql_where'};");
$row=$sth->execute;

if(!defined($row) || $row==0){
	ShowInfo('メール送信可能な会員を取得できません');
	$sth->finish;
	$db->disconnect;
	undef($db);
	exit;
}
$sth->finish;

my ($saveclient, $savesubd, $savecontd, $savesubj, $savecontj, $savesube, $saveconte, $savesubo, $saveconto, $savecond, $savewhr);

$saveclient = ReplaceFieldValue($cookie{'client'});
$savesubd   = ReplaceFieldValue($cookie{'subjectd'});
$savecontd  = ReplaceFieldValue($cookie{'contentsd'});
$savesubj   = ReplaceFieldValue($cookie{'subjectj'});
$savecontj  = ReplaceFieldValue($cookie{'contentsj'});
$savesube   = ReplaceFieldValue($cookie{'subjecte'});
$saveconte  = ReplaceFieldValue($cookie{'contentse'});
$savesubo   = ReplaceFieldValue($cookie{'subjecto'});
$saveconto  = ReplaceFieldValue($cookie{'contentso'});
$savecond   = ReplaceFieldValue($cookie{'msg_where'});
$savewhr    = ReplaceFieldValue($cookie{'sql_where'});

$sql = 'REPLACE INTO 1MP.tAdmail
 (admailno, fromaddress, senddate, client, sendd, sendj, sende, sendo, subjectd, subjectj, subjecte, subjecto, 
 contentsd, contentsj, contentse, contentso, `condition`, sqlcond ) 
 VALUES (?,?,NOW(),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'; 
# VALUES ($admailno, $cookie{'from'}, NOW(), $saveclient, $cookie{'sendmemd'}, $cookie{'sendmemj'}, $cookie{'sendmeme'}, $cookie{'sendmemo'}, $savesubd, $savesubj, $savesube, $savesubo, $savecond, $savewhr);";

#$sql = "
# insert into admail (admailno, fromaddress, senddate, client,
# sendd, sendj, sende, sendo,
# subjectd, subjectj, subjecte, subjecto,
# contentsd, contentsj, contentse, contentso,
# condition, sqlcond )
# values ($admailno, '$cookie{'from'}', now(), '$saveclient',
# $cookie{'sendmemd'}, $cookie{'sendmemj'}, $cookie{'sendmeme'},
# $cookie{'sendmemo'},
# '$savesubd', '$savesubj', '$savesube', '$savesubo',
# '$savecontd', '$savecontj', '$saveconte', '$saveconto',
# '$savecond', '$savewhr');";

#############################
# 情報の更新
#############################
my @CARR_DEFINE = (
	{'disc' => 'その他', 'id' => 0, 'sub' => 'subjecto', 'body' => 'contentso',
		'cnt' => 'sendmemo' },
	{'disc' => 'DoCoMo', 'id' => 1, 'sub' => 'subjectd', 'body' => 'contentsd',
		'cnt' => 'sendmemd' },
	{'disc' => 'Vodafone', 'id' => 2, 'sub' => 'subjectj', 'body' => 'contentsj',
		'cnt' => 'sendmemj' },
	{'disc' => 'EZweb', 'id' => 3, 'sub' => 'subjecte', 'body' => 'contentse',
		'cnt' => 'sendmeme' });

$send=0;
#送信データーを入れるテーブル名
my $admanage_table = "";
eval{
	$db->do("set autocommit=0") || die "トランザクション開始失敗\n";
	$db->do("begin") || die "トランザクション開始失敗\n";
	$db->do($sql, undef,
	 $admailno, $cookie{'from'}, $saveclient, $cookie{'sendmemd'}, $cookie{'sendmemj'}, $cookie{'sendmeme'}, $cookie{'sendmemo'}, $savesubd, $savesubj, $savesube, $savesubo, $savecontd, $savecontj, $saveconte, $saveconto,$savecond, $savewhr
	 )
	  || die "広告メール追加失敗\n";

	#キャリアの数だけループ
	my @all_adid = ();
	foreach  my $c_ref (@CARR_DEFINE){

		next if(0 == $cookie{"$c_ref->{'cnt'}"});
		
		my @tmp_adid = ();
		@tmp_adid = GetAddIdInArray($cookie{"$c_ref->{'body'}"});
		#配列をマージして、全広告コードを捕らえておく
		@all_adid = (@all_adid, @tmp_adid);
		foreach my $ad (@tmp_adid){
			#1メール当たりの広告URLの数だけ、INSERTする
			$db->do("
 insert into 1MP.tAdsetmail(admailno, carrier, adid)
 values($admailno, $c_ref->{'id'}, $ad);") || die "広告IDメール掲載管理更新失敗\n";
		}#end of adid foreach
		#置き換え文字列の適用
		my $send_body = ReplaceAdMailContents($admailno,
											 $cookie{"$c_ref->{'body'}"},
											 $c_ref->{'id'});
		my $send_subject = ReplaceMailSubject($cookie{"$c_ref->{'sub'}"},
											 $c_ref->{'id'});
		my $send_carr = 2 ** $c_ref->{'id'};
		
		#本文、件名インサート
		$db->do("
 insert into 1MP.tAdcontents(admailno, carrier, subject, contents)
 values($admailno, $send_carr, '$send_subject',
 '$send_body')") || die '広告メール送信設定登録失敗' . "\n";
	}#eod of carrior foreach
	
	#############################
	# 広告メール送信設定にデータを設定
	#############################
	#サーバーの数だけインサート
	foreach (@MAIL_SERVERS){
		$db->do("
 insert into 1MP.tAdmailsetting(admailno, fromaddress, server, header)
 values($admailno, '$cookie{'from'}', '$_', '')")
		  || die '広告メール送信設定登録失敗' . "\n";
	}

	# 広告メール管理テーブルの作成
	$admanage_table ="1MP.tAdmailmanage" . $admailno;
	$db->do("create table $admanage_table like 1MP.base_admailmanage");
	$send = 1;
	#広告コードの重複を解く
	@all_adid = uniq @all_adid;
	#実データーの挿入
	foreach (@all_adid){
		#若干問題あるが、この処理で良い
		#問題は、キャリアによって、広告コードがあったりなかったりする場合
		#ないキャリアに対しても、データーを登録してしまうが、そもそも
		#ユーザーに届くメールの中身にリンクがないので、問題ない
#		$db->do("
# insert into $admanage_table (select $admailno, $_, id_no, 1, null, null
# from HP_general.tMemberM left join error_mail on HP_general.tMemberM.mailaddr = HP_management.error_mail.error_mailaddr
# $cookie{'sql_where'});");
		$db->do("
 insert into $admanage_table (select $admailno, $_, owid, 1, null, null
 from 1MP.tMemberM left join 1MP.error_mail on 1MP.tMemberM.mobilemailaddress = 1MP.error_mail.error_mailaddr
 $cookie{'sql_where'});");
	}
	
};

if ($@) {
    # もし、DBIがRaiseErrorでdieしたら、$@ には$DBI::errstrが入っています。
	# 登録失敗
    $db->do("rollback");
	$db->do("set autocommit=1");
	if($admanage_table ne ''){
		$db->do("drop table $admanage_table;");
	}
	$db->disconnect;
	undef($db);
	ShowInfo('広告メールの登録・送信に失敗しました' . $@);
	exit;
}

$db->do("commit");
$db->do("set autocommit=1");
$db->disconnect;
undef($db);

# 送信プロセスの実行
#system("perl /usr/local/src/kensyo-i/common/watchmaillist.pl $Mail_kind_adml $admailno&");
#system("perl /home/httpd/htdocs/common/sendmaillist.pl $Mail_kind_adml $admailno&");
#system("perl /home/ecshop/www/common/sendmaillist.pl 1 $admailno&");
#system("perl /home/vhosts/JKZ/extlib/common/sendmaillist.pl 1 $admailno&");
system("perl /home/vhosts/JKZ/modules/mail/sendmaillist.pl 1 $admailno&");
ShowMsg('広告メール登録','広告メールの登録・送信に成功しました',1,@URL);

sub ShowInfo{
	#単にエラーをHTML出力し、脱出するだけ
    print "Content-type: text/html; charset=Shift_JIS\n\n";
    print "<HTML><HEAD>\n";
    print "<TITLE>" . '広告メール送信確認' . "</TITLE>\n";
    print "</HEAD><BODY>\n";
    print $_[0] . "<BR>\n";
	print "</BODY></HTML>";
}1;
exit;
