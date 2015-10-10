#********************************************
# @desc        バナー画像専用
# @package    serveImageBanner
# @access    public
# @author    磐長谷　亮
# @create    2010/09/01
# @version    1.00
#********************************************
use strict;
use vars qw($cfg);

BEGIN {
    my $config = $ENV{'OMP_CONFIG'};
    require MyClass::Config;
    $cfg = MyClass::Config->new($config);
}

use CGI::Carp qw(fatalsToBrowser);
use MyClass::WebUtil;
use MyClass::UsrWebDB;

my $namespace = $cfg->param('DATABASE_NAME') . 'BannerImageData';
my $q         = new CGI;

if (defined ($q->param('rt'))) {
    my ($bannerm_id, $bannerdatam_id, $bannerdataf_id) = split(/::/, $q->param('rt'));
    my $memcached_key = $q->param('rt');
    my $col_name = defined $q->param('b') ? 'resized_image' : 'image';

    my $memcached = MyClass::UsrWebDB::MemcacheInit();
    my $obj       = $memcached->get("$namespace:$memcached_key");

   my $dbh = MyClass::UsrWebDB::connect({
                 dbaccount => $cfg->param('DATABASE_USER'),
                 dbpasswd  => $cfg->param('DATABASE_PASSWORD'),
                 dbname    => $cfg->param('DATABASE_NAME'),
             });

    if(!$obj) {
        my $sql = sprintf("SELECT mime_type, %s FROM %s.tBannerImageF WHERE bannerm_id=? AND bannerdatam_id=? AND id=?;", $col_name, $cfg->param('DATABASE_NAME'));
        my ($mime_type, $resized_image) = $dbh->selectrow_array($sql, undef, $bannerm_id, $bannerdatam_id, $bannerdataf_id);
        $obj = {
            mime_type     => $mime_type,
            resized_image => $resized_image,
        };
        $memcached->add("$namespace:$memcached_key", $obj, 120);
    }

    my $tBannerCountF = sprintf("%s.tBannerCountF_%s", $cfg->param('DATABASE_NAME'), MyClass::WebUtil::GetTime("5"));

=pod
my $sql = sprintf("
 UPDATE %s SET impression=impression+1,last_impression=NOW()
 WHERE bannerm_id='$rowref->[$rand]->{id1}'
 AND bannerdatam_id='$rowref->[$rand]->{id2}' 
 AND bannerdataf_id='$rowref->[$rand]->{id}' 
 AND clickdate=CURDATE()", 
=cut
    my $sql = sprintf("
 UPDATE %s SET impression=impression+1,last_impression=NOW()
 WHERE  bannerm_id=? AND bannerdatam_id=? AND bannerdataf_id=?
 AND clickdate=CURDATE()", $tBannerCountF);
    my $sth = $dbh->prepare($sql);
    if ($sth->execute($bannerm_id, $bannerdatam_id, $bannerdataf_id) < 1) {
        $dbh->do("
 INSERT INTO $tBannerCountF (bannerm_id, bannerdatam_id, bannerdataf_id, clickdate, impression, last_impression)
 VALUES ('$bannerm_id', '$bannerdatam_id', '$bannerdataf_id', CURDATE(), 1, NOW())
         ");
    }

    $dbh->disconnect();

    print $q->header(-type=>$obj->{mime_type},-Content_Length=>length ($obj->{resized_image}));
    print $obj->{resized_image};
}


ModPerl::Util::exit();