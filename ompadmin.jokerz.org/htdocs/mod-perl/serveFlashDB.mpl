#**************************
# @desc		Flash表示スクリプト
# @package	serveFlashDB.mpl
# @access	public
# @author	Iwahase Ryo
# @create	2009/05/26
# @update
# @version	1.00
#**************************
use strict;
use CGI::Carp qw(fatalsToBrowser);
use lib qw(/home/vhosts/JKZ);
use MyClass::WebUtil;
use MyClass::UsrWebDB;

my $q = CGI->new();


my ($product_id, $id) = ( $q->param('p'), $q->param('i'));

my $dbh = JKZ::UsrWebDB::connect();
$dbh->do ('set names utf8');
$dbh->do ('use MYSDK');

my ($mime_type, $swfdata) = $dbh->selectrow_array (
				"SELECT mime_type, swf FROM 1MP.tProductSwf WHERE productm_id=? AND id=?",
				undef,
				$product_id, $id
				);

$dbh->disconnect ();


print $q->header(
	-type=>$mime_type,
	-Content_Length=>length($swfdata),
);

print $swfdata;

ModPerl::Util::exit();



sub Error {
my $msg = shift;
my $q = new CGI;
	print $q->header (),
			$q->start_html ("Error"),
			$q->p ($q->escapeHTML ($msg)),
			$q->end_html ();
	ModPerl::Util::exit ();
}
