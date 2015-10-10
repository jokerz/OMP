# �����ݒ� -----------------------------------------------#

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
# �L���Ǘ��e�[�u���̃n�b�V�����Q��
# WebEnvConf�͎g�p���Ȃ�
# �b��Ή� 2010/01/31
#**********************************
my $HASHTB = {
		KARA_MAIL		=>	'1MP.tKaraMailF',
		MEMBER			=>	'1MP.tMemberM',
		USERIMAGE		=>	'1MP.tUserImageM',
	## ��������͊Ǘ���pDB
		ADCONTENTS		=>	'1MP.tAdcontents',
		ADINFO			=>	'1MP.tAdinfo',
		ADMAIL			=>	'1MP.tAdmail',
		#####@���̃e�[�u���͉���ڂ̔z�M�������������ɂ�admailmanage1 admailmanage3 �Ƃ�
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
	## �������牺��logdata�f�[�^�x�[�X
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
# �n���ꂽ�l��ϐ��փZ�b�g
#****************************
if ($ENV{'REQUEST_METHOD'} eq 'POST') {
	#****************************
	# �p�����[�^�̒l���擾
	#****************************
	$page=$form->param("page");
}
else {
	if($ENV{'QUERY_STRING'} ne ""){
	    @pairs = split(/&/,$ENV{'QUERY_STRING'});
	
		#****************************
		# �p�����[�^�̒l���擾
		#****************************
		($k,$page) = split(/=/,$pairs[0]);
	}
}

my @URL=("/app.mpl",'�߂�');

#****************************
# DB���`�F�b�N
#****************************

$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');
#****************************
# SQL�����s
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
	&ShowMsg('���M����','���̎擾�Ɏ��s���܂���',1, @URL);
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	ModPerl::Util::exit();
}

if($sth->rows==0){
	#�\�����郁�[���񐔂��Ȃ��̂ŃG���[�Ƃ���
	&ShowMsg('���M����','�\�������񂪂���܂���',1,@URL);
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	ModPerl::Util::exit();
}

$max=$sth->rows;
$list=$sth->fetchall_arrayref();

#****************************
# �񐔂̍ő吔���擾
#****************************

$listnum = 15;
$maxpage=int($max / $listnum);
if($max % $listnum){
	$maxpage++;
}

if($maxpage == 0){
	#�ǉ��ƊǗ��g�b�v�֖߂�݂̂�\��
	&ShowMsg('���M����','�L�����[�����͂���܂���',1, @URL);
	ModPerl::Util::exit();
}

#****************************
# �y�[�W�ԍ�����\������񐔂��擾
#****************************
$startpos=($page-1)*$listnum;


#****************************
#�L�����[���̑��MDB���I�[�v��
#****************************
$dba = MyClass::UsrWebDB::connect();
$dba->do('set names sjis');

#****************************
# ���ʕ����̏o��
#****************************
my @caption = ('No.', '�N���C�A���g��', '�z�M����', '�^�C�g��', '�{��', '���M����', '���M�I������', '���', '���M���s����', '���M����',);
print $form->header(-charset=>'shift_jis');
print $form->start_html (
					-encoding=>'Shift_JIS',
					-head=>$form->meta({-http_equiv=>'Content-Type', -content=>'text/html', -charset=>'Shift_JIS'}),
					-lang=>"ja",-title=>"���M����",
					-style=>{-src=>'/css/style.css',-code=>''},
	);
#print qq(<script src="/js/cms_header.js" type="text/JavaScript"></script>);
#print $form->a({-href=>"/mod-perl/downloadadmail.mpl",-target=>"_blank"},"�_�E�����[�h") . $form->br ();
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
		$limit = '�@';
	}
	print "<TD>" . $limit . "</TD>\n";
	if(defined($list->[$cnt][2])){
		$limit = $list->[$cnt][2];
		$limit =~ s/\-/\//gi;
	}
	else{
		$limit = '�@';
	}
	print "<TD>" . $limit . "</TD>\n";

### ���[���X�P�W���[�����O
	if($list->[$cnt][3] == 4){
		print "<TD>" . '���M�\�񒆎~' . "</TD>\n";
	}
	elsif($list->[$cnt][3] == 3){
		print "<TD>" . '���M�\��' . "\n";

		# �\�񒆎~�L�[�\��
		print "<FORM ACTION=\"/mod-perl/chkdel_admail.cgi\" method=post>\n";
		print "<INPUT TYPE=HIDDEN name=id value=" . $admailno . ">\n";
		print "<INPUT TYPE=SUBMIT value=\"" . '���M���~' . "\">\n";
		print "</FORM>\n";
		print "</TD>\n";
	}
	elsif($list->[$cnt][3] == 2){
		print "<TD>" . '���M�҂�' . "</TD>\n";
	}
	elsif($list->[$cnt][3] == 1){
		print "<TD>" . '���M��' . "</TD>\n";
	}
	elsif($list->[$cnt][3] == -1){
		print "<TD>" . '���M���s' . "</TD>\n";
	}
	elsif($list->[$cnt][3] == 9){
		print "<TD>" . '���M���s' . "</TD>\n";
	}
	else{
		print "<TD>" . '�@' . "</TD>\n";
	}

	if( $list->[$cnt][3]==0 ) {
		$table="tAdmailmanage" . $admailno;
		$sendngcnt=0;
		$sendcnt=0;

		#���M���s�������J�E���g����
		$stha=$dba->prepare("SELECT COUNT(*) FROM $table WHERE admailno='$admailno' AND send_status!=1;");
		$stha->execute;
		if($stha->rows!=0){
			$reca=$stha->fetchrow_arrayref;
			if($reca->[0]>0){
				$sendngcnt=$reca->[0];
			}
		}
		$stha->finish;
		#���M�������J�E���g����
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
		$sendngcnt = '�@';
		$sendcnt = '�@';
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
	# �O�y�[�W�ւ�\��
	print qq(<TD><FORM ACTION="$ENV{SCRIPT_NAME}" method="post">);
	print "<INPUT TYPE=HIDDEN name=page value=" . ($page-1) . ">\n";
	print "<INPUT TYPE=SUBMIT value=\"" . '�O�y�[�W��' . "\">\n";
	print "</FORM></TD>\n";
}
if($page<$maxpage){
	# ���y�[�W�ւ�\��
	print qq(<TD><FORM ACTION="$ENV{SCRIPT_NAME}" method="post">)
		. qq(<INPUT TYPE=HIDDEN name="page" value=) . ($page+1) . '>'
		. qq(<INPUT TYPE=SUBMIT value="���y�[�W��">)
		. qq(</FORM></TD>)
		;
}
print "</TR></TABLE>\n";
print "<a href=\"javascript:window.close()\">" . '����' . "</a>\n";
print "</BODY>\n";
print "</HTML>\n";

$sth->finish ();
$db->disconnect ();
undef($db);

ModPerl::Util::exit();
