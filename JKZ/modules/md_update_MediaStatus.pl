#!/usr/bin/perl

#******************************************************
# @desc		ポイント広告有効期限設定による期限切れにする
# @package	md_update_MediaStatus
# @author	Iwahase Ryo
# @create	2010/03/01
# @version	
#******************************************************

use strict;
use vars qw($include_path);

BEGIN {
	## クラスのインクルードパスを取得するための処理
	require Cwd;
	my $pwd = Cwd::getcwd();
	($include_path = $pwd) =~ s!/modules!!;

	unshift @INC, $include_path;
}

use MyClass::UsrWebDB;

#*******************************
# cronで1日一回0:00に実行させる。
# ad_period_flagが2で有効期限が本日より前のものはstatus_flag=4とする。
#*******************************

my $sql = "UPDATE tMediaM SET status_flag=4 WHERE ad_period_flag=2 AND DATE(expire_date) < DATE(now())";

my $dbh = MyClass::UsrWebDB::connect();
$dbh->do('USE 1MP');
$dbh->do('set names sjis');
my $rc = $dbh->do($sql);
$dbh->disconnect();


if ('0E0' eq $rc) {
    print " FAIL Update Media status \n";
}


exit();
