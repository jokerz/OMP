#!/usr/bin/perl -w
# �����ݒ� -----------------------------------------------#

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
# ���Ұ��̒l���擾
#////////////////////////////
my $ua = new HTTP::MobileAgent;
my $q = new CGI;
my $id = $q->param('i');
my $password = $q->param('p');
my $admailno = $q->param('n');
my $adid = $q->param('a');

my ($db, $sth, $row, $rec, $sql);
sub ShowInfo{
	#�P�ɃG���[��HTML�o�͂��A�E�o���邾��
    print "Content-type: text/html; charset=Shift_JIS\n\n";
    print "<HTML><HEAD>\n";
    print "<TITLE>" . '���[����M�m�F' . "</TITLE>\n";
    print "</HEAD><BODY>\n";
    print $_[0] . "<BR>\n";
	print "</BODY></HTML>";
}1;

#////////////////////////////
# DB���I�[�v��
#////////////////////////////
$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');

# ���ID�p�X���[�h�̃`�F�b�N�A�y�уL�����A�̎擾
# status_flag 2�͉�� 4�͑މ�
#$sql = "
# SELECT owid, carrier FROM 1MP.tMemberM WHERE owid = '$id' AND
# password = '$password' AND status_flag = 2;";

$sql = "
 SELECT owid, carrier FROM 1MP.tMemberM WHERE owid = '$id' AND
 status_flag = 2;";

$sth = $db->prepare ($sql);
$row = $sth->execute ();
my $carrier = 2 ** 0; # �f�t�H���g�̃L�����A = ���̑�
if(defined($row) && $sth->rows>0){
	$rec=$sth->fetchrow_arrayref;
	if($rec->[0]==0){
		ShowInfo('�܂��͉���y�[�W�ɃA�N�Z�X���Ă���������');
		$sth->finish ();
		$db->disconnect ();
		undef($db);
		exit;
	}
	$carrier=$rec->[1];
}
$sth->finish ();

## Database��ύX
#$db->do ('USE 1MP');

# �L��Ұٔԍ��ƍL��ID������
$sql = "
 SELECT admailno FROM tAdsetmail WHERE
 admailno = $admailno AND carrier = $carrier AND adid = $adid;";

$sth = $db->prepare ($sql);
$row = $sth->execute ();

if(!defined($row) || $row == 0){
	#�L��Ұٔԍ��ƍL��ID����v���Ȃ��̂ŏI��
	ShowInfo('�L����񂪂���܂���');
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	exit;
}
$sth->finish;


# ���M�ς݂̉���ł��邩����������
my $mngtable="tAdmailmanage" . $admailno;
$sql = "
 SELECT admailno FROM $mngtable WHERE admailno=$admailno AND id_no='$id'
 AND  send_status = 1;";

$sth = $db->prepare ($sql);
$row = $sth->execute ();
if(!defined($row) || $row != 1){
	ShowInfo('�L����񂪂���܂���');
	$sth->finish;
	$db->disconnect;
	undef($db);
	exit;
}
$sth->finish ();


# �L��ID������
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
	#�L��ID����v���Ȃ��̂ŏI��
	ShowInfo('�L����񂪂���܂���');
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	exit;
}
# �L�������擾
$rec=$sth->fetchrow_arrayref;
my $adpoint = $rec->[1];
my $delad = $rec->[3];
my $adurl = $rec->[4];

#////////////////////////////
# �L������������
#////////////////////////////
if($rec->[2] ne ""){
	#�L�������؂�
	if($rec->[2]==1){
		$sth->finish;
		$db->disconnect;
		undef($db);
		#�A�N�Z�X�J�E���^���C���N�������g����
		RegCountAd($id, $admailno, $adid, $SUM_KIND{'notermaccess'}, 1);
		#�L���������؂�Ă���̂ŁAURL�֔�΂�
		print "Location: $adurl\n\n";
		exit;
	}
}
$sth->finish ();

#////////////////////////////
# �폜�ς݂�����
#////////////////////////////
if($delad==1){
	#�L�����폜����Ă���̂ŏI��
	ShowInfo('�L����񂪂���܂���');
	$db->disconnect ();
	undef($db);
	exit ();
}

#////////////////////////////
# ���̍X�V
#////////////////////////////
eval{
	$db->do("set autocommit=0") || die "�g�����U�N�V�����J�n���s\n";
	$db->do("begin") || die "�g�����U�N�V�����J�n���s\n";
	if($adpoint>0){
		#��x�|�C���g���v���[���g���Ă��邩���`�F�b�N
		my $admanage_table = 'tAdmailmanage'.$admailno;
		$sql = "
 SELECT IFNULL(pointdate,'yet') FROM $admanage_table WHERE
 admailno=$admailno AND adid=$adid AND id_no='$id';";
		$sth=$db->prepare($sql) || die "�L���Ǘ��e�[�u���擾���s\n";
		$row=$sth->execute;
		if(!defined($row) || $sth->rows!=1){
			die "�|�C���g�Ǘ��X�V���s\n";
		}
		$rec=$sth->fetchrow_arrayref;
		if($rec->[0] eq 'yet'){
			#�|�C���g���v���[���g����
			$sql = "
 UPDATE $admanage_table SET accessdate = NOW(), pointdate = NOW() WHERE
 admailno = $admailno AND adid =  $adid AND id_no = '$id';";
			$db->do ($sql) || die "�L�����[���Ǘ��e�[�u�����f���s\n";
			$sql = "
 UPDATE HP_general.tMemberM SET point = point + $adpoint WHERE owid = '$id';";
			$db->do($sql) || die "�L�����[���|�C���g���f���s\n";
			#�A�N�Z�X�J�E���^���C���N�������g����
			RegCountAd($id, $admailno, $adid, $SUM_KIND{'paccess'}, 1);
		}else{
			RegCountAd($id, $admailno, $adid, $SUM_KIND{'nopaccess'}, 1);
		}
		$sth->finish ();
	}
};

if ($@) {
    # �����ADBI��RaiseError��die������A$@ �ɂ�$DBI::errstr�������Ă��܂��B
	# �o�^���s
    $db->do ("rollback");
    $db->do ("set autocommit=1");
	$db->disconnect ();
	undef($db);
	ShowInfo('�L���̃A�N�Z�X�Ɏ��s���܂���');
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