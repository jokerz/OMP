#!/usr/bin/perl

#******************************************************
# @desc        �L���b�V����S�N���A����
# @package    memcached_flush_all.pl
# @author    Iwahase Ryo
# @create    2009/06/08
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
use MyClass::WebUtil;

## Cache::Memcached::Fast���Ȃ��ꍇ��undef��Ԃ�
eval("require Cache::Memcached::Fast;"); return undef if $@;
my $memcached = Cache::Memcached::Fast->new(
            {
                #servers            => ["192.168.10.30:11211"],
                servers            => ["127.0.0.1:11211"],
                namespace          => 'dOMP:',
                compress_threshold => 10_000,
                compress_ratio     => 0.9,
            }
        );

MyClass::WebUtil::warnMSG_LINE($memcached, __LINE__);
warn "\n $memcached->server_versions \n","flushing cached object\n";

$memcached->flush_all;

exit();
