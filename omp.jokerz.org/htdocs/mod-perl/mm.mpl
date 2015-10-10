#**************************
# @desc		メールアドレス登録処理…確定処理
# @package	mm.pl (modifymailaddress.mplを改名)
# @access	public
# @author	Iwahase Ryo
# @create	2009/09/17
# @update	
# @version	1.00
# @info		関連テーブル
#			tMailAddressLogF 
#			tMemberM 
#
#
#
#
#
#**************************

use strict;
use lib qw(/home/vhosts/JKZ);
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use MyClass::WebUtil;
use MyClass::UsrWebDB;

my $q = CGI->new();
my $message;

if (!$q->param('s')) {
	$message = "セッション情報がありません。";
	goto PRINT_HTML;
}

my $session_id = $q->param('s');
my ($sguid, $screated_time) = MyClass::WebUtil::decodeMD5($session_id);

my $dbh = MyClass::UsrWebDB::connect();
$dbh->do('SET NAMES SJIS');

my $sql;

#*******************************
# step 1) セッションの有効期限確認
#*******************************
$sql = sprintf("SELECT IF(TIME_FORMAT(TIMEDIFF(NOW(), %s), '%H') < 24, 1, -1)", $screated_time);
if( 0 > $dbh->selectrow_array($sql) ) {
	$message = "セッションの有効期限切れです。";
	goto PRINT_HTML;
}

$sql = "SELECT guid, new_mobilemailaddress, IFNULL(former_mobilemailaddress, -1) FROM 1MP.tMailAddressLogF WHERE session_id=? AND status_flag=1";

my ($guid, $new_mobilemailaddress, $former_mobilemailaddress) = $dbh->selectrow_array($sql, undef, $session_id);

#*******************************
# step 2) メールアドレス変更確定処理
#*******************************
if ($guid) {
	my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);

	$sql = (0 > $former_mobilemailaddress)
			? 
			"UPDATE 1MP.tMemberM SET mobilemailaddress=?, mailstatus_flag=? WHERE guid=?;"
			: 
			"UPDATE 1MP.tMemberM SET mobilemailaddress=?, mailstatus_flag=? WHERE guid=? AND  mobilemailaddress=?;"
			;

	my @placeholder;
	push(@placeholder, $new_mobilemailaddress, 2, $guid);
	push(@placeholder, $former_mobilemailaddress) unless 0 > $former_mobilemailaddress;

	eval {
		## メール登録ログテーブルレコードのフラグ更新
		$dbh->do("UPDATE 1MP.tMailAddressLogF SET status_flag=? WHERE session_id=? AND status_flag=1", undef, 2, $session_id);

		## 会員マスタテーブルの会員レコードの更新 メアド新規登録時と変更時はSQL条件がちがう
		$dbh->do($sql, undef, @placeholder);

		$dbh->commit();
	};
	## 失敗のロールバック
	if ($@) {
		$dbh->rollback();
		$message = "変更に失敗しました。";
	}
	else {
		$message = "変更完了しました。";
	}

	MyClass::UsrWebDB::TransactFin($dbh,$attr_ref,$@);
} else {
	$message = "変更対象データ存在しません。";

}

$dbh->disconnect ();


PRINT_HTML:

print "Content-type: text/html\n\n";
print qq(<html><head><title>ﾒｰﾙｱﾄﾞﾚｽ登録・変更</title><meta http-equiv="Content-type" content="text/html; charset=Shift_JIS"></head><body>)
	. $message
	. '<p style="margin:0;">&nbsp;<a href="http://m.1mp.jp" accesskey="0"><font color="#fe33ff">Pointyﾛｸﾞｲﾝ</font></a></p>'
	. '</body></html>'
	;

ModPerl::Util::exit();

__END__