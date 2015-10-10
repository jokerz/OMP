#!/usr/bin/perl -I /home/vhostsuser/KKFLA/JKZ

#******************************************************
# @desc     �}�[�W�e�[�u���̐���
#           1�N��12�e�[�u���Ɖ��z�e�[�u��1��

#			--------------------------------
#						�������牺�͂܂��Ή����Ă��Ȃ��e�[�u��

#
#		perl createMRGTables.pl 2008
#
# @ param	int	�N �Ȃ��ꍇ�͌��݂̔N��1�N�������N�Ő���
#
# @package  createMRGTables.pl
# @access   public
# @author   Iwahase Ryo
# @create   2008/12/15
# @update	
# @version  1.00
#******************************************************

use strict;
use WebUtil;
use JKZ::UsrWebDB;


#*************************
# ��������e�[�u���̍\���z��
# $tableConditions->[$integre]-{table}
# $tableConditions->[$integre]-{columns}
#*************************
my $tableConditions = [
	{
		table	=> 'tAccessLogF_',
		columns => "
 (
 `id` int(11) unsigned NOT NULL auto_increment,
 `in_datetime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
 `acd` char(6) NOT NULL default '',
 `carrier` tinyint(3) unsigned NOT NULL,
 `guid` char(30),
 `ip` char(15) NOT NULL default '',
 `host` char(100) default NULL,
 `useragent` char(100) NOT NULL default '',
 `referer` char(100) default NULL,
 PRIMARY KEY  (`id`),
 KEY `in_datetime` (`in_datetime`),
 KEY `acd` (`acd`)
 )
",
	},
	{
		table	=> 'tPageViewLogF_',
		columns => " 
 (
 `in_date` DATE NOT NULL COMMENT '���t yyyy-mm',
 `in_time` char(2) COMMENT '���� HH 0-23',
 `carrier` tinyint(1) unsigned NOT NULL,
 `tmplt_id` int(10) unsigned NOT NULL,
 `pvcount` int(10) unsigned default '0',
 `last_pv` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
 PRIMARY KEY  (`in_date`,`in_time`, `carrier`, `tmplt_id`)
 )
",
	},
];

my @errmsg;
## ���s����SQL��
my @msg;
## ���N�x�̃e�[�u���𐶐�����
#my $baseyear = ($ARGV[0] =~ /\d\d\d\d/) ? chomp ($ARGV[0]) : WebUtil::GetTime (9);
my $baseyear = $ARGV[0] ? $ARGV[0] : WebUtil::GetTime (9);
$baseyear += 1;

my %engine = (
	isam => ' ENGINE=MyISAM',
	mrg  => ' ENGINE=MRG_MyISAM',
);
my $charset = ' DEFAULT CHARSET=sjis';

my $dbh = JKZ::UsrWebDB::connect();
#$dbh->trace(2, '/home/vhosts/MYSDK/JKZ/tmp/aDBITrace.log');
#*************************
# HP_logdate�ɃX�C�b�`
#*************************
$dbh->do('USE MYSDK');
$dbh->do('SET NAMES SJIS');

#*************************
# 12�����̃e�[�u�����쐬 1�O���[�v���ƂɎ��s
#*************************
foreach my $table (@{$tableConditions}) {
	my (@tablenames, @tablestocreate);
	#*************************
	# 12��������CREAT���𐶐�
	#*************************
	@tablestocreate = map {
		'CREATE TABLE IF NOT EXISTS ' . $table->{table} . $baseyear . sprintf("%02d", $_+1)
		. $table->{columns}
		. $engine{isam}
		. $charset
		. ";"
	} (0..11);

	@tablenames = map { $table->{table} . $baseyear . sprintf("%02d", $_+1) } (0..11);

	#*************************
	# �}�[�W���쐬
	#*************************
	my $mrgsql = 'CREATE TABLE IF NOT EXISTS ' . $table->{table} . $baseyear
		   . $table->{columns}
		   . $engine{mrg}
		   . $charset
		   . ' INSERT_METHOD=LAST UNION=('
		   . sprintf "%s", join (',', @tablenames)
		   . ");"
		   ;
	push (@tablestocreate, $mrgsql);

	#*******************************
	# ������@tablestocreate�z��̃��[�v������
	# DB��createSQL�����s 
	#*******************************

	eval {
		map { $dbh->do($_); } @tablestocreate;
	};
	push(@errmsg, $@) if $@;
=pod
	foreach my $sql (@tablestocreate) {
		if (!$dbh->do($sql)) {
			push (@errmsg ,'SQL Failed : ' . $sql . "\n");
			last;
		}
		push (@msg ,'SQL Executed : ' . $sql . "\n");
=cut
=pod
		my $rc = $dbh->do($sql);
		# �}�[�W�e�[�u���Ȃ̂ŁA���s������I�����ĒE�o�B���̃O���[�v�����s
		push (@errmsg ,'SQL Failed : ' . $sql . "\n") && last if $rc eq '0E0';
		push (@msg ,'SQL Executed : ' . $sql . "\n");
	}
=cut
}

$dbh->disconnect();

print $#msg, "SQL SUCCESS \n";
print @msg;

print $#errmsg, "SQL FAIL \n";
print @errmsg;

=pod
if (1 < $errmsg[-1]) {
	print @tablestocreate,"\n\n","ALL tables success\n\n";
}
else { print @errmsg; }
=cut

exit();

