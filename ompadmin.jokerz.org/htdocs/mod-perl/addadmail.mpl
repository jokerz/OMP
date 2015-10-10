
use strict;
use CGI::Carp qw(fatalsToBrowser);

use lib qw(/home/vhosts/JKZ);
use MyClass::WebUtil;
use MyClass::UsrWebDB;
use Data::Dumper;
use Goku::SiteSettings;
use Goku::Area;
use Goku::Output qw(ShowMsg);
use Goku::StrConv qw(ConvSJIS ReplaceHTML ReplaceHiddenData 
					 ReplaceHTMLTextArea);
use Goku::SetWhere;

my $admailno=0;
my $subjectd="";
my $contentsd="";
my $maild="";
my $subjectj="";
my $contentsj="";
my $mailj="";
my $subjecte="";
my $contentse="";
my $maile="";
my $subjecto="";
my $contentso="";
my $mailo="";
my $fsitelist="1";
my $message="";


my ($db, $sth, $row, $ret, $sql);

my $fromstr;
my $whrstr;

my $rec;
my $back=0;
my @work;
my @fslist;
my @crr;
my @income;
my @job;
my @mar;
my @area;
my @sex;
my $cnt=0;

my @URL=("/app.mpl",'�߂�');


#############################
# ���Ұ��̒l���擾
#############################
my $cgi = CGI->new();
my %cookie;
my $clear = $cgi->param('clear'); #�N�b�L�[�N���A�t���O
unless($clear){
	#�N���A�t���O�������ĂȂ��Ȃ�
	#�N�b�L�[�擾
	%cookie = $cgi->cookie(-name => 'form_cookie');
}

my @fca = $cgi->param('fca'); #�L�����A�I���ꗗ
my $fca; #�L�����A�I��(�r�b�g�R�[�h)
my $fsme = $cgi->param('fsme'); #�G���[�񐔉���
my $feme = $cgi->param('feme'); #�G���[�񐔏��
my $ftmem = $cgi->param('ftmem'); #�����
my $frmem = $cgi->param('frmem'); #���
my $fspoint = $cgi->param('fspoint'); #�|�C���g����
my $fepoint = $cgi->param('fepoint'); #�|�C���g����
my @frsex = $cgi->param('frsex'); #����
my $frsex; #����(�r�b�g)
my $frsage = $cgi->param('frsage'); #�N���
my $freage = $cgi->param('freage'); #�N���
my $fbsmonth = $cgi->param('fbsmonth'); #�a�������@����
my $fbsday = $cgi->param('fbsday'); #�a������ ����
my $fbemonth = $cgi->param('fbemonth'); #�a�������@���
my $fbeday = $cgi->param('fbeday'); #�a�������@���
my @frincome = $cgi->param('frincome'); #�N��
my $frincome; #�N��(�r�b�g)
my @frjob = $cgi->param('frjob'); #�E��
my $frjob; #�E��(�r�b�g)
my @frmar = $cgi->param('frmar'); #��������
my $frmar; #����(�r�b�g)
my @frarea = $cgi->param('frarea'); #����
my $frarea; #����(�r�b�g)
my $frsyear = $cgi->param('frsyear'); #�o�^���t�N�@����
my $frsmonth = $cgi->param('frsmonth'); #�o�^���t���@����
my $frsday = $cgi->param('frsday'); #�o�^���t���@����
my $freyear = $cgi->param('freyear'); #�o�^���t�N ���
my $fremonth = $cgi->param('fremonth');#�o�^���t�� ���
my $freday = $cgi->param('freday');#�o�^���t�� ���
my $client = $cgi->param('client');#�N���C�A���g��
my $from = $cgi->param('from'); #���M�҃A�h���X
unless($from){ $from = $SITE_DEFAULT_FROM; }
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

#############################
# DB���`�F�b�N
#############################
$db = MyClass::UsrWebDB::connect();
$db->do('set names sjis');

