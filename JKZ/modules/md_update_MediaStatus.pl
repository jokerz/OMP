#!/usr/bin/perl

#******************************************************
# @desc		�|�C���g�L���L�������ݒ�ɂ������؂�ɂ���
# @package	md_update_MediaStatus
# @author	Iwahase Ryo
# @create	2010/03/01
# @version	
#******************************************************

use strict;
use vars qw($include_path);

BEGIN {
	## �N���X�̃C���N���[�h�p�X���擾���邽�߂̏���
	require Cwd;
	my $pwd = Cwd::getcwd();
	($include_path = $pwd) =~ s!/modules!!;

	unshift @INC, $include_path;
}

use MyClass::UsrWebDB;

#*******************************
# cron��1�����0:00�Ɏ��s������B
# ad_period_flag��2�ŗL���������{�����O�̂��̂�status_flag=4�Ƃ���B
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
