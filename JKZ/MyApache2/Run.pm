package MyApache2::Run;
use strict;

use Apache2::RequestRec(); # for $r->content_type
use Apache2::RequestIO(); # for $r->print
use Apache2::Const -compile => ':common';

sub handler {
    my $r = shift;

    my $config = $ENV{'OMP_CONFIG'};
    require MyClass::Config;
    my $cfg = MyClass::Config->new($config);
    use MyClass::JKZWebPage;
    my $myclass = MyClass::JKZWebPage->new($cfg);
    $myclass->run();


    Apache2::Const::OK
}
1;
