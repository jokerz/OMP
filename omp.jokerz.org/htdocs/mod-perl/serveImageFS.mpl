#********************************************
# @desc		ローカルディレクトリの画像を出力
# @desc		ディレクトリの読み込みが遅い
# @package	serveImageFS
# @access	public
# @author	磐長谷　亮
# @create	2008/06/06
# @version	1.00
# @version	1.10
# @update	2008/09/26 画像をMemcached仕様実装
#********************************************

use strict;
use lib qw(/home/vhosts/JKZ_WAF/JKZ);
use MyClass::UsrWebDB;


my $q = CGI->new ();

my $image     = $q->param('f') if defined $q->param('f');
my $image_dir = '/home/vhosts/1mp.1mp.jp/htdocs/images/';
my $data      = $image_dir . $image;

my $mime_type;

if ($image =~ /jpg$/) {
	$mime_type = 'image/jpeg';
}
elsif ($image =~ /gif$/) {
	$mime_type = "image/gif";
}
elsif ($image =~ /png$/) {
	$mime_type = "image/png";
}

use MIME::Base64 qw(encode_base64 decode_base64);

## キャッシュサーバーは192.168.10.30に変更
my $memcached = MyClass::UsrWebDB::MemcacheInit();
my $obj       = $memcached->get("ImageJKZ_WAF:$image");

if (!$obj) {
	local $/;
	local *IMG;
	open (IMG, $data);
	$obj = encode_base64 (<IMG>);
	#binmode (IMG);
	#binmode STDOUT;
	close (IMG);
	$memcached->add("ImageJKZ_WAF:$image", $obj, 120);
}

my $cached_image = decode_base64 ($obj);
print $q->header (-type => $mime_type);
print $cached_image;

ModPerl::Util::exit();
