#!/usr/bin/perl -w
# �����ݒ� -----------------------------------------------#

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Net::SMTP;
#use lib qw(../../common);
#use lib qw(/home/httpd/WebDB);
use lib qw(/home/vhosts/JKZ/extlib/common);
use lib qw(/home/vhosts/JKZ);
use MyClass::UsrWebDB;
use Data::Dumper;
use Goku::SiteSettings;
use Goku::Area;
use Goku::Output qw(ShowMsg);
use Goku::StrConv qw(ConvSJIS ReplaceHTML ReplaceHiddenData 
					 ReplaceHTMLTextArea ReplaceMailSubject 
					 ReplaceAdMailContents );
my $cgi = new CGI;
my %cookie = $cgi->cookie(-name=>'form_cookie');

my $admailno = $cgi->param('admailno');
my $from = $cgi->param('from');
my $client = $cgi->param('client');

my $subjectd = $cgi->param('subjectd');
my $contentsd = $cgi->param('contentsd');
my $maild = $cgi->param('maild');

my $subjectj = $cgi->param('subjectj');
my $contentsj = $cgi->param('contentsj');
my $mailj = $cgi->param('mailj');

my $subjecte = $cgi->param('subjecte');
my $contentse = $cgi->param('contentse');
my $maile = $cgi->param('maile');

my $subjecto = $cgi->param('subjecto');
my $contentso = $cgi->param('contentso');
my $mailo = $cgi->param('mailo');

