#!/usr/bin/perl -w
# �����ݒ� -----------------------------------------------#

use strict;
use CGI::Carp qw(fatalsToBrowser);
#use lib qw(../../common);
#"use lib qw(/home/httpd/WebDB);
#use UsrWebDB;
# mod-perl.conf��PerSwitches -Mlib�Ŏw��ς�
#use lib qw(/home/vhostsu/JKZ);
use MyClass::UsrWebDB;
#use JKZ::WebEnvConf qw($HASHTB $HASHURL %CARRIER);
use Goku::SiteSettings;
use Goku::StrConv qw(ConvSJIS);
use Goku::Output qw(ShowMsg);

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








my $buffer;
my @pairs;
my $id="";
my $page=0;
my $setid=0;
my $adname="";
my $urld="";
my $urlj="";
my $urle="";
my $urlo="";
my $limit="";
my %limit_sel = ("year" => "", "month" => "", "day" => "",
				 "hour" => "", "min" => "");
my $nolimit="";
my $point=0;
my $delad=0;
my $update=0;
my $db;
my $saveid;
my $sth;
my $row;
my @rec;
my $mailcnt=0;
my $dba;
my $stha;
my $adac;
my $table;
my $sthc;
my $publish=0;
my $access=0;
my @site=(0,0,0);
my @work;
my $cnt;

my $num=0;
my $resetinfo=0;

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
####1#########################
# ���Ұ��̒l���擾
#############################
my $pcnt;
my @pwork;
foreach $pcnt(0..$#pairs){
	@pwork= split(/=/,$pairs[$pcnt]);
	if($pwork[0] =~ /^id$/i){
		if(defined($pwork[1])){
			$id=$pwork[1];
		}
	}
	elsif($pwork[0] =~ /^page$/i){
		if(defined($pwork[1])){
			$page=$pwork[1];
		}
	}
	elsif($pwork[0] =~ /^adname$/i){
		if(defined($pwork[1])){
			$adname=$pwork[1];
			$adname=ConvSJIS($adname);
		}
	}
	elsif($pwork[0] =~ /^urld$/i){
		if(defined($pwork[1])){
			$urld=$pwork[1];
			$urld=ConvSJIS($urld);
		}
	}
	elsif($pwork[0] =~ /^urlj$/i){
		if(defined($pwork[1])){
			$urlj=$pwork[1];
			$urlj=ConvSJIS($urlj);
		}
	}
	elsif($pwork[0] =~ /^urle$/i){
		if(defined($pwork[1])){
			$urle=$pwork[1];
			$urle=ConvSJIS($urle);
		}
	}
	elsif($pwork[0] =~ /^urlo$/i){
		if(defined($pwork[1])){
			$urlo=$pwork[1];
			$urlo=ConvSJIS($urlo);
		}
	}
	elsif($pwork[0] =~ /^limityear$/i){
		if(defined($pwork[1])){
			$limit_sel{'year'} = $pwork[1];
		}
	}
	elsif($pwork[0] =~ /^limitmonth$/i){
		if(defined($pwork[1])){
			$limit_sel{'month'} = $pwork[1];
		}
	}
	elsif($pwork[0] =~ /^limitday$/i){
		if(defined($pwork[1])){
			$limit_sel{'day'} = $pwork[1];
		}
	}
	elsif($pwork[0] =~ /^limithour$/i){
		if(defined($pwork[1])){
			$limit_sel{'hour'} = $pwork[1];
		}
	}
	elsif($pwork[0] =~ /^limitmin$/i){
		if(defined($pwork[1])){
			$limit_sel{'min'} = $pwork[1];
		}
	}
	elsif($pwork[0] =~ /^nolimit$/i){
		if(defined($pwork[1])){
			$nolimit=$pwork[1];
		}
	}
	elsif($pwork[0] =~ /^point$/i){
		if(defined($pwork[1])){
			$point=$pwork[1];
		}
	}
	elsif($pwork[0] =~ /^delad$/i){
		if(defined($pwork[1])){
			$delad=$pwork[1];
		}
	}
	elsif($pwork[0] =~ /^update$/i){
		if(defined($pwork[1])){
			$update=$pwork[1];
		}
	}
	elsif($pwork[0] =~ /^reset$/i){
		if(defined($pwork[1])){
			$resetinfo=$pwork[1];
		}
	}
}


