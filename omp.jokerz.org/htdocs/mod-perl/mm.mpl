#**************************
# @desc		���[���A�h���X�o�^�����c�m�菈��
# @package	mm.pl (modifymailaddress.mpl������)
# @access	public
# @author	Iwahase Ryo
# @create	2009/09/17
# @update	
# @version	1.00
# @info		�֘A�e�[�u��
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
	$message = "�Z�b�V������񂪂���܂���B";
	goto PRINT_HTML;
}

my $session_id = $q->param('s');
my ($sguid, $screated_time) = MyClass::WebUtil::decodeMD5($session_id);

my $dbh = MyClass::UsrWebDB::connect();
$dbh->do('SET NAMES SJIS');

my $sql;

#*******************************
# step 1) �Z�b�V�����̗L�������m�F
#*******************************
$sql = sprintf("SELECT IF(TIME_FORMAT(TIMEDIFF(NOW(), %s), '%H') < 24, 1, -1)", $screated_time);
if( 0 > $dbh->selectrow_array($sql) ) {
	$message = "�Z�b�V�����̗L�������؂�ł��B";
	goto PRINT_HTML;
}

$sql = "SELECT guid, new_mobilemailaddress, IFNULL(former_mobilemailaddress, -1) FROM 1MP.tMailAddressLogF WHERE session_id=? AND status_flag=1";

my ($guid, $new_mobilemailaddress, $former_mobilemailaddress) = $dbh->selectrow_array($sql, undef, $session_id);

#*******************************
# step 2) ���[���A�h���X�ύX�m�菈��
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
		## ���[���o�^���O�e�[�u�����R�[�h�̃t���O�X�V
		$dbh->do("UPDATE 1MP.tMailAddressLogF SET status_flag=? WHERE session_id=? AND status_flag=1", undef, 2, $session_id);

		## ����}�X�^�e�[�u���̉�����R�[�h�̍X�V ���A�h�V�K�o�^���ƕύX����SQL������������
		$dbh->do($sql, undef, @placeholder);

		$dbh->commit();
	};
	## ���s�̃��[���o�b�N
	if ($@) {
		$dbh->rollback();
		$message = "�ύX�Ɏ��s���܂����B";
	}
	else {
		$message = "�ύX�������܂����B";
	}

	MyClass::UsrWebDB::TransactFin($dbh,$attr_ref,$@);
} else {
	$message = "�ύX�Ώۃf�[�^���݂��܂���B";

}

$dbh->disconnect ();


PRINT_HTML:

print "Content-type: text/html\n\n";
print qq(<html><head><title>Ұٱ��ڽ�o�^�E�ύX</title><meta http-equiv="Content-type" content="text/html; charset=Shift_JIS"></head><body>)
	. $message
	. '<p style="margin:0;">��&nbsp;<a href="http://m.1mp.jp" accesskey="0"><font color="#fe33ff">Pointy۸޲�</font></a></p>'
	. '</body></html>'
	;

ModPerl::Util::exit();

__END__