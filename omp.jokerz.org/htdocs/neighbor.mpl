#******************************************************
# Controller
# @desc		近所さんのController
# @access	public
# @author	Iwahase Ryo
# @create	2010/01/18
# @update	2010/03/26 vhostsにてPerlSwitches -I設定により、@INCをいじらない
# @update   2010/06/10 呼び出しクラス変更
#******************************************************
use strict;
use vars qw($cfg);

BEGIN {

    my $config = $ENV{'OMP_CONFIG'};
    require MyClass::Config;
    $cfg = MyClass::Config->new($config);

}
{
    eval {
        use MyClass::JKZ::Neighbor;
        my $myclass = MyClass::JKZ::Neighbor->new($cfg);
        $myclass->run();
    };

    if($@) {
        print "Content-Type: text/html\r\n\r\n", "Error: $@";
    }

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}