my @URL=("/app.mpl",'�߂�');

#############################
# DB���`�F�b�N
#############################
$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');

if($id == 0){
	#�V�K�L���R�[�h���s����
	$saveid=$setid;

	#############################
	# �L��ID�̔ԍ����擾
	#############################
	$sth=$db->prepare("select max(adid), date_format(now(), '%Y'),
	                  date_format(now(), '%m'),date_format(now(), '%d'),
	                  date_format(now(), '%h'),date_format(now(), '%i')
	                  from $HASHTB->{ADINFO};");
	$row=$sth->execute;
	if(!defined($row) || $row!=1){
		ShowMsg('�L���R�[�h', '�L���R�[�h�̏��擾�Ɏ��s���܂���', 1, @URL);
		exit;
	}
	
	@rec=$sth->fetchrow_array;
	if(defined($rec[0])){
		$setid=$rec[0]+1;
	}
	else{
		$setid=1;
	}

	if($saveid==0){
		#�V�K�o�^�̏ꍇ
		($limit_sel{'year'}, $limit_sel{'month'}, $limit_sel{'day'},
		 $limit_sel{'hour'}, $limit_sel{'min'}) = @rec[1..5];
		
		$point=1;
		$delad=0;
		$urld="";
		$urlj="";
		$urle="";
		$urlo="";
		$adname="";
	}
	
	$sth->finish;
}else{
	#############################
	# �L���R�[�h�̏����擾
	#############################
	$sth=$db->prepare("SELECT adname,
	                          adpoint,
	                          adlimit,
	                          delad,
	                          DATE_FORMAT(adlimit, '%Y'),
	                          DATE_FORMAT(adlimit, '%m'),
	                          DATE_FORMAT(adlimit, '%d'),
	                          DATE_FORMAT(adlimit, '%H'),
	                          DATE_FORMAT(adlimit, '%i'),
	                          urld,
	                          urlj,
	                          urle,
	                          urlo
	                   FROM $HASHTB->{ADINFO}
	                   WHERE adid=$id;");
	$row=$sth->execute;
	if(!defined($row) || $row!=1){
		ShowMsg('�L���R�[�h', '�L���R�[�h�̏��擾�Ɏ��s���܂���', 1, @URL);
		exit;
	}
	
	@rec=$sth->fetchrow_array;
	$setid=$id;
	($adname, $point, $limit, $delad, $limit_sel{'year'}, $limit_sel{'month'},
	 $limit_sel{'day'}, $limit_sel{'hour'}, $limit_sel{'min'},
	 $urld, $urlj, $urle, $urlo) = @rec;
	
	$sth->finish;
	
	if(!defined($limit) || $limit eq '0000-00-00 00:00:00'){
		#���Ԃ����܂��Ă��Ȃ��Ƃ��́A����������
		$limit = "";
		foreach (keys(%limit_sel)){
			$limit_sel{$_} = "";
		}
	}

	#############################
	# �L�����[���f�ڐ����擾
	#############################
	$sth=$db->prepare("select distinct admailno from $HASHTB->{ADSETMAIL}
	                   where adid=$id;");
	$row=$sth->execute;
	if(defined($row) && $row >0){
		$mailcnt=$sth->rows;
	}
	$sth->finish;
	
=pod
	#############################
	# �z�M���ƃA�N�Z�X���̍��v���擾
	#############################
	$stha=$dba->prepare("show tables like 'ad%'");
	$row = $stha->execute;
	if( $row ){
		$stha->bind_columns(\$table);
		while($rec = $stha->fetchrow_arrayref){
		#�e�[�u������L��ID�̃J�E���g�������߂�
		$sthc=$dba->prepare("select kind, sum(value) from $table where
                             adid=$id group by kind order by kind");
		
		$row=$sthc->execute;
		if(defined($row) && $row>0){
			while($adac=$sthc->fetchrow_arrayref) {
				if($adac->[0]==$SUM_KIND{'publish'}) {
					$publish += $adac->[1];
				}
				elsif($adac->[0]==$SUM_KIND{'access'}) {
					$access += $adac->[1];
				}
			}
		}
		$sthc->finish;

	}
	$stha->finish;
	$dba->disconnect;
	undef($dba);
=cut
}#end of �L��ID��URL�p�����[�^�Ƃ��ēn���ꂽ

$db->disconnect;
undef($db);


#############################
# �L�����[���̍쐬�y�[�W��\��
#############################
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
			<a href="/app.mpl">�g�b�v</a>���L���Ǘ���<strong>���[���L���o�^</strong>
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


#print "<form action=\"regad.cgi\" method=post>\n";
print "<form action=\"/mod-perl/regad.mpl\" method=post>\n";
print "<input type=hidden name=\"page\" value=\"$page\">\n";
print "<input type=hidden name=\"id\" value=\"$id\">\n";
print "<input type=hidden name=\"setid\" value=\"$setid\">\n";
print qq(<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">);

print "<tr>\n";
print "<th nowrap align=center colspan=3>" . '�L���R�[�h�F' . $setid . "\n";
unless(0 == $id){
	#�ҏW�Ȃ̂ŁA����\��
	print "<br>\n";
	print '�����}�K�f�ڐ��F' . $mailcnt . "</th></tr>\n";
	print "<tr>\n";
	print "<th colspan=2>" . '�z�M��' . "</th>\n";
	if($resetinfo == 0) {
		print "<td>" . $publish . "</td></tr>\n";
		print "<tr>\n";
		print "<th colspan=2>" . '�A�N�Z�X��' . "</th>\n";
		print "<td>" . $access . "</td></tr>\n";
	}
	else {
		print "<td bgcolor=#d5f7be><b>" . '0' . "</b></td></tr>\n";
		print "<tr>\n";
		print "<th colspan=2>" . '�A�N�Z�X��' . "</th>\n";
		print "<td bgcolor=#d5f7be><b>" . '0' . "</b></td></tr>\n";
		print "<input type=hidden name=\"reset\" value=\"$resetinfo\">\n";
	}
}
### print "</TD></TR>\n";
print "<tr>\n";
print "<th colspan=2>" . '����' . "</th>\n";
print "<td bgcolor=#ffffff>\n";
print "<input type=text name=\"adname\" value=\"$adname\" size=64 maxlength=255>\n";
print "</td></tr>\n";

print "<tr>\n";
print "<th rowspan=4>" . 'url' . "</th>\n";
print "<th>" . 'NTT�h�R��' . "</th>\n";
print "<td bgcolor=#ffffff>\n";
print "<input type=text name=\"urld\" value=\"$urld\" size=64>\n";
print "</td></tr>\n";
print "<tr>\n";
print "<th>" . 'SOFTBANK' . "</th>\n";
print "<td bgcolor=#ffffff>\n";
print "<input type=text name=\"urlj\" value=\"$urlj\" size=64>\n";
print "</td></tr>\n";
print "<tr>\n";
print "<th>" . 'AU' . "</th>\n";
print "<td bgcolor=#ffffff>\n";
print "<input type=text name=\"urle\" value=\"$urle\" size=64>\n";
print "</td></tr>\n";
print "<tr>\n";
print "<th>" . '���̑�' . "</th>\n";
print "<td bgcolor=#ffffff>\n";
print "<input type=text name=\"urlo\" value=\"$urlo\" size=64>\n";
print "</td></tr>\n";

print "<tr>\n";
print "<th colspan=2>" . '�L������' . "</th>\n";
print "<td bgcolor=#ffffff>\n";
print "<select name=\"limityear\" size=\"1\">\n";
print "<option> \n";
for($cnt=0; $cnt<100; $cnt++){
	printf "<option";
	if($limit_sel{'year'} ne ""){
		if(($cnt+2002) == $limit_sel{'year'}){
			print " selected";
		}
	}
	printf ">%04d\n", $cnt+2002;
}
print "</select>/\n";
print "<select name=\"limitmonth\" size=\"1\">\n";
print "<option> \n";
for($cnt=1; $cnt<=12; $cnt++){
	print "<option";
	if($limit_sel{'month'} ne ""){
		if($cnt == $limit_sel{'month'}){
			print " selected";
		}
	}
	printf ">%02d\n", $cnt;
}
print "</select>/\n";
print "<select name=\"limitday\" size=\"1\">\n";
print "<option> \n";
for($cnt=1; $cnt<=31; $cnt++){
	print "<option";
	if($limit_sel{'day'} ne ""){
		if($cnt == $limit_sel{'day'}){
			print " selected";
		}
	}
	printf ">%02d\n", $cnt;
}
print "</select>" . '�@' . "\n";
print "<select name=\"limithour\" size=\"1\">\n";
print "<option> \n";
for($cnt=0; $cnt<=23; $cnt++){
	print "<option";
	if($limit_sel{'hour'} ne ""){
		if($cnt == $limit_sel{'hour'}){
			print " selected";
		}
	}
	printf ">%02d\n", $cnt;
}
print "</select>:\n";
print "<select name=\"limitmin\" size=\"1\">\n";
print "<option> \n";
for($cnt=0; $cnt<=59; $cnt++){
	print "<option";
	if($limit_sel{'min'} ne ""){
		if($cnt == $limit_sel{'min'}){
			print " selected";
		}
	}
	printf ">%02d\n", $cnt;
}
print "</select><br>\n";
print "<input type=\"checkbox\" name=\"nolimit\" value=\"1\"";
if($limit eq ""){
	print " checked";
}
print ">" . '�L�������Ȃ�' . "</td></tr>\n";
print "<tr>\n";
print "<th colspan=2>" . '�ǉ��|�C���g' . "</th>\n";
print "<td bgcolor=#ffffff>\n";
print "<input type=text name=\"point\" value=\"$point\">\n";
print "</td></tr>\n";
print "<tr>\n";
print "<th colspan=2>" . '���' . "</th>\n";
print "<td bgcolor=#ffffff>\n";
print "<input type=radio name=\"delad\" value=0";
if($delad==0){
	print ' checked>�L��  ';
}
else{
	print ' >�L��  ';
}
print "<input type=radio name=\"delad\" value=1";
if($delad==1){
	print ' checked>����' . "\n";
}
else{
	print ' >����' . "\n";
}
print "</td></tr>\n";

print "<tr>\n";
print "<td bgcolor=\"white\" colspan=3 align=center>" . '�@';
print "<input type=hidden name=\"update\" value=0>";
unless(0 == $id){
	#�ҏW�Ȃ̂ŁA�X�V�{�^����\������
	print "<input type=\"submit\" value=\"" . '�X�V' . "\">\n";
	#�ҏW�Ȃ̂ŁA���Z�b�g�{�^�� or ���Z�b�g�����{�^����\������
	if($resetinfo == 0) {
		print "<input type=\"submit\" name=\"rst" . $id . "\" value=\"" . '���Z�b�g' . "\">\n";
	}
	else {
		print "<input type=\"submit\" name=\"rst" . $id . "\" value=\"" . '���Z�b�g����' . "\">\n";
	}
	print "<input type=hidden name=\"mailcnt\" value=\"$mailcnt\">";
	print "<input type=hidden name=\"publish\" value=\"$publish\">";
	print "<input type=hidden name=\"access\" value=\"$access\">";
}
else{
	#�V�K�o�^�Ȃ̂ŁA�o�^�{�^����\������
	print "<input type=\"submit\" value=\"" . '�@�@�o�@�@�^�@�@' . "\">\n";
}
print "</tr>\n";
print "</table>\n";
print "<br>\n";

#print "<a href=\"rptad.cgi?page=1\">" . '�L���R�[�h���ꗗ' . "</a><br>\n";
print "<a href=\"/mod-perl/rptad.mpl?page=1\">" . '�L���R�[�h���ꗗ' . "</a><br>\n";

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
