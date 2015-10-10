#!/usr/bin/perl -w
# �����ݒ� -----------------------------------------------#

use strict;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(/home/vhosts/JKZ/extlib/common);
use lib qw(/home/vhosts/JKZ);
use MyClass::UsrWebDB;
use Goku::SiteSettings;
use Goku::Output qw(ShowMsg);
use Goku::StrConv qw(ConvSJIS ReplaceFieldValue);
use Data::Dumper;

my $q = CGI->new();

#########################
#  �L�����[���f�ځE�A�N�Z�X�W�v�̃p�����[�^
#########################

my $buffer;
my @pairs;
my $k;
my $page=1;
my $id="";
my $adname="";
my $urld="";
my $urlj="";
my $urle="";
my $urlo="";
my $limityear="";
my $limitmonth="";
my $limitday="";
my $limithour="";
my $limitmin="";
my $nolimit="";
my @work;
my $point=0;
my $delad=0;
my $update=0;
my $limit;

my $db;
my $dba;
my $sth="";
my $stha="";

my $setid;
my $rec;
my $commoncond;
my $s_cnt;
my $cnt;
my $cond;
my $row;

my $mailcnt=0;
my $access=0;
my $publish=0;
my $rst_num=0;
my $num=0;
my $rst_csl=0;
my $resetinfo=0;
my $find=0;

my $table;
my @adcount_tables=();

#############################
# �n���ꂽ�l��ϐ��־��
#############################
if ($ENV{'REQUEST_METHOD'} eq 'POST') {
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    @pairs = split(/&/,$buffer);
}
else {
	if($ENV{'QUERY_STRING'} ne ""){
	    @pairs = split(/&/,$ENV{'QUERY_STRING'});
	}
}
#############################
# ���Ұ��̒l���擾
#############################
my $pcnt;
my @pwork;

if ($pwork[0] =~ /^rst(\d+)$/i){
		if(defined($pwork[1])){
			$rst_num=$1;
		}
	}

## Modified 2008/07/03
#my %QueryCGI = $q->Vars ();
#map { "\$$_" = $QueryCGI{$_} } keys %QueryCGI;


## Modified  �s���p�����[�^�ǉ� 2008/10/14
$setid  = $q->param('setid');
$point  = $q->param('point');


$urld	= $q->param('urld');
$urlj	= $q->param('urlj');
$urle	= $q->param('urle');
$urlo	= $q->param('urlo');
$id		= $q->param('id');
$page	= $q->param('page');
$adname	= $q->param('adname');
$limityear	= $q->param('limityear');
$limitmonth = $q->param('limitmonth');
$limitday	= $q->param('limitday');
$limithour	= $q->param('limithour');
$nolimit	= $q->param('nolimit');
$delad		= $q->param('delad');
$update		= $q->param('update');
$commoncond = $q->param('commoncond');
$resetinfo	= $q->param('resetinfo');
$mailcnt	= $q->param('mailcnt');
$publish	= $q->param('publish');
$access		= $q->param('access');



## Modified 2008/10/14
my @URL = ("/mod-perl/editad.mpl?page=$page&id=$id", '���߂�');
my @LIST = ("/mod-perl/rptad.mpl?page=$page", '���߂�');

#############################
# �p�����[�^�̒l���`�F�b�N
#############################
if(grep($_ eq '', ($urld, $urlj, $urle, $urlo)) ){
	#URL���s�� �ǂꂩ1�ł���Ȃ��
	ShowInfo ('URL���s���ł�');
	ModPerl::Util::exit ();
}