sub db_error_exit
{
	#DB�G���[�ɂ��ً}�E�o
	my @msgs = @_;
	ShowMsg(@msgs);
	$sth->finish ();
	$db->disconnect ();
	undef($db);
	exit;
}

sub param_error_exit
{
	#�p�����[�^�[�G���[�̏o��
	my @msgs = @_;
	ShowMsg(@msgs);
	exit;
}

#############################
# �����������쐬
#############################
my $where;
#�N�b�L�[�̏㏑������������
Goku::SetWhere::CreateWhere($cgi, \$whrstr, \$where, \%cookie);


MyClass::WebUtil::warnMSG_LINE (\$where, __LINE__);

#############################
# �ŐV�̃��[���񐔂��擾
#############################
if($admailno == 0){
	$sth=$db->prepare("select max(admailno) from 1MP.tAdmail;");
	$row=$sth->execute ();
	if(!defined($row) || $row!=1){
		&db_error_exit('�L�����[���쐬','���̎擾�Ɏ��s���܂���',1,@URL);
	}
	if($sth->rows>0){
		$rec=$sth->fetchrow_arrayref;
		$admailno=$rec->[0]+1;
	}else{
		$admailno=1;
	}
	$sth->finish ();
}


#############################
# ���M�ΏێҐ����擾
#############################
#my $sql =
#"select carrier, count(id_no) from HP_general.tMemberM left join HP_management.error_mail on
# tMemberM.mailaddr = error_mail.error_mailaddr $where group by carrier;";
my $sql =
"select carrier, count(owid) from 1MP.tMemberM left join 1MP.error_mail on
 tMemberM.mobilemailaddress = error_mail.error_mailaddr $where group by carrier;";

$sth = $db->prepare($sql);
$row = $sth->execute ();
if(!defined($row) || $row==0){
	&db_error_exit(
		'�L�����[���쐬',
		"�w�肳�ꂽ�����ł͑��M�Ώێ҂����܂���: $sql",1,@URL
		);
}

my ($sendmemd, $sendmemj, $sendmeme, $sendmemo) = (0,0,0,0);
while($rec=$sth->fetchrow_arrayref){
	if($rec->[0] == 2 ** $CARRIER{'docomo'}){
		$sendmemd +=$rec->[1];
	}elsif($rec->[0] == 2 ** $CARRIER{'voda'}){
		$sendmemj +=$rec->[1];
	}elsif($rec->[0] == 2 ** $CARRIER{'ezweb'}){
		$sendmeme +=$rec->[1];
	}else{
		$sendmemo +=$rec->[1];
	}
}
$sth->finish ();
$db->disconnect ();
undef($db);
$cookie{'sendmemd'} = $sendmemd;
$cookie{'sendmemj'} = $sendmemj;
$cookie{'sendmeme'} = $sendmeme;
$cookie{'sendmemo'} = $sendmemo;

my $setcont = ReplaceHTML($whrstr);
#"<a href=\"mailreplace.cgi?site=1&kind=$MAIL_KIND{'admail'}\" target=\"_blank\">" .
=pod
my $sub_page_link =
"<a href=\"mailreplace.cgi?site=1&kind=12\" target=\"_blank\">" .
'�u���\������\\��' . "</a><p>\n";
$sub_page_link .=
"<a href=\"rptad.mpl?page=1\" target=\"_blank\">" .
'�L��ID�\\��' . "</a><br>\n";
$sub_page_link .=
"<a href=\"rptadmail.mpl?page=1\" target=\"_blank\">" .
'���M����' . "</a><p>\n";
=cut

my %hidden_contents = ('d' => ReplaceHiddenData($contentsd,1),
					 'v' => ReplaceHiddenData($contentsj,1),
					 'e' => ReplaceHiddenData($contentse,1),
					 'o' => ReplaceHiddenData($contentso,1));
my %send_contents = ('d' => ReplaceHTMLTextArea($contentsd),
					 'v' => ReplaceHTMLTextArea($contentsj),
					 'e' => ReplaceHTMLTextArea($contentse),
					 'o' => ReplaceHTMLTextArea($contentso));

my $hidden_fromstr = ReplaceHiddenData( $fromstr , 1 );
my $hidden_whrstr = ReplaceHiddenData( $whrstr , 1 );
my $hidden_where = ReplaceHiddenData( $where , 1 );

#############################
# �L�����[���̍쐬�y�[�W��\��
#############################
my $form_cookie = $cgi->cookie(-name => 'form_cookie',
						  -value => \%cookie);

print $cgi->header(-type => 'text/html',
						  -charset => 'Shift_JIS',
						  -cookie => $form_cookie);

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
			<a href="/app.mpl">�g�b�v</a>���L���Ǘ���<strong>���[�� �L�����[���쐬</strong>
		</div>
		<!-- �^�C�g�� -->
		<div class="screen_title">
			<h2>�L���Ǘ�</h2>
		</div>

		<div id="list">
			<!-- <fieldset> -->

				<div id="content"></div>
				<script src="/js/myIndicator.js" type="text/javascript"></script>



<!--<table style="border: solid 1px #000000;" cellpadding="0" cellspacing="0" width="100%" align="center">-->
<table border="0" cellspacing="0" width="100%" rules="all" class="datagrid">
<tr><td style="vertical-align:top;">

<table border=0 cellpadding=2 cellspacing=1 bgcolor=#999999 width="100%" align="center">
<tr>
<th nowrap bgcolor=#eeeaff align=center colspan=3> ��${admailno}�񃁁[���}�K�W�� </th>
</tr>

<tr>
<td bgcolor=#ffffff colspan="3">$cookie{'msg_where'}<br>
<form action="/mod-perl/admailfilter.mpl" method=post>
<input type=hidden name="admailno" value="$admailno">
<input type="submit" value="�����w��" onclick="init();" id="content" />
</form></td>
</tr>

<!--form action="/master/perl-cgi/chkadmail.cgi" method=post-->
<form action="/mod-perl/chkadmail.cgi" method=post>
<input type=hidden name="admailno" value="$admailno">

<tr>
<th colspan=2>�N���C�A���g��
</td>
<td bgcolor=#ffffff>
<input type="text" name="client" size="70" maxlength="50" value="$cookie{'client'}"></td>
</tr>

<tr>
<th colspan=2>���M�����[���A�h���X
</td>
<td bgcolor=#ffffff>
<input type="text" name="from" size="70" maxlength="50" value="$cookie{'from'}"></td>
</tr>

<tr>
<th rowspan=5>NTT�h�R��</td>
<th>���M�ΏێҐ�</td>
<td bgcolor=#ffffff>$cookie{'sendmemd'}�l</td>
</tr>

<tr>
<th>���ӎ���</td>
<td bgcolor=#ffffff><font color=red>�G��������͂���ꍇ�́A${KEY_DOCOMO_SHOW} (XXXX��S-JIS�R�[�h��16�i��)�̌`�œ��͂��Ă�������<br>
��j����}�[�N  : ${KEY_DOCOMO_CHECK}F89F${KEY_BASE_END}</font></td>
</tr>
<tr>
<th>�^�C�g��</td>
<td bgcolor=#ffffff>
<input type="text" name="subjectd" size="70" maxlength="136" value="$cookie{'subjectd'}"></td>
</tr>
<tr>
<th>�{��</td>
<td>
<textarea name="contentsd" rows="14" cols="48">$cookie{'contentsd'}
</textarea></td>
</tr>
<tr>
<th>���[���A�h���X<br>(�e�X�g���[�����M�p)</td>
<td bgcolor=#ffffff>
<input type="text" name="maild" size="50" maxlength="100" value="$maild" /><br>
<input type="submit" name="t_send_d" value="NTT�h�R�� �e�X�g���[�����M" onclick="init();" id="content" /> ���\\�����Ă�����e�Ńe�X�g���[���𑗐M���܂�</td>
</tr>

<tr>
<th rowspan=4>SOFTBANK</td>
<th>���M�ΏێҐ�</td>
<td bgcolor=#ffffff>$cookie{'sendmemj'}�l</td>
<tr>
<th>�^�C�g��</td>
<td bgcolor=#ffffff>
<input type="text" name="subjectj" size="70" maxlength="136" value="$cookie{'subjectj'}"></td>
</tr>
<tr>
<th>�{��</td>
<td><textarea name="contentsj" rows="14" cols="48">$cookie{'contentsj'}</textarea></td>
</tr>
<tr>
<th>���[���A�h���X<br>(�e�X�g���[�����M�p)</td>
<td bgcolor=#ffffff>
<input type="text" name="mailj" size="30" maxlength="100" value="$mailj" /><br>
<input type="submit" name="t_send_j" value="SOFTBANK �e�X�g���[�����M" onclick="init();" id="content" />���\\�����Ă�����e�Ńe�X�g���[���𑗐M���܂�</td>
</tr>

<tr>
<th rowspan=5>AU</td>
<th>���M�ΏێҐ�</td>
<td bgcolor=#ffffff>$cookie{sendmeme}�l</td>
</tr>
<tr>
<th>���ӎ���</td>
<td bgcolor=#ffffff><font color=red>�G��������͂���ꍇ�́A${KEY_EZWEB_SHOW} (x�̓A�C�R���ԍ�)�̌`�œ��͂��Ă�������<br>
��j����}�[�N  :  ${KEY_EZWEB_CHECK}44${KEY_BASE_END}</font><br>
</tr>
<tr>
<th>�^�C�g��</td>
<td bgcolor=#ffffff>
<input type="text" name="subjecte" size="70" maxlength="136" value="$cookie{'subjecte'}"></td>
</tr>

<tr>
<th>�{��</td>
<td bgcolor=#ffffff><textarea name="contentse" rows="14" cols="48">$cookie{'contentse'}</textarea></td>
</tr>
<tr>
<th>���[���A�h���X<br>(�e�X�g���[�����M�p)</td>
<td bgcolor=#ffffff>
<input type="text" name="maile" size="30" maxlength="100" value="$maile" /><br>
<input type="submit" name="t_send_e" value="AU �e�X�g���[�����M" onclick="init();" id="content" />���\\�����Ă�����e�Ńe�X�g���[���𑗐M���܂�</td>
</tr>

<tr>
<th rowspan=4>���̑�</td>
<th>���M�ΏێҐ�</td>
<td bgcolor=#ffffff>$cookie{'sendmemo'}�l</td>
<tr>
<th>�^�C�g��</td>
<td bgcolor=#ffffff>
<input type="text" name="subjecto" size="70" maxlength="136" value="$cookie{'subjecto'}"></td>
</tr>

<tr>
<th>�{��</td>
<td><textarea name="contentso" rows="14" cols="48">$cookie{'contentso'}</textarea></td>
</tr>
<tr>
<th>���[���A�h���X<br>(�e�X�g���[�����M�p)</td>
<td bgcolor=#ffffff>
<input type="text" name="mailo" size="30" maxlength="100" value="$mailo" /><br>
<input type="submit" name="t_send_o" value="���̑� �e�X�g���[�����M" onclick="init();" id="content" />���\\�����Ă�����e�Ńe�X�g���[���𑗐M���܂�</td>
</tr>

<tr>
<td bgcolor="white" colspan=4><center>
<input type="submit" name="exec" value="�@�m�@�F�@�@��@�ʁ@" onclick="init();" id="content" />
</td>
</tr>
</table>

</td></tr></table>
</form>
<br>
</font><p>

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
_HTML_HEADER_

ModPerl::Util::exit();
