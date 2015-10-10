#!/usr/bin/perl -w
# 初期設定 -----------------------------------------------#

#use ConvEmo;

=pod
my $q = new CGI;

my $adid = $q->param('a');
my $today = WebUtil::GetTime ("1");
my $month = WebUtil::GetTime ("5");
#my $linkcnttable = $HASHTB->{LINKCNT} . $month;
my $linkcnttable = 'mailcnt_2005';

my $dbh = JKZ::UsrWebDB::connect ();
$dbh->do ('SET NAMES SJIS');
my ($sqllink,$sqlexe,$urlrow,$sth);

$sqllink = "SELECT urld FROM HP_management.tAdinfo WHERE adid=?";
$urlrow = $dbh->selectrow_array ($sqllink, undef, $adid);
if (defined ($urlrow)) {
	$sqlexe = qq(UPDATE $linkcnttable SET count=count+1 WHERE adid='$adid' AND date='$today');
	$sth = $dbh->prepare($sqlexe);
	if ($sth->execute < 1) {
		$sqlexe = qq(INSERT INTO $linkcnttable (adid, date, count ) VALUES ('$adid', '$today', 1));
		$sth = $dbh->prepare($sqlexe);
		$sth->execute ();
	}
	$dbh->disconnect ();
	print "Location: $urlrow\n\n";
}

ModPerl::Util::exit ();


=cut
#use strict;
#use CGI;
#use CGI::Carp qw(fatalsToBrowser);

use lib qw(/home/vhosts/JKZ);
use strict;

use CGI::Carp qw(fatalsToBrowser);
use HTTP::MobileAgent;
#use lib qw(../../common);
#use lib qw(/home/httpd/WebDB);
#use UsrWebDB;
use Data::Dumper;
use Goku::SiteSettings;
use Goku::AccessCounter qw(RegCountAd);
use MyClass::UsrWebDB;

#////////////////////////////
# ﾊﾟﾗﾒｰﾀの値を取得
#////////////////////////////
my $ua = new HTTP::MobileAgent;
my $q = new CGI;
my $id = $q->param('i');
my $password = $q->param('p');
my $admailno = $q->param('n');
my $adid = $q->param('a');

my ($db, $sth, $row, $rec, $sql);
sub ShowInfo{
	#単にエラーをHTML出力し、脱出するだけ
    print "Content-type: text/html; charset=Shift_JIS\n\n";
    print "<HTML><HEAD>\n";
    print "<TITLE>" . 'メール受信確認' . "</TITLE>\n";
    print "</HEAD><BODY>\n";
    print $_[0] . "<BR>\n";
	print "</BODY></HTML>";
}1;

#////////////////////////////
# DBをオープン
#////////////////////////////
$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');

# 会員IDパスワードのチェック、及びキャリアの取得
# status_flag 2は会員 4は退会
#$sql = "
# SELECT owid, carrier FROM 1MP.tMemberM WHERE owid = '$id' AND
# password = '$password' AND status_flag = 2;";

$sql = "
 SELECT owid, carrier FROM 1MP.tMemberM WHERE owid = '$id' AND
 status_flag = 2;";

$sth = $db->prepare ($sql);
$row = $sth->execute ();
my $carrier = 2 ** 0; # デフォルトのキャリア = その他
if(defined($row) && $sth->rows>0){
	$rec=$sth->fetchrow_arrayref;
	if($rec->[0]==0){
		ShowInfo('まずは会員ページにアクセスしてくださいね');
		$sth->finish ();
		$db->disconnect ();
		undef($db);
		exit;
	}
	$carrier=$rec->[1];
}
$sth->finish ();

## Databaseを変更
#$db->do ('USE 1MP');

# 広告ﾒｰﾙ番号と広告IDのﾁｪｯｸ
$sql = "
 SELECT admailno FROM tAdsetmail WHERE
 admailno = $admailno AND carrier = $carrier AND adid = $adid;";

$sth = $db->prepare ($sql);
$row = $sth->execute ();

if(!defined($row) || $row == 0){
	#広告ﾒｰﾙ番号と広告IDが一致しないので終了
	ShowInfo('広告情報がありません');
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	exit;
}
$sth->finish;


# 送信済みの会員であるかをﾁｪｯｸする
my $mngtable="tAdmailmanage" . $admailno;
$sql = "
 SELECT admailno FROM $mngtable WHERE admailno=$admailno AND id_no='$id'
 AND  send_status = 1;";

