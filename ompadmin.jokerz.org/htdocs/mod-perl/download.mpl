#******************************************************
# @desc		�f�[�^�_�E�����[�h
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
# �t�@�C�������擾
#****************************
my($fileTemp) = POSIX::tmpnam();
open( FILE, ">" . $fileTemp);	


#�^�C�g���s�̐ݒ�@��
# mid, memberstatus_flag, mobilemailaddress, carrier, subno, guid, sex, adv_code, useragent, registration_date, withdraw_date, reregistration_date

$string = '���No.'				. ",";
#$string .= '����X�e�[�^�X'		. ",";
$string .= '���[���A�h���X'		. ",";
$string .= '�L�����A(2->DoCoMo 4->SB 8->AU)'			. ",";
$string .= '�T�u�X�N���C�o�[ID' . ",";
$string .= 'uid/guid'			. ",";
$string .= '����(1->���I�� 2->�j 4->��)'				. ",";
$string .= '�L���R�[�h'			. ",";
$string .= 'UA'					. ",";
$string .= '�o�^��'				. ",";
$string .= '�މ��'				. ",";
$string .= "\n";
#$string .= '����'				. ",";
#$string .= '�ēo�^��'			. "\n";

=pod
# owid, mobilemailaddress, carrier, sex, month_of_birth, date_of_birth, prefecture
$string = '���No.' . ",";
$string .= '���[���A�h���X' . ",";
$string .= '�L�����A' . ",";
$string .= '����' . ",";
$string .= '�a����' . ",";
$string .= '�a����' . ",";
$string .= '�Z�܂��n��' . "\n";
=cut

$p_err = print FILE $string;


if($p_err == 0 ) {
	&ShowMsg('������_�E�����[�h','�_�E�����[�h�G���[�ł�',0,"");
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
# CSV�t�@�C��
#****************************
my $dlfile='/tmp/memberinfo.csv';
#my $dlfile='./memberinfo.csv';
#****************************
# �V�K��zip�A�[�J�C�u�̍쐬
#****************************
my $zip = Archive::Zip->new();
#****************************
# zip �t�@�C���������o�ɒǉ�
#****************************
my $member = $zip->addFile( $fileTemp, $dlfile );
warn Dumper($member);
#****************************
# ���k���x���̐ݒ�
#****************************
$member->desiredCompressionLevel( COMPRESSION_LEVEL_BEST_COMPRESSION  );

#****************************
# zip��������
#    (0) ���͂Ȃɂ��Ȃ��D
#    (1) �ǂݍ��݃X�g���[�� (�܂��̓Z���g�����f�B���N�g��) ������ɏI�������D
#    (2) ���炩�̈�ʓI�Ȏ�ނ̃G���[���N�������D
#    (3) �ǂݍ���ł���Zip�t�@�C�����Ńt�H�[�}�b�g�̃G���[���N�������D
#    (4) IO �G���[���N�������D
#****************************
if( $zip->writeToFileNamed( $dlfile ) != 0 ) {
	&ShowMsg('�_�E�����[�h', '�t�@�C���̍쐬�Ɏ��s���܂���', 0, '');
	exists( $ENV{MODPERL} ) ? ModPerl::Util::exit() : exit();
}

#****************************
# �_�E�����[�h�t�@�C���̓ǂݍ���
#****************************
open( FILE, $dlfile );
binmode FILE;

read( FILE, $data, -s FILE );

#****************************
# ���[�U�Ƀv�b�V��
#****************************
$length = -s FILE;
print 'Content-Length: '.$length."\n";
print 'Content-disposition: attachment; filename=memberinfo.zip'."\n";#���[�U�Ɍ�����t�@�C�����@�֘A�Ȃ�
print 'Content-Type: application/octet-stream'."\n\n";
#print 'Content-Type: application/zip'."\n\n";

### print 'Content-disposition: attachment; filename="meminfo.csv"'."\n";	#���[�U�Ɍ�����t�@�C�����@�֘A�Ȃ�
### print 'Content-Type: application/octet-stream'."\n\n";

$p_err = print $data;

if($p_err == 0 ) {
	&ShowMsg('������_�E�����[�h', '�_�E�����[�h�G���[�ł�', 0, "");
}

close( FILE );

##�t�@�C�����폜
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
