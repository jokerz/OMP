#**************************
#
# 会員の画像表示スクリプト
# serveUserImageDB.mpl
# @access    public
# @author    Iwahase Ryo
# @create    2010/06/11
#                         memcachedのnamespaceとしてDATABASE NAME+TABLE NAMEを使用すること
#**************************
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


my $namespace  = $cfg->param('DATABASE_NAME') . 'UserImageData';
my $q          = CGI->new();
## p=product_id i =id s = image size

#***************************************
# @param 会員ID 画像ID サイズ
#
#
#***************************************

my ($owid, $s) = ($q->param('owid'), $q->param('s'));
my $id         = $q->param('i') || 1;
my @thumb      = (undef,'image', 'thumbnail_320', 'thumbnail_200', 'thumbnail_64');
my $col_name   = (defined ($size) ? $thumb[$size] : "thumbnail_64");
my $key        = join (';', (int($owid), $id, $col_name));
my $memcached  = MyClass::UsrWebDB::MemcacheInit();
my $obj        = $memcached->get("$namespace:$key");

if(!$obj) {
	my $dbh = MyClass::UsrWebDB::connect({
                 dbaccount => $cfg->param('DATABASE_USER'),
                 dbpasswd  => $cfg->param('DATABASE_PASSWORD'),
                 dbname    => $cfg->param('DATABASE_NAME'),
              });

    $dbh->do ('set names utf8');

    my $sql                      = sprintf("SELECT mime_type, %s FROM %s.tUserImageF WHERE owid=? AND id=?;", $col_name, $cfg->param('DATABASE_NAME'));
    my ($mime_type, $image_data) = $dbh->selectrow_array ($sql, undef, $owid, $id);
    $dbh->disconnect();

    $obj = {
    mime_type => $mime_type,
    image_data=> $image_data,
    };
	$memcached->add("$namespace:$key", $obj, 3600);
}

print $q->header(-type=>$obj->{mime_type},-Content_Length=>length ($obj->{image_data}));
print $obj->{image_data};

ModPerl::Util::exit();

__END__