#############################
# �����ʂ��`�F�b�N
#############################
if($rst_num > 0) {
	### ���Z�b�g�w��
	if($id != $rst_num) {
		### ���ۂ̕ҏW�L���R�[�h�ƃ��Z�b�g�ΏۍL���R�[�h���قȂ�ꍇ
		ShowInfo('���Z�b�g�Ώۂ̍L���R�[�h���s���ł�');
		ModPerl::Util::exit ();
	}

	print "Content-Type: text/html; charset=Shift_JIS\n\n";
print <<_HTML_HEADER_;
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

	<!-- ���������������������������� ���j���[ BEGIN ��������������������������������-->
   	<div id="side">
		<script src="/js/cms_leftmenu.js" type="text/JavaScript"></script>
	</div>

	<div id="main"><!-- ---------------------------------------------------------------------------- -->
		<!-- �p������ -->
		<div id="pankuzu">
			<a href="/app.mpl">�g�b�v</a>���L���Ǘ���<strong>���[���L���R�[�h���ҏW�����Z�b�g��</strong>
		</div>
		<!-- �^�C�g�� -->
		<div class="screen_title">
			<h2>�L���Ǘ�</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>
<!--
		<div id="menu_yoko">
			<ul>
				<li><a href="/mod-perl/editad.mpl?page=1;id=0">�L���R�[�h�o�^ </a></li>
				<li><a href="/mod-perl/rptad.mpl?page=1">�L���R�[�h�ꗗ </a></li>
				<li><a href="/mod-perl/addadmail.mpl?clear=1">���[���z�M </a></li>
				<li><a href="/mod-perl/rptadmail.mpl?page=1" target="blank">���[�����M����</a></li>
			</ul>
		</div>
-->
_HTML_HEADER_

	print "<form action=\"/mod-perl/editad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=hidden name=\"id\" value=\"$id\">\n";
	print "<input type=hidden name=\"setid\" value=\"$setid\">\n";
	#print "<table border=1 cellpadding=3 cellspacing=0 width=\"100%\">\n";
print qq(<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">);
	if($resetinfo==1) {
		print "<captoin>" . '�L���R�[�h�F' . $id . '�@�̏W�v�l���Z�b�g���������܂��B<br>�X������Ή����{�^���������ĉ������B' . "</caption>\n";
		$rst_csl=1;
	}
	else {
		print "<captoin>" . '�L���R�[�h�F' . $id . '�@�̏W�v�l�����Z�b�g���܂��B<br>�X������΃��Z�b�g�{�^���������ĉ������B' . "</caption>\n";
	}
	print "<br /><br />\n";
	print "<tr><td nowrap bgcolor=#eeeaff align=center colspan=3>";
	print '�L���R�[�h�F' . $id . "\n";
	print "<br>\n";
	print '�����}�K�f�ڐ��F' . $mailcnt . "</td></tr>\n";
	print "<tr>\n";
	print "<td bgcolor=#eeeaff colspan=2>" . '�z�M��' . "</td>\n";
	print "<td>" . $publish . "</td></tr>\n";
	print "<tr>\n";
	print "<td bgcolor=#eeeaff colspan=2>" . '�A�N�Z�X��' . "</td>\n";
	print "<td>" . $access . "</td></tr>\n";
	print "</td></tr>\n";
	print "<tr><td bgcolor=#eeeaff colspan=2 width=\"40%\">" . '����' . "</td>\n";
	print "<td bgcolor=#ffffff>" . $adname . "</td></tr>\n";
	print "<tr><td bgcolor=#eeeaff rowspan=2 width=\"20%\">" . '�T�C�g�w��' . "</td>\n";
	print "<td bgcolor=#eeeaff width=\"20%\">" . '����' . "</td>\n";
	print "<tr><td bgcolor=#eeeaff width=\"20%\">" . '�I��' . "</td>\n";
	print "<td bgcolor=#ffffff>";
	print "</td></tr>\n";
	print "<tr> \n";
	print "<td bgcolor=white colspan=3 align=center>\n";
	print "<table border=0 cellspacing=0 cellpadding=0>\n";
	print "<tr><td>\n";
	if($rst_csl==1) {
		print "<input type=\"submit\" value=\"����\">\n";
		print "<input type=hidden name=\"reset\" value=\"0\">\n";
	}
	else {
		print "<input type=\"submit\" value=\"���Z�b�g\">\n";
		print "<input type=hidden name=\"reset\" value=\"1\">\n";
	}
	print "</td>\n";
	print "</form>\n";
	print "<td>\n";
	print "<form action=\"/mod-perl/editad.cgi\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=hidden name=\"id\" value=\"$id\">\n";
	print "<input type=hidden name=\"reset\" value=\"$resetinfo\">\n";
	print "&nbsp;&nbsp;";
	print "<input type=\"submit\" value=\"" . '�L�����Z��' . "\">";
	print "</td>\n";
	print "</tr>\n";
	print "</table>\n";
	print "</table>\n";
print <<_HTML_FOOTER_;
		</div>

	</div><!-- ---------------------------------------------------------------------------- -->

	<!-- �R�s�[���C�g -->
	<div id="copy">
		<div class="line"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
		(c)UP-STAIR 2009 All Rights Reserved
	</div>

</div>
_HTML_FOOTER_
	print "</body>\n";
	print "</html>\n";
	ModPerl::Util::exit();
}

#############################
# DB���`�F�b�N
#############################

$db = MyClass::UsrWebDB::connect();
$db->do("set names sjis");
#############################
# �p�����[�^�̒l���`�F�b�N
#############################
if($nolimit eq ""){
	#�L���������`�F�b�N
	#���K�\���g����
	$limit = $limityear . "-" . $limitmonth . "-" . $limitday . " " . $limithour . ":" . $limitmin . ":00";
	my $chkyear=sprintf("%04d",$limityear);
	my $chkmonth=sprintf("%02d",$limitmonth);
	my $chkday=sprintf("%02d",$limitday);
	my $chkhour=sprintf("%02d",$limithour);
	my $chkmin=sprintf("%02d",$limitmin);
	
	$sth=$db->prepare("select date_add('$limit', interval 0 day),
				      date_format(date_add('$limit', interval 0 day), '%Y'), 
					  date_format(date_add('$limit', interval 0 day), '%m'), 
					  date_format(date_add('$limit', interval 0 day), '%d'), 
					  date_format(date_add('$limit', interval 0 day), '%H'), 
					  date_format(date_add('$limit', interval 0 day), '%i');");
	$sth->execute;
	
	if(!$sth || $sth->rows == 0){
		&ShowInfo('�L���������s���ł�');
		$sth->finish;
		$db->disconnect;
		undef($db);
		ModPerl::Util::exit ();
	}
	$rec=$sth->fetchrow_arrayref;
	if($rec->[0] eq ""){
		&ShowInfo('�L���������s���ł�');
		$sth->finish;
		$db->disconnect;
		undef($db);
		ModPerl::Util::exit ();
	}
	if($rec->[1] ne $chkyear || $rec->[2] ne $chkmonth || $rec->[3] ne $chkday || $rec->[4] ne $chkhour || $rec->[5] ne $chkmin){
		&ShowInfo('�L���������s���ł�');
		$sth->finish;
		$db->disconnect;
		undef($db);
		ModPerl::Util::exit ();
	}
	$limit = $rec->[0];
	$sth->finish;
}
else{
	$limit = "";
}

#############################
# ����̍L��ID�����邩���`�F�b�N
#############################
$sth=$db->prepare("select adid from HP_management.tAdinfo where adid = $setid;");
$sth->execute;
if(!$sth){
	#�G���[�����������̂Œ��f
	ShowInfo('�L��URL�̓o�^�Ɏ��s���܂���');
	$sth->finish;
	$db->disconnect;
	undef($db);
	ModPerl::Util::exit ();
}

if($sth->rows > 0 && $update == 0){
	#�㏑�����m�F
	print "Content-type: text/html; charset=Shift_JIS\n\n";
print <<_HTML_HEADER_;
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

	<!-- ���������������������������� ���j���[ BEGIN ��������������������������������-->
   	<div id="side">
		<script src="/js/cms_leftmenu.js" type="text/JavaScript"></script>
	</div>

	<div id="main"><!-- ---------------------------------------------------------------------------- -->
		<!-- �p������ -->
		<div id="pankuzu">
			<a href="/app.mpl">�g�b�v</a>���L���Ǘ���<strong>���[���L���R�[�h���ҏW���o�^��</strong>
		</div>
		<!-- �^�C�g�� -->
		<div class="screen_title">
			<h2>�L���Ǘ�</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>
<!--
		<div id="menu_yoko">
			<ul>
				<li><a href="/mod-perl/editad.mpl?page=1;id=0">�L���R�[�h�o�^ </a></li>
				<li><a href="/mod-perl/rptad.mpl?page=1">�L���R�[�h�ꗗ </a></li>
				<li><a href="/mod-perl/addadmail.mpl?clear=1">���[���z�M </a></li>
				<li><a href="/mod-perl/rptadmail.mpl?page=1" target="blank">���[�����M����</a></li>
			</ul>
		</div>
-->
_HTML_HEADER_

	print '�L���R�[�h�̏����㏑�����Ă���낵���ł����H' . "\n";
	print "<p>\n";
	
	print qq(<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">);
	print "<td><form action=\"/mod-perl/regad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=hidden name=\"id\" value=\"$id\">\n";
	print "<input type=hidden name=\"setid\" value=\"$setid\">\n";
	print "<input type=hidden name=\"adname\" value=\"$adname\">\n";
	print "<input type=hidden name=\"urld\" value=\"$urld\">\n";
	print "<input type=hidden name=\"urlj\" value=\"$urlj\">\n";
	print "<input type=hidden name=\"urle\" value=\"$urle\">\n";
	print "<input type=hidden name=\"urlo\" value=\"$urlo\">\n";
	print "<input type=hidden name=\"limityear\" value=\"$limityear\">\n";
	print "<input type=hidden name=\"limitmonth\" value=\"$limitmonth\">\n";
	print "<input type=hidden name=\"limitday\" value=\"$limitday\">\n";
	print "<input type=hidden name=\"limithour\" value=\"$limithour\">\n";
	print "<input type=hidden name=\"limitmin\" value=\"$limitmin\">\n";
	print "<input type=hidden name=\"nolimit\" value=\"$nolimit\">\n";
	print "<input type=hidden name=\"point\" value=\"$point\">\n";
	print "<input type=hidden name=\"delad\" value=\"$delad\">\n";
	print "<input type=hidden name=\"update\" value=1>\n";
	print "<input type=hidden name=\"reset\" value=\"$resetinfo\">\n";
	print qq(<input type="submit" value="�@��@���@" onclick="init();" id="content" />);
	print "</form></TD>\n";
	print "<td><form action=\"/mod-perl/rptad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=\"submit\" value=\"" . '�L�����Z��' . "\">";
	print "</form></td>\n";
	print "</tr></table>\n";
print <<_HTML_FOOTER_;
		</div>

	</div><!-- ---------------------------------------------------------------------------- -->

	<!-- �R�s�[���C�g -->
	<div id="copy">
		<div class="line"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
		(c)UP-STAIR 2009 All Rights Reserved
	</div>

</div>
_HTML_FOOTER_
	
	print "</body>\n";
	print "</html>\n";
	ModPerl::Util::exit();
}

#############################
# ���̍X�V
#############################
eval{
	$db->do("set autocommit = 0") || die "�g�����U�N�V�����J�n���s\n";
	$db->do("begin") || die "�g�����U�N�V�����J�n���s\n";
	
	my $sadname = ReplaceFieldValue($adname);
	#�L��URL�̒ǉ�
	$sth=$db->prepare("
replace into 1MP.tAdinfo (adid, adname, adpoint, adlimit, delad, urld, urlj,
urle, urlo ) values ($setid, '$sadname', $point, '$limit', $delad, '$urld',
'$urlj', '$urle', '$urlo');");
	$sth->execute || die "�L��URL���o�^���s\n";
	
	$sth->finish;
	
	#############################
	# ���Z�b�g�w��̏ꍇ�A�f�ڐ��ƃA�N�Z�X�����X�V
	#############################
	if($resetinfo == 1) {

		$dba = MyClass::UsrWebDB::connect();
		$dba->do("set names sjis");
		$dba->do("set autocommit=0") || die "�g�����U�N�V�����J�n���s\n";
		$dba->do("begin") || die "�g�����U�N�V�����J�n���s\n";
		
		$stha = $dba->prepare("show tables");
		$row = $stha->execute;
		if(defined($row) && $row>0) {
			$cnt=0;
			$stha->bind_columns(\$table);
			while($rec = $stha->fetchrow_arrayref){
				if($table =~ /ad\d{6}/){
					push @adcount_tables, $table;
				}
			}
		}
		
		foreach (@adcount_tables){
			# �z�M����݌v�f�ڐ���ʂɕύX
			$dba->do("
update $_ set kind = $SUM_KIND{'publish_total'} 
where mailkind = $MAIL_KIND{'admail'} and adid=$id and 
kind = $SUM_KIND{'publich'};") || die "�z�M�����X�V�G���[\n";
			# �A�N�Z�X����݌v�A�N�Z�X����ʂɕύX
			$dba->do("
update $_ set kind = $SUM_KIND{'access_total'} 
where mailkind = $MAIL_KIND{'admail'} adid=$id and 
kind = $SUM_KIND{'access'};") || die "�A�N�Z�X�����X�V�G���[\n";
		}
	}
};# end of eval

if ($@) {
    # �����ADBI��RaiseError��die������A$@ �ɂ�$DBI::errstr�������Ă��܂��B
	# �o�^���s
    $db->do("rollback");
    $db->do("set autocommit=1");
	$db->disconnect;
	undef($db);
	if($resetinfo == 1) {
	    $dba->do("rollback");
	    $dba->do("set autocommit=1");
		$dba->disconnect;
		undef($dba);
	}
	ShowInfo('�L���R�[�h���̍X�V�Ɏ��s���܂���');
	print Dumper(\$@);
	ModPerl::Util::exit();
} else {
    $db->do("commit");
    $db->do("set autocommit=1");
	$db->disconnect;
	undef($db);
	if($resetinfo == 1) {
	    $dba->do("commit");
	    $dba->do("set autocommit=1");
		$dba->disconnect;
		undef($dba);
	}
}

ShowMsg('�L���R�[�h���ҏW���o�^��','�L���R�[�h���̍X�V�ɐ������܂���', 1, @LIST);
ModPerl::Util::exit();

sub ShowInfo() {
	my $message;
	($message)=@_;
	
	print "Content-type: text/html; charset=Shift_JIS\n\n";
print <<_HTML_HEADER_;
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
			<a href="/app.mpl">�g�b�v</a>���L���Ǘ���<strong>���[���L���R�[�h���ҏW���o�^��</strong>
		</div>
		<!-- �^�C�g�� -->
		<div class="screen_title">
			<h2>�L���Ǘ�</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>
_HTML_HEADER_

	print $message . "\n";
	print "<p>\n";
	
	print "<form action=\"/mod-perl/editad.mpl\" method=post>\n";
	print "<input type=hidden name=\"page\" value=\"$page\">\n";
	print "<input type=hidden name=\"id\" value=\"$id\">\n";
	print "<input type=hidden name=\"setid\" value=\"$setid\">\n";
	print "<input type=hidden name=\"adname\" value=\"$adname\">\n";
	print "<input type=hidden name=\"urld\" value=\"$urld\">\n";
	print "<input type=hidden name=\"urlj\" value=\"$urlj\">\n";
	print "<input type=hidden name=\"urle\" value=\"$urle\">\n";
	print "<input type=hidden name=\"urlo\" value=\"$urlo\">\n";
	print "<input type=hidden name=\"limityear\" value=\"$limityear\">\n";
	print "<input type=hidden name=\"limitmonth\" value=\"$limitmonth\">\n";
	print "<input type=hidden name=\"limitday\" value=\"$limitday\">\n";
	print "<input type=hidden name=\"limithour\" value=\"$limithour\">\n";
	print "<input type=hidden name=\"limitmin\" value=\"$limitmin\">\n";
	print "<input type=hidden name=\"nolimit\" value=\"$nolimit\">\n";
	print "<input type=hidden name=\"point\" value=\"$point\">\n";
	print "<input type=hidden name=\"delad\" value=\"$delad\">\n";
	print "<input type=hidden name=\"update\" value=1>\n";
	print "<input type=\"submit\" value=\"" . '�߂�' . "\">";
	print "</form>\n";
print <<_HTML_FOOTER_;
		</div>

	</div><!-- ---------------------------------------------------------------------------- -->

	<!-- �R�s�[���C�g -->
	<div id="copy">
		<div class="line"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
		(c)UP-STAIR 2009 All Rights Reserved
	</div>

</div>
_HTML_FOOTER_
	print "</body>\n";
	print "</html>\n";

}
