#******************************************************
# Controller
# @desc		Controller 会員登録用
# @access	public
# @author	Iwahase Ryo
# @create	2010/01/08
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
        use MyClass::JKZRegistration;
        my $myclass = MyClass::JKZRegistration->new($cfg);
        $myclass->run();
    };

    if($@) {
        print "Content-Type: text/html\r\n\r\n", "Error: $@";
    }

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}