sub ContentsCheck($$$$) {
	my ($db, $body, $count, $crr) = @_;
	my @msg = ('���̑��̑��M���e���s���ł�',
			   'NTT�h�R���̑��M���e���s���ł�',
			   'SoftBank�̑��M���e���s���ł�',
			   'AU�̑��M���e���s���ł�');
	#���M�����ƁA���g�̊m�F
	if(0 == $count){return 'OK';}
	if($body eq "" && $count!=0){
	
		return $msg[$crr];
	}
	#�L���R�[�h�̊m�F
	my ($sth, $row, $rec);
	my $list = $body;
	while ( $list=~ /$KEY_ADID/i) {
		my $key = $1;
		$sth=$db->prepare("
 select delad, adlimit ,unix_timestamp(adlimit) - unix_timestamp(now())
 from 1MP.tAdinfo where adid=$key;");
		$row=$sth->execute;
		if(!defined($row) || $row!=1){
			$sth->finish;
			return '�s���ȍL��ID���܂܂�Ă���\��������܂�'
		}
		$rec=$sth->fetchrow_arrayref;
		if($rec->[0] == 1){
			$sth->finish;
			return '�g�p�s�̍L��ID���܂܂�Ă���\��������܂�';
		}
		if($rec->[1] ne "0000-00-00 00:00:00" && $rec->[2] < 0){
			$sth->finish;
			return '�����؂�̍L��ID���܂܂�Ă���\��������܂�';
		}
		$sth->finish;
		$list =$'; #'
	}
	return 'OK';
}1;

sub ShowInfo{
	#�P�ɃG���[��HTML�o�͂��A�E�o���邾��
    print "Content-type: text/html; charset=Shift_JIS\n\n";
    print "<HTML><HEAD>\n";
    print "<TITLE>" . '�L�����[�����M�m�F' . "</TITLE>\n";
    print "</HEAD><BODY>\n";
    print $_[0] . "<BR>\n";
	print "</BODY></HTML>";
}1;

#�e�X�g���[�����M
sub SendTestMail($$$$$$){
	my ($admailno, $to, $from, $subject, $body, $crr) = @_;
	$subject = ReplaceMailSubject($subject, $crr);

	my($sp, $header);
	unless($sp = Net::SMTP->new('192.168.10.10')){
		return 0;
	}

	$header = Goku::StrConv::GetMailHeader(
		$subject, $from, $to, $crr, undef);
	#�����Ȃ�BASE64�������̂��~����
	$body = Goku::StrConv::GetTestMailBody($admailno,$body, $crr);
	$sp->mail($from);
	$sp->to($to);
	$sp->data();
	$sp->datasend($header);
	$sp->datasend("\n");
	$sp->datasend($body);
	$sp->dataend();
	$sp->quit();

warn Dumper ($sp);

	return 1;
};

#�e�X�g���[�����M���̓���
#�e��p�����[�^�[�̃`�F�b�N
if($admailno ==0){
	#���[���񐔂��s��
	ShowInfo('���[���񐔂��s���ł�');
	exit;
}
if($client eq ""){
	#�N���C�A���g�����s��
	ShowInfo('�N���C�A���g�����s���ł�');
	exit;
}
if($from eq ""){
	#���M�����[���A�h���X���s��
	ShowInfo('���M�����[���A�h���X���s���ł�');
	exit;
}

##�e�X�g���[�����M
##���邢�\�[�X������N��������
if(defined $cgi->param('t_send_d') ){
	if($maild !~ /^([A-Z0-9\_\.\~\?\-\/]+)@([A-Z0-9\_\.\~\-]+)$/i){
		ShowInfo('DoCoMo�e�X�g���[�����M�惁�[���A�h���X���s���ł�');
		exit;
	}
	if(SendTestMail($admailno, $maild, $from, $subjectd, $contentsd, 1)){
		ShowInfo('DoCoMo�e�X�g���[�����M���܂���');
		exit;
	}else{
		ShowInfo('DoCoMo�e�X�g���[�����M�Ɏ��s���܂���');
		exit;
	}
}
if(defined $cgi->param('t_send_j') ){
	if($mailj !~ /^([A-Z0-9\_\.\~\?\-\/]+)@([A-Z0-9\_\.\~\-]+)$/i){
		ShowInfo('SoftBank�e�X�g���[�����M�惁�[���A�h���X���s���ł�');
		exit;
	}
	if(SendTestMail($admailno, $mailj, $from, $subjectj, $contentsj, 2)){
		ShowInfo('SoftBank�e�X�g���[�����M���܂���');
		exit;
	}else{
		ShowInfo('SoftBank�e�X�g���[�����M�Ɏ��s���܂���');
		exit;
	}
}
if(defined $cgi->param('t_send_e') ){
	if($maile !~ /^([A-Z0-9\_\.\~\?\-\/]+)@([A-Z0-9\_\.\~\-]+)$/i){
		ShowInfo('AU�e�X�g���[�����M�惁�[���A�h���X���s���ł�');
		exit;
	}
	if(SendTestMail($admailno, $maile, $from, $subjecte, $contentse, 3)){
		ShowInfo('AU�e�X�g���[�����M���܂���');
		exit;
	}else{
		ShowInfo('AU�e�X�g���[�����M�Ɏ��s���܂���');
		exit;
	}
}
if(defined $cgi->param('t_send_o') ){
	if($mailo !~ /^([A-Z0-9\_\.\~\?\-\/]+)@([A-Z0-9\_\.\~\-]+)$/i){
		ShowInfo('���̑��e�X�g���[�����M�惁�[���A�h���X���s���ł�');
		exit;
	}
	if(SendTestMail($admailno, $mailo, $from, $subjecto, $contentso, 0)){
		ShowInfo('���̑��e�X�g���[�����M���܂���');
		exit;
	}else{
		ShowInfo('���̑��e�X�g���[�����M�Ɏ��s���܂���');
		exit;
	}
}


#DB�ڑ�
my($db, $sth, $row, $rec);
$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');
#��ɂȂ��ł����Ȃ��Ɠ����Ȃ��@�����Ă������Ⴂ
my @msg =( ContentsCheck($db, $contentsd, $cookie{sendmemd}, 1),
		   ContentsCheck($db, $contentsj, $cookie{sendmemj}, 2),
		   ContentsCheck($db, $contentse, $cookie{sendmeme}, 3),
		   ContentsCheck($db, $contentso, $cookie{sendmemo}, 0));
if(@msg = grep $_ ne 'OK', @msg){
	#�ǂꂩ�ŃG���[���������� ����OK�͊Ԉ���
	$db->disconnect;
	undef($db);
	ShowInfo(join '<br>',@msg);
	exit;
}
$db->disconnect;
undef($db);

#�l���܂Ƃ��ł���΁A�N�b�L�[�ɒǉ�
$cookie{'from'} = $from;
$cookie{'client'} = $client;
$cookie{'subjectd'} = $subjectd;
$cookie{'contentsd'} = $contentsd;
$cookie{'subjectj'} = $subjectj;
$cookie{'contentsj'} = $contentsj;
$cookie{'subjecte'} = $subjecte;
$cookie{'contentse'} = $contentse;
$cookie{'subjecto'} = $subjecto;
$cookie{'contentso'} = $contentso;
my $form_cookie = $cgi->cookie(-name => 'form_cookie',
							   -value => \%cookie);

#############################
# �m�F��ʂ̕\��
#############################
print $cgi->header(-type => 'text/html',
			 -charset => 'Shift_JIS',
			 -cookie => $form_cookie);
print << "END_OF_HERE_DOC";
<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html
	PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN"
	 "http://www.w3.org/TR/xhtml1/Dtd/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
<head>
<meta http-equiv="content-type" content="application/xhtml+xml;charset=Shift_JIS" />
<meta name="Pragma" content="no-cache" />
<title>�L���R�[�h���ҏW</title>
<link rel="stylesheet" href="/style.css" type="text/css" charset="Shift_JIS" />
<link rel="stylesheet" type="text/css" href="build/fonts/fonts-min.css" />
<script src="/js/popuphint.js" type="text/javascript"></script>
</head>
<body class="yui-skin-sam">
<div id="base"><!-- ---------------------------------------------------------------------------- -->
	<!-- �w�b�_�[ -->
	<div id="head">
		<h1>UPSTAIR �V�X�e���@�Ǘ��҉��</h1>
	</div>
   	<div id="side">
		<script src="/js/cms_leftmenu.js" type="text/JavaScript"></script>
	</div>
	<div id="main"><!-- ---------------------------------------------------------------------------- -->
		<!-- �p������ -->
		<div id="pankuzu">
			<a href="/app.mpl">�g�b�v</a>���L���Ǘ���<strong>���[���L�����[���m�F</strong>
		</div>
		<!-- �^�C�g�� -->
		<div class="screen_title">
			<h2>�L���Ǘ�</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

<!--
				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>
-->

<form action="/mod-perl/regadmail.cgi" method="post">
<input type="hidden" name="admailno" value="$admailno">

<!--<table border=0 cellpadding=3 cellspacing=1 bgcolor=#000000 width=720 align="center">-->
<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">
<tr>
<th nowrap bgcolor="#eeeaff" align="center" colspan="3">��${admailno}�񃁁[���}�K�W���m�F���</th>
</tr>

<tr>
<td bgcolor="#ffffff" colspan=3>$cookie{'msg_where'}</td>
<tr>
<td bgcolor="#eeeaff" colspan=2 width=30%>�N���C�A���g��</td>
<td bgcolor="#ffffff">$client</td>
</tr>
<tr>
<td bgcolor="#eeeaff" colspan=2>���M�����[���A�h���X</td>
<td bgcolor="#ffffff">$from</td>
</tr>
<tr>
<td bgcolor="#eeeaff" rowspan=3>NTT�h�R��</td>
<td bgcolor="#eeeaff">���M�ΏێҐ�</td>
<td bgcolor="#ffffff">$cookie{'sendmemd'}�l</td>
</tr>
<tr>
<td bgcolor="#eeeaff" width=15%>�^�C�g��</td>
<td bgcolor="#ffffff">$subjectd</td>
</tr>
<tr>
<td bgcolor="#eeeaff">�{��</td>
<td bgcolor="#ffffff">$contentsd</td>
</tr>
<tr>
<td bgcolor="#eeeaff" rowspan=3>�{�[�_�t�H��</td>
<td bgcolor="#eeeaff">���M�ΏێҐ�</td>
<td bgcolor="#ffffff">$cookie{'sendmemj'}�l</td>
</tr>
<tr>
<td bgcolor="#eeeaff">�^�C�g��</td>
<td bgcolor="#ffffff">$subjectj</td>
</tr>
<tr>
<td bgcolor="#eeeaff">�{��</td>
<td bgcolor="#ffffff">$contentsj</td>
</tr>
<tr>
<td bgcolor="#eeeaff" rowspan=3>EZweb</td>
<td bgcolor="#eeeaff">���M�ΏێҐ�</td>
<td bgcolor="#ffffff">$cookie{'sendmeme'}�l</td>
</tr>
<tr>
<td bgcolor="#eeeaff">�^�C�g��</td>
<td bgcolor="#ffffff">$subjecte</td>
</tr>
<tr>
<td bgcolor="#eeeaff">�{��</td>
<td bgcolor="#ffffff">$contentse</td>
</tr>
<td bgcolor="#eeeaff" rowspan=3>���̑�</td>
<td bgcolor="#eeeaff">���M�ΏێҐ�</td>
<td bgcolor="#ffffff">$cookie{'sendmemo'}�l</td>
</tr>
<tr>
<td bgcolor="#eeeaff">�^�C�g��</td>
<td bgcolor="#ffffff">$subjecto</td>
</tr>
<tr>
<td bgcolor="#eeeaff">�{��</td>
<td bgcolor="#ffffff">$contentso</td>
</tr>
<tr>
<td bgcolor="#ffffff" colspan="3">
<input type="hidden" name="admailno" value="$admailno" />
<center>
  <input type="submit" name="sub_send" value="�@���M�@" />
</center>
</td>
</tr>
</table>
</form>
<br>
<a href="/mod-perl/rptad.mpl?page=1" target="_blank">�L��ID�\\��</a><p>
<a href="/mod-perl/rptadmail.mpl?page=1" target="_blank">���M����</a>

		</div>

	</div><!-- ---------------------------------------------------------------------------- -->

	<!-- �R�s�[���C�g -->
	<div id="copy">
		<div class="line"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
		(c)UP-STAIR 2009 All Rights Reserved
	</div>

</div>

</body>
</html>
END_OF_HERE_DOC
exit;
