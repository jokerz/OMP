#******************************************************
# Controller cart.mpl
# @desc		Controller 商品購入・ポイント交換など
# @access	public
# @author	Iwahase Ryo
# @create	2010/01/28
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
        use MyClass::JKZ::Cart;
        my $myclass = MyClass::JKZ::Cart->new($cfg);
        $myclass->run();
    };

    if($@) {
        print "Content-Type: text/html\r\n\r\n", "Error: $@";
    }

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}
