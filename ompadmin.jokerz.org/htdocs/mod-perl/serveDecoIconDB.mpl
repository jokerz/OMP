#*********************************************
# @desc      �摜�\���X�N���v�g
#            cache�f�[�^���`�F�b�N����cahche�f�[�^�������ꍇ��DB����摜�f�[�^��
#            �擾���āAmemcache�Ƀf�[�^���i�[
#
# @package   serveDecoIcon.mpl
# @create	 2009/06/09
# @update    2010/05/07   ModPerl�EApache���Őݒ肵�����ϐ�����
#                        �ݒ�����擾���āADB�A�N�Z�X����悤�ɕύX
#                         memcached��namespace�Ƃ���DATABASE NAME+TABLE NAME���g�p���邱��
# @version   1.00
# @version   1.20
#*********************************************
use strict;
use vars qw($cfg);

BEGIN {
    my $config = $ENV{'JKZ_WAF_CONFIG'};
    require MyClass::Config;
    $cfg = MyClass::Config->new($config);
}


use CGI::Carp qw(fatalsToBrowser);
use MyClass::WebUtil;
use MyClass::UsrWebDB;

my $namespace        = $cfg->param('DATABASE_NAME') . 'DecoIcon';
my $q                = CGI->new();
my ($product_id, $s) = ($q->param('p'), $q->param('s'));
# �摜�I���p�����[�^��s�����������ꍇ�̓T���v���摜���o��
my $col_name         = (defined($s) && 1 == $s ? 'image' : 'image1');
my $key              = join (';', (int ($product_id), $col_name));
my $memcached        = MyClass::UsrWebDB::MemcacheInit();
my $obj              = $memcached->get("$namespace:$key");

if(!$obj) {
	my $dbh = MyClass::UsrWebDB::connect({
                 dbaccount => $cfg->param('DATABASE_USER'),
                 dbpasswd  => $cfg->param('DATABASE_PASSWORD'),
                 dbname    => $cfg->param('DATABASE_NAME'),
              });

    $dbh->do('set names utf8');

    my $sql                      = sprintf("SELECT mime_type, %s FROM %s.tProductImageM WHERE productm_id=?", $col_name, $cfg->param('DATABASE_NAME'));
    my ($mime_type, $image_data) = $dbh->selectrow_array($sql, undef, $product_id);
    $dbh->disconnect ();

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
	ModPerl::Util::exit ();



__END__

=pod
use CGI::Carp qw(fatalsToBrowser);
use lib qw(/home/vhosts/JKZ_WAF/JKZ);
use MyClass::WebUtil;
use MyClass::UsrWebDB;


my $q = new CGI;

my $product_id = $q->param('p');

my $memcached = MyClass::UsrWebDB::MemcacheInit();

my $key = $product_id;
my $obj = $memcached->get ("JKZ_WAFDecoIcon:$key");
if(!$obj) {
	my $dbh = MyClass::UsrWebDB::connect();
	$dbh->do ('set names utf8');
	$dbh->do ('use JKZ_WAF');
	my ($mime_type, $image_data) = $dbh->selectrow_array (
					"SELECT mime_type, image FROM JKZ_WAF.tProductDecoIcon WHERE productm_id=?",
					undef,
					$product_id
					);
	$dbh->disconnect ();

	$obj = {
		mime_type => $mime_type,
		image_data=> $image_data,
	};
	$memcached->add("JKZ_WAFDecoIcon:$key", $obj, 3600);
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
	ModPerl::Util::exit ();
}
=cut