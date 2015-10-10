#!/usr/bin/perl -w
# �����ݒ� -----------------------------------------------#

#use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
#use lib qw(/home/httpd/WebDB);
#use lib qw(../../common);
use lib qw(/home/vhosts/JKZ/extlib/common);
use lib qw(/home/vhosts/JKZ);
use MyClass::UsrWebDB;
use Goku::SiteSettings;
use Goku::Area;
use Goku::Output qw(ShowMsg DumpAndExit);
use Goku::StrConv qw(ConvSJIS ReplaceFieldValue
					 ReplaceMailSubject 
					 ReplaceAdMailContents);

my ($db, $sth, $row, $rec);

my $send;
my $sql;

my $cgi = CGI->new();
my %cookie = $cgi->cookie(-name => 'form_cookie');
my $admailno = $cgi->param('admailno');

my @URL=("/app.mpl", '�߂�');

#�{�����̍L��ID��T��
sub GetAddIdInArray{
	my ($body) = @_;
	my @ret = ();
	while ($body =~ /$KEY_ADID/i){
		push @ret, $1;
		$body = $'; #'
	}
	return @ret;
}

#���O�̂Ƃ���
sub uniq {
   my %seen;
   grep !$seen{$_}++, @_
}

#############################
# �f�[�^�x�[�X�ڑ�
#############################
$db= MyClass::UsrWebDB::connect();
$db->do('set names sjis');
#############################
# ������̎擾
#############################
#$sth=$db->prepare("
# select id_no from member left join error_mail on
# member.mailaddr = error_mail.error_mailaddr
# $cookie{'sql_where'};");
$sth=$db->prepare("select owid from 1MP.tMemberM  $cookie{'sql_where'};");
$row=$sth->execute;

if(!defined($row) || $row==0){
	ShowInfo('���[�����M�\�ȉ�����擾�ł��܂���');
	$sth->finish;
	$db->disconnect;
	undef($db);
	exit;
}
$sth->finish;

my ($saveclient, $savesubd, $savecontd, $savesubj, $savecontj, $savesube, $saveconte, $savesubo, $saveconto, $savecond, $savewhr);

$saveclient = ReplaceFieldValue($cookie{'client'});
$savesubd   = ReplaceFieldValue($cookie{'subjectd'});
$savecontd  = ReplaceFieldValue($cookie{'contentsd'});
$savesubj   = ReplaceFieldValue($cookie{'subjectj'});
$savecontj  = ReplaceFieldValue($cookie{'contentsj'});
$savesube   = ReplaceFieldValue($cookie{'subjecte'});
$saveconte  = ReplaceFieldValue($cookie{'contentse'});
$savesubo   = ReplaceFieldValue($cookie{'subjecto'});
$saveconto  = ReplaceFieldValue($cookie{'contentso'});
$savecond   = ReplaceFieldValue($cookie{'msg_where'});
$savewhr    = ReplaceFieldValue($cookie{'sql_where'});

$sql = 'REPLACE INTO 1MP.tAdmail
 (admailno, fromaddress, senddate, client, sendd, sendj, sende, sendo, subjectd, subjectj, subjecte, subjecto, 
 contentsd, contentsj, contentse, contentso, `condition`, sqlcond ) 
 VALUES (?,?,NOW(),?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'; 
# VALUES ($admailno, $cookie{'from'}, NOW(), $saveclient, $cookie{'sendmemd'}, $cookie{'sendmemj'}, $cookie{'sendmeme'}, $cookie{'sendmemo'}, $savesubd, $savesubj, $savesube, $savesubo, $savecond, $savewhr);";

#$sql = "
# insert into admail (admailno, fromaddress, senddate, client,
# sendd, sendj, sende, sendo,
# subjectd, subjectj, subjecte, subjecto,
# contentsd, contentsj, contentse, contentso,
# condition, sqlcond )
# values ($admailno, '$cookie{'from'}', now(), '$saveclient',
# $cookie{'sendmemd'}, $cookie{'sendmemj'}, $cookie{'sendmeme'},
# $cookie{'sendmemo'},
# '$savesubd', '$savesubj', '$savesube', '$savesubo',
# '$savecontd', '$savecontj', '$saveconte', '$saveconto',
# '$savecond', '$savewhr');";

#############################
# ���̍X�V
#############################
my @CARR_DEFINE = (
	{'disc' => '���̑�', 'id' => 0, 'sub' => 'subjecto', 'body' => 'contentso',
		'cnt' => 'sendmemo' },
	{'disc' => 'DoCoMo', 'id' => 1, 'sub' => 'subjectd', 'body' => 'contentsd',
		'cnt' => 'sendmemd' },
	{'disc' => 'Vodafone', 'id' => 2, 'sub' => 'subjectj', 'body' => 'contentsj',
		'cnt' => 'sendmemj' },
	{'disc' => 'EZweb', 'id' => 3, 'sub' => 'subjecte', 'body' => 'contentse',
		'cnt' => 'sendmeme' });

$send=0;
#���M�f�[�^�[������e�[�u����
my $admanage_table = "";
eval{
	$db->do("set autocommit=0") || die "�g�����U�N�V�����J�n���s\n";
	$db->do("begin") || die "�g�����U�N�V�����J�n���s\n";
	$db->do($sql, undef,
	 $admailno, $cookie{'from'}, $saveclient, $cookie{'sendmemd'}, $cookie{'sendmemj'}, $cookie{'sendmeme'}, $cookie{'sendmemo'}, $savesubd, $savesubj, $savesube, $savesubo, $savecontd, $savecontj, $saveconte, $saveconto,$savecond, $savewhr
	 )
	  || die "�L�����[���ǉ����s\n";

	#�L�����A�̐��������[�v
	my @all_adid = ();
	foreach  my $c_ref (@CARR_DEFINE){

		next if(0 == $cookie{"$c_ref->{'cnt'}"});
		
		my @tmp_adid = ();
		@tmp_adid = GetAddIdInArray($cookie{"$c_ref->{'body'}"});
		#�z����}�[�W���āA�S�L���R�[�h��߂炦�Ă���
		@all_adid = (@all_adid, @tmp_adid);
		foreach my $ad (@tmp_adid){
			#1���[��������̍L��URL�̐������AINSERT����
			$db->do("
 insert into 1MP.tAdsetmail(admailno, carrier, adid)
 values($admailno, $c_ref->{'id'}, $ad);") || die "�L��ID���[���f�ڊǗ��X�V���s\n";
		}#end of adid foreach
		#�u������������̓K�p
		my $send_body = ReplaceAdMailContents($admailno,
											 $cookie{"$c_ref->{'body'}"},
											 $c_ref->{'id'});
		my $send_subject = ReplaceMailSubject($cookie{"$c_ref->{'sub'}"},
											 $c_ref->{'id'});
		my $send_carr = 2 ** $c_ref->{'id'};
		
		#�{���A�����C���T�[�g
		$db->do("
 insert into 1MP.tAdcontents(admailno, carrier, subject, contents)
 values($admailno, $send_carr, '$send_subject',
 '$send_body')") || die '�L�����[�����M�ݒ�o�^���s' . "\n";
	}#eod of carrior foreach
	
	#############################
	# �L�����[�����M�ݒ�Ƀf�[�^��ݒ�
	#############################
	#�T�[�o�[�̐������C���T�[�g
	foreach (@MAIL_SERVERS){
		$db->do("
 insert into 1MP.tAdmailsetting(admailno, fromaddress, server, header)
 values($admailno, '$cookie{'from'}', '$_', '')")
		  || die '�L�����[�����M�ݒ�o�^���s' . "\n";
	}

	# �L�����[���Ǘ��e�[�u���̍쐬
	$admanage_table ="1MP.tAdmailmanage" . $admailno;
	$db->do("create table $admanage_table like 1MP.base_admailmanage");
	$send = 1;
	#�L���R�[�h�̏d��������
	@all_adid = uniq @all_adid;
	#���f�[�^�[�̑}��
	foreach (@all_adid){
		#�኱��肠�邪�A���̏����ŗǂ�
		#���́A�L�����A�ɂ���āA�L���R�[�h����������Ȃ������肷��ꍇ
		#�Ȃ��L�����A�ɑ΂��Ă��A�f�[�^�[��o�^���Ă��܂����A��������
		#���[�U�[�ɓ͂����[���̒��g�Ƀ����N���Ȃ��̂ŁA���Ȃ�
#		$db->do("
# insert into $admanage_table (select $admailno, $_, id_no, 1, null, null
# from HP_general.tMemberM left join error_mail on HP_general.tMemberM.mailaddr = HP_management.error_mail.error_mailaddr
# $cookie{'sql_where'});");
		$db->do("
 insert into $admanage_table (select $admailno, $_, owid, 1, null, null
 from 1MP.tMemberM left join 1MP.error_mail on 1MP.tMemberM.mobilemailaddress = 1MP.error_mail.error_mailaddr
 $cookie{'sql_where'});");
	}
	
};

if ($@) {
    # �����ADBI��RaiseError��die������A$@ �ɂ�$DBI::errstr�������Ă��܂��B
	# �o�^���s
    $db->do("rollback");
	$db->do("set autocommit=1");
	if($admanage_table ne ''){
		$db->do("drop table $admanage_table;");
	}
	$db->disconnect;
	undef($db);
	ShowInfo('�L�����[���̓o�^�E���M�Ɏ��s���܂���' . $@);
	exit;
}

$db->do("commit");
$db->do("set autocommit=1");
$db->disconnect;
undef($db);

# ���M�v���Z�X�̎��s
#system("perl /usr/local/src/kensyo-i/common/watchmaillist.pl $Mail_kind_adml $admailno&");
#system("perl /home/httpd/htdocs/common/sendmaillist.pl $Mail_kind_adml $admailno&");
#system("perl /home/ecshop/www/common/sendmaillist.pl 1 $admailno&");
#system("perl /home/vhosts/JKZ/extlib/common/sendmaillist.pl 1 $admailno&");
system("perl /home/vhosts/JKZ/modules/mail/sendmaillist.pl 1 $admailno&");
ShowMsg('�L�����[���o�^','�L�����[���̓o�^�E���M�ɐ������܂���',1,@URL);

sub ShowInfo{
	#�P�ɃG���[��HTML�o�͂��A�E�o���邾��
    print "Content-type: text/html; charset=Shift_JIS\n\n";
    print "<HTML><HEAD>\n";
    print "<TITLE>" . '�L�����[�����M�m�F' . "</TITLE>\n";
    print "</HEAD><BODY>\n";
    print $_[0] . "<BR>\n";
	print "</BODY></HTML>";
}1;
exit;
