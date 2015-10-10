#*********************************************
#
# 画像表示スクリプト
# serveImageDB.mpl
# @update 2008/09/26
# @update 2008/09/30 動作修正
# @update 2009/06/12 画像DB変更と定義変更
# @update    2010/05/07   ModPerl・Apache側で設定した環境変数から
#                        設定情報を取得して、DBアクセスするように変更
#                         memcachedのnamespaceとしてDATABASE NAME+TABLE NAMEを使用すること
# @version   1.00
# @version   1.20
#*********************************************

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


my $namespace             = $cfg->param('DATABASE_NAME') . 'ImageData';
my $q                     = CGI->new();
my ($product_id, $s, $id) = ( $q->param('p'), $q->param('s'), $q->param('i') );
$s = 1 if !$q->param('s') || $s eq '';
$id ||= 1;

my @thumb     = (undef, 'image', 'image1', 'image2');
my $col_name  = $thumb[$s];
my $key = join (';', (int($product_id), $id, $s));
my $memcached = MyClass::UsrWebDB::MemcacheInit();
my $obj       = $memcached->get("$namespace:$key");


if(!$obj) {
	my $dbh = MyClass::UsrWebDB::connect({
                 dbaccount => $cfg->param('DATABASE_USER'),
                 dbpasswd  => $cfg->param('DATABASE_PASSWORD'),
                 dbname    => $cfg->param('DATABASE_NAME'),
              });

    $dbh->do ('set names utf8');

    my $sql                      = sprintf("SELECT mime_type, %s FROM %s.tProductImageM WHERE productm_id=? AND id=?;", $col_name, $cfg->param('DATABASE_NAME'));
    my ($mime_type, $image_data) = $dbh->selectrow_array ($sql, undef, $product_id, $id);
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


sub Error {
    my $msg = shift;
    my $q = new CGI;
    print $q->header (),
          $q->start_html ("Error"),
          $q->p ($q->escapeHTML ($msg)),
          $q->end_html ();
	ModPerl::Util::exit();
}

__END__