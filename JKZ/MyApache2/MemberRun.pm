package MyApache2::MemberRun;
use strict;

use Apache2::RequestRec(); # for $r->content_type
use Apache2::RequestIO(); # for $r->print
use Apache2::Const -compile => ':common';

sub handler {
    my $r = shift;

    my $config = $ENV{'OMP_CONFIG'};
    require MyClass::Config;
    my $cfg = MyClass::Config->new($config);
    use MyClass::JKZ::MemberContents;
    my $myclass = MyClass::JKZ::MemberContents->new($cfg);
    $myclass->run();


    Apache2::Const::OK
}
1;
