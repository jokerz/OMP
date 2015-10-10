#******************************************************
# @desc		データダウンロード
# @package	download.mpl
# @access	public
# @author	Iwahase Ryo
# @create	2008/11/28
# @version	1.00
#******************************************************

use strict;
use lib qw(/home/vhosts/JKZ/extlib/common);
use MyClass::UsrWebDB;
use POSIX;
use Archive::Zip qw ( :ERROR_CODES :CONSTANTS );
use Data::Dumper;

use MyClass::WebUtil;


my $q = CGI->new();

my $data;
my $length;
my $string=" " x 10000;
my $p_err=0;

#****************************
# ファイル名を取得
#****************************
my($fileTemp) = POSIX::tmpnam();
open( FILE, ">" . $fileTemp);	


#タイトル行の設定　仮
# mid, memberstatus_flag, mobilemailaddress, carrier, subno, guid, sex, adv_code, useragent, registration_date, withdraw_date, reregistration_date

$string = '会員No.'				. ",";
#$string .= '会員ステータス'		. ",";
$string .= 'メールアドレス'		. ",";
$string .= 'キャリア(2->DoCoMo 4->SB 8->AU)'			. ",";
$string .= 'サブスクライバーID' . ",";
$string .= 'uid/guid'			. ",";
$string .= '性別(1->未選択 2->男 4->女)'				. ",";
$string .= '広告コード'			. ",";
$string .= 'UA'					. ",";
$string .= '登録日'				. ",";
$string .= '退会日'				. ",";
$string .= "\n";
#$string .= '解約日'				. ",";
#$string .= '再登録日'			. "\n";

=pod
# owid, mobilemailaddress, carrier, sex, month_of_birth, date_of_birth, prefecture
$string = '会員No.' . ",";
$string .= 'メールアドレス' . ",";
$string .= 'キャリア' . ",";
$string .= '性別' . ",";
$string .= '誕生月' . ",";
$string .= '誕生日' . ",";
$string .= '住まい地区' . "\n";
=cut

$p_err = print FILE $string;


if($p_err == 0 ) {
	&ShowMsg('会員情報ダウンロード','ダウンロードエラーです',0,"");
	close( FILE );
	unlink($fileTemp);
	exists( $ENV{MODPERL} ) ? ModPerl::Util::exit() : exit();
}

my $cookie = $q->cookie('CMS1MP_USERsearchcondition');

## Modified 2009/10/29 BEGIN
#my ($condition, $holder) = split (/,/, $cookie);
#my @placeholder = split(/ /, $holder);

my ($condition_sqlmessage, $orderby, $holder) = split (/,/, $cookie);
my @placeholder = split(/ /, $holder);
my ($condition, $sqlmessage) = split(/::/, $condition_sqlmessage);
## Modified 2009/10/29 END

# Modified 2010/02/26
#my $sql = "SELECT owid, memberstatus_flag, mobilemailaddress, carrier, subno, guid, sex, adv_code, useragent, registration_date, withdraw_date, reregistration_date"
# 		. " FROM 1MP.tMemberM";
my $sql = "SELECT owid, mobilemailaddress, carrier, subno, guid, sex, adv_code, useragent, registration_date, withdraw_date"
 		. " FROM 1MP.tMemberM";
$sql .= sprintf(" WHERE %s", $condition) if $condition ne "";



#my $sql = "SELECT mid, mobilemailaddress, carrier, sex, month_of_birth, date_of_birth, prefecture"
# 		. " FROM MYSDK.tMemberM WHERE "
# 		. $condition;

my $dbh = MyClass::UsrWebDB::connect();

$dbh->trace(2, '/home/vhosts/JKZ/tmp/DBITrace.log');

my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, @placeholder);

#if ($#{$aryref} > 0) {
if ($aryref) {
	foreach (@{$aryref}) {
		$string = $_->{owid} . ",";
		#$string .= "\"" . $_->{mobilemailaddress} . "\",";
#		$string .= $_->{memberstatus_flag} . ",";
		$string .= "\"" . $_->{mobilemailaddress} . "\",";
		$string .= $_->{carrier} . ",";
		$string .= $_->{subno} . ",";
		$string .= $_->{guid} . ",";
		$string .= $_->{sex} . ",";
		$string .= $_->{adv_code} . ",";
		$string .= $_->{useragent} . ",";
		$string .= $_->{registration_date} . ",";
		$string .= $_->{withdraw_date} . ",";
#		$string .= $_->{reregistration_date};
		$string .= "\n";

		$p_err = print FILE $string;
	}
}
else {
	close( FILE );
	unlink($fileTemp);
}

$dbh->disconnect();

close( FILE );

#****************************
# CSVファイル
#****************************
my $dlfile='/tmp/memberinfo.csv';
#my $dlfile='./memberinfo.csv';
#****************************
# 新規のzipアーカイブの作成
#****************************
my $zip = Archive::Zip->new();
#****************************
# zip ファイルをメンバに追加
#****************************
my $member = $zip->addFile( $fileTemp, $dlfile );
warn Dumper($member);
#****************************
# 圧縮レベルの設定
#****************************
$member->desiredCompressionLevel( COMPRESSION_LEVEL_BEST_COMPRESSION  );

#****************************
# zip書き込み
#    (0) 問題はなにもない．
#    (1) 読み込みストリーム (またはセントラルディレクトリ) が正常に終了した．
#    (2) 何らかの一般的な種類のエラーが起こった．
#    (3) 読み込んでいるZipファイル内でフォーマットのエラーが起こった．
#    (4) IO エラーが起こった．
#****************************
if( $zip->writeToFileNamed( $dlfile ) != 0 ) {
	&ShowMsg('ダウンロード', 'ファイルの作成に失敗しました', 0, '');
	exists( $ENV{MODPERL} ) ? ModPerl::Util::exit() : exit();
}

#****************************
# ダウンロードファイルの読み込み
#****************************
open( FILE, $dlfile );
binmode FILE;

read( FILE, $data, -s FILE );

#****************************
# ユーザにプッシュ
#****************************
$length = -s FILE;
print 'Content-Length: '.$length."\n";
print 'Content-disposition: attachment; filename=memberinfo.zip'."\n";#ユーザに見せるファイル名　関連なし
print 'Content-Type: application/octet-stream'."\n\n";
#print 'Content-Type: application/zip'."\n\n";

### print 'Content-disposition: attachment; filename="meminfo.csv"'."\n";	#ユーザに見せるファイル名　関連なし
### print 'Content-Type: application/octet-stream'."\n\n";

$p_err = print $data;

if($p_err == 0 ) {
	&ShowMsg('会員情報ダウンロード', 'ダウンロードエラーです', 0, "");
}

close( FILE );

##ファイルを削除
unlink($fileTemp);
unlink($dlfile);

exists( $ENV{MODPERL} ) ? ModPerl::Util::exit() : exit();



sub ShowMsg{
	my $cnt=0;
    print "Content-type: text/html; charset=Shift_JIS\n\n";
    print "<HTML><HEAD>\n";
    print "<TITLE>" . $_[0] . "</TITLE>\n";
    print "</HEAD><BODY>\n";
    print $_[1] . "<BR>\n";
	print "<P>\n";
	
	if( $_[2] > 0){
	    for( $cnt = 3; $cnt < (($_[2] * 2)+3); $cnt += 2){
	    	print "<A HREF=\"" . $_[$cnt] . "\">" . $_[$cnt+1] . "</A><BR>\n";
	    }
	}

    print "</BODY></HTML>\n";
    return 1;
}
