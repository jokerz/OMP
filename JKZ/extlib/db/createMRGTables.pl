#!/usr/bin/perl -I /home/vhostsuser/KKFLA/JKZ

#******************************************************
# @desc     マージテーブルの生成
#           1年で12テーブルと仮想テーブル1つ

#			--------------------------------
#						ここから下はまだ対応していないテーブル

#
#		perl createMRGTables.pl 2008
#
# @ param	int	年 ない場合は現在の年に1年足した年で生成
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
# 生成するテーブルの構造配列
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
 `in_date` DATE NOT NULL COMMENT '日付 yyyy-mm',
 `in_time` char(2) COMMENT '時間 HH 0-23',
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
## 実行したSQL文
my @msg;
## 次年度のテーブルを生成する
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
# HP_logdateにスイッチ
#*************************
$dbh->do('USE MYSDK');
$dbh->do('SET NAMES SJIS');

#*************************
# 12ヶ月のテーブルを作成 1グループごとに実行
#*************************
foreach my $table (@{$tableConditions}) {
	my (@tablenames, @tablestocreate);
	#*************************
	# 12ヶ月分のCREAT文を生成
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
	# マージを作成
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
	# ここで@tablestocreate配列のループ処理で
	# DBのcreateSQLを実行 
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
		# マージテーブルなので、失敗したら終了して脱出。次のグループを実行
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

