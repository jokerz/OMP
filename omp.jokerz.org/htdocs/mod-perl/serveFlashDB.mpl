#*********************************************
# @desc      Flash�\���X�N���v�g
#            �����DB����f�[�^���擾���āA�V���A���C�Y�I�u�W�F�N�g�𐶐�
#            �I�u�W�F�N�g������ꍇ�̓I�u�W�F�N�g����f�[�^���擾
# @packag    serveFlashDB.mpl
# @access    public
# @author    Iwahase Ryo
# @create    2009/05/26
# @update    2009/06/07 �_�E�����[�h�J�E���g������ǉ�
# @update    2010/05/07 1.ModPerl�EApache���Őݒ肵�����ϐ�����
#                        �ݒ�����擾���āADB�A�N�Z�X����悤�ɕύX
#                       2.memcached��namespace�Ƃ���DATABASE NAME+TABLE NAME���g�p���邱��
#                       3.Flash�R���e���c�ƃf�R���e���v���[�g�̃f�[�^�V���A���C�Y�f�B���N�g���̐ݒ�l
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
use constant SWF_PUBLISHDIR => $cfg->param('SERIALIZEDOJB_DIR') . '/contents/swf/';

my $q                 = CGI->new();
## id of FlashData
my ($product_id, $id) = ( $q->param('p'), $q->param('i'));
my $published         = SWF_PUBLISHDIR . sprintf("%s_%s", $product_id, $id);
my $swfobj;
my $swfdata;
my $mime_type;

## Find Data From SerializedObject OR Fetch From Database
eval {
    $swfobj     = MyClass::WebUtil::publishObj( { file=>$published } );
    $swfdata    = $swfobj->{swfdata};
    $mime_type  = $swfobj->{mime_type};
};

## Can Not Find SerializedObjectFile, Connect to Database to Fetch Data
if ($@) {
    require MyClass::UsrWebDB;
    my $dbh = MyClass::UsrWebDB::connect({
                 dbaccount => $cfg->param('DATABASE_USER'),
                 dbpasswd  => $cfg->param('DATABASE_PASSWORD'),
                 dbname    => $cfg->param('DATABASE_NAME'),
              });

	$dbh->do('set names utf8');

    my $sql                = sprintf("SELECT swf, mime_type FROM %s.tProductSwf WHERE productm_id=? AND id=?", $cfg->param('DATABASE_NAME'));
    ($swfdata, $mime_type) = $dbh->selectrow_array ($sql, undef, $product_id, $id);
	$dbh->disconnect ();

    MyClass::WebUtil::publishObj({
        file => $published,
        obj  => {
            swfdata   => $swfdata,
            mime_type => $mime_type
        }
    });
}


print $q->header(
            -type=>$mime_type,
            -Content_Length=>length($swfdata),
      );

print $swfdata;

## Modified �����Ń_�E�����[�h�̃J�E���g����� 2009/06/07 BEGIN
#***********************************
# DownloadCounter
#***********************************
=pod 2010/02/12 
use MyClass::JKZMobile;
use JKZ::JKZDownloadCounter;
my $agent	= MyClass::JKZMobile->new();
my $carrier = $agent->getCarrierCode();
my $CNT		= MyClass::JKZDownloadCounter->new({
	carrier		=> 2 ** $carrier,
	product_id	=> $product_id
});
$CNT->insertCounter();
## Modified �����Ń_�E�����[�h�̃J�E���g����� 2009/06/07 END
=cut

ModPerl::Util::exit();

__END__