#******************************************************
# Controller
# @desc		管理画面Controller
# @access	public
# @author	Iwahase Ryo
# @create	2010/01/13
# @update	
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
        use CGI;
        my $q          = CGI->new();
        my $base_class = 'MyClass::JKZApp';
        my $class      = defined( $q->param('app') ) ? sprintf("%s::%s", $base_class, $q->param('app')) : $base_class;

        eval "require $class";

        my $myApp = $class->new($cfg);
        $myApp->run();
    };

    if($@) {
        print "Content-Type: text/html\r\n\r\n", "Error: $@";
    }

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}