$sth = $db->prepare ($sql);
$row = $sth->execute ();
if(!defined($row) || $row != 1){
	ShowInfo('広告情報がありません');
	$sth->finish;
	$db->disconnect;
	undef($db);
	exit;
}
$sth->finish ();


# 広告IDをﾁｪｯｸ
my ($url_col, $url) = ('','');

if($ua->is_docomo){
	$url_col = 'urld';
}elsif($ua->is_vodafone){
	$url_col = 'urlj';
}elsif($ua->is_ezweb){
	$url_col = 'urle';
}else{
	$url_col = 'urlo';
}

$sql = "
 SELECT adid, adpoint,
 IF(adlimit IS NULL,0, IF(adlimit='0000-00-00 00:00:00',0,(NOW() > adlimit))),
 delad, $url_col
 FROM tAdinfo WHERE adid=$adid;";

$sth = $db->prepare ($sql);
$row=$sth->execute ();

if(!defined($row) || $row != 1){
	#広告IDが一致しないので終了
	ShowInfo('広告情報がありません');
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	exit;
}
# 広告情報を取得
$rec=$sth->fetchrow_arrayref;
my $adpoint = $rec->[1];
my $delad = $rec->[3];
my $adurl = $rec->[4];

#////////////////////////////
# 有効期限をﾁｪｯｸ
#////////////////////////////
if($rec->[2] ne ""){
	#有効期限切れ
	if($rec->[2]==1){
		$sth->finish;
		$db->disconnect;
		undef($db);
		#アクセスカウンタをインクリメントする
		RegCountAd($id, $admailno, $adid, $SUM_KIND{'notermaccess'}, 1);
		#有効期限が切れているので、URLへ飛ばす
		print "Location: $adurl\n\n";
		exit;
	}
}
$sth->finish ();

#////////////////////////////
# 削除済みをﾁｪｯｸ
#////////////////////////////
if($delad==1){
	#広告が削除されているので終了
	ShowInfo('広告情報がありません');
	$db->disconnect ();
	undef($db);
	exit ();
}

#////////////////////////////
# 情報の更新
#////////////////////////////
eval{
	$db->do("set autocommit=0") || die "トランザクション開始失敗\n";
	$db->do("begin") || die "トランザクション開始失敗\n";
	if($adpoint>0){
		#一度ポイントをプレゼントしているかをチェック
		my $admanage_table = 'tAdmailmanage'.$admailno;
		$sql = "
 SELECT IFNULL(pointdate,'yet') FROM $admanage_table WHERE
 admailno=$admailno AND adid=$adid AND id_no='$id';";
		$sth=$db->prepare($sql) || die "広告管理テーブル取得失敗\n";
		$row=$sth->execute;
		if(!defined($row) || $sth->rows!=1){
			die "ポイント管理更新失敗\n";
		}
		$rec=$sth->fetchrow_arrayref;
		if($rec->[0] eq 'yet'){
			#ポイントをプレゼントする
			$sql = "
 UPDATE $admanage_table SET accessdate = NOW(), pointdate = NOW() WHERE
 admailno = $admailno AND adid =  $adid AND id_no = '$id';";
			$db->do ($sql) || die "広告メール管理テーブル反映失敗\n";
			$sql = "
 UPDATE HP_general.tMemberM SET point = point + $adpoint WHERE owid = '$id';";
			$db->do($sql) || die "広告メールポイント反映失敗\n";
			#アクセスカウンタをインクリメントする
			RegCountAd($id, $admailno, $adid, $SUM_KIND{'paccess'}, 1);
		}else{
			RegCountAd($id, $admailno, $adid, $SUM_KIND{'nopaccess'}, 1);
		}
		$sth->finish ();
	}
};

if ($@) {
    # もし、DBIがRaiseErrorでdieしたら、$@ には$DBI::errstrが入っています。
	# 登録失敗
    $db->do ("rollback");
    $db->do ("set autocommit=1");
	$db->disconnect ();
	undef($db);
	ShowInfo('広告のアクセスに失敗しました');
	ModPerl::Util::exit ();
} else {
    $db->do ("commit");
    $db->do ("set autocommit=1");
	$db->disconnect ();
	undef($db);

	print "Location: $adurl\n\n";
}
ModPerl::Util::exit ();
=pod
=cut