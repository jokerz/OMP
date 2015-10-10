#******************************************************
# Controller
# @desc		サイトのController
# @access	public
# @author	Iwahase Ryo
# @create	2010/01/06
# @update	2010/03/26 vhostsにてPerlSwitches -I設定により、@INCをいじらない
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
        use MyClass::JKZWebPage;
        my $myclass = MyClass::JKZWebPage->new($cfg);
        $myclass->run();
    };

    if($@) {
        print "Content-Type: text/html\r\n\r\n", "Error: $@";
    }

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}
