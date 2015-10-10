#*********************************************
# @desc
# 
#
#*********************************************

# $Id: push_uid.mpl,v 1.2 2010/12/10 19:27:28 ryo Exp $


use vars qw($cfg);

BEGIN {
    my $config = $ENV{'OMP_CONFIG'};
    require MyClass::Config;
    $cfg = MyClass::Config->new($config);
}



use CGI;
use CGI::Carp qw(fatalsToBrowser);
use LWP;
use HTTP::Request::Common;
use URI::Escape;

use MyClass::WebUtil;
use MyClass::UsrWebDB;

use Data::Dumper;

# uidのpush先
use constant PUSHTO => 'http://www.avidimer.com';


sub getDCMGUID {
my $guid =
        ( exists($ENV{'HTTP_X_DCMGUID'}) )    ? $ENV{'HTTP_X_DCMGUID'}    :
        ( exists($ENV{'HTTP_X_JPHONE_UID'}) ) ? $ENV{'HTTP_X_JPHONE_UID'} :
        ( exists($ENV{'HTTP_X_UP_SUBNO'}) )   ? $ENV{'HTTP_X_UP_SUBNO'}   :
                                                    undef                 ;

    return ($guid);
}

my $remote_addr = $ENV{'REMOTE_ADDR'};
my $remote_host = $ENV{'REMOTE_HOST'};

my $ua  = LWP::UserAgent->new;
$ua->agent($ENV{'HTTP_USER_AGENT'});

warn "\n\n ----------\n[ guid :  ", getDCMGUID, " ] [ ua : ", $ENV{'HTTP_USER_AGENT'}, " ] [ remote addr / remote host : ", $remote_addr , ' / ', $remote_host, " ]\n";

my $req = HTTP::Request->new( GET => PUSHTO );

my $res = $ua->request($req);

# 成功なら画像を表示
if ($res->is_success) {
#$res->is_successの他にis_redirect、is_info、is_errorがある。
# $res->content $ref->message

    my $namespace = $cfg->param('DATABASE_NAME') . 'SiteImageData';
    my $q         = CGI->new();
    my $id        = $q->param('i');
    my $key       = $id;
    my $memcached = MyClass::UsrWebDB::MemcacheInit();
    my $obj       = $memcached->get("$namespace:$key");

    if(!$obj) {
        my $dbh = MyClass::UsrWebDB::connect({
                     dbaccount => $cfg->param('DATABASE_USER'),
                     dbpasswd  => $cfg->param('DATABASE_PASSWORD'),
                     dbname    => $cfg->param('DATABASE_NAME'),
                  });

        $dbh->do('set names utf8');

        my $sql                      = sprintf("SELECT mime_type, image FROM %s.tSiteImageM WHERE id=?;", $cfg->param('DATABASE_NAME'));
        my ($mime_type, $image_data) = $dbh->selectrow_array($sql, undef, $id);
        $dbh->disconnect ();

        $obj = {
            mime_type => $mime_type,
            image_data=> $image_data,
        };
        $memcached->add("$namespace:$key", $obj, 3600);
    }

    print $q->header(-type=>$obj->{mime_type},-Content_Length=>length ($obj->{image_data}));
    print $obj->{image_data};
}
else {
	print $res->status_line, "\n";
}

ModPerl::Util::exit ();

__END__