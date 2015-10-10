#*********************************************
# @desc      �f�R���e���v���[�g�X�N���v�g
# @package   serveFlashDB.mpl
# @access    public
# @author    Iwahase Ryo
# @create    2009/05/28
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
use MyClass::JKZMobile;
use constant DECO_PUBLISHDIR => $cfg->param('SERIALIZEDOJB_DIR') . '/contents/decotmplt/';

my $agent             = MyClass::JKZMobile->new();
my $carrier           = $agent->getCarrierCode();
my $q                 = CGI->new();
my ($product_id, $id) = ( $q->param('p'), $q->param('i'));
my $published         = DECO_PUBLISHDIR . sprintf("%s_%s", $product_id, $id);
my $decoobj;
my $decodata;
my $mime_type;
## ���f�[�^
my ($dmt, $hmt, $khm);
my ($mime_type_docomo, $mime_type_softbank, $mime_type_au);
my ($file_size_docomo, $file_size_softbank, $file_size_au);

## Find Data From SerializedObject OR Fetch From Database
eval {
    $decoobj    = MyClass::WebUtil::publishObj( { file=>$published } );
    $decodata   = $decoobj->[$carrier - 1]->{decodata};
    $mime_type  = $decoobj->[$carrier - 1]->{mime_type};
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

    my $sql = sprintf("SELECT
 dmt, hmt, khm,
 mime_type_docomo, mime_type_softbank, mime_type_au,
 file_size_docomo, file_size_softbank, file_size_au
 FROM %s.tProductDecoTmplt
 WHERE productm_id=?", $cfg->param('DATABASE_NAME'));

    ($dmt, $hmt, $khm, $mime_type_docomo, $mime_type_softbank, $mime_type_au, $file_size_docomo, $file_size_softbank, $file_size_au) = $dbh->selectrow_array($sql, undef, $product_id);
    $dbh->disconnect();

    my $tmpobj = [
                    {
                        decodata    => $dmt,
                        mime_type   => $mime_type_docomo,
                        file_size   => $file_size_docomo,
                    },
                    {
                        decodata    => $hmt,
                        mime_type   => $mime_type_softbank,
                        file_size   => $file_size_softbank,
                    },
                    {
                        decodata    => $khm,
                        mime_type   => $mime_type_au,
                        file_size   => $file_size_au,
                    },
                 ];

    MyClass::WebUtil::publishObj({
        file => $published,
        obj  => $tmpobj
    });

    $decodata  = $tmpobj->[$carrier - 1]->{decodata};
    $mime_type = $tmpobj->[$carrier - 1]->{mime_type};
}

print $q->header(
        -type=>$mime_type,
        -Content_Length=>length($decodata),
      );

print $decodata;

## Modified �����Ń_�E�����[�h�̃J�E���g����� 2009/06/07 BEGIN
#***********************************
# DownloadCounter
#***********************************
=pod 2010/02/12
use MyClass::JKZDownloadCounter;
my $CNT = MyClass::JKZDownloadCounter->new({
			carrier		=> 2 ** $carrier,
			product_id	=> $product_id
		});
$CNT->insertCounter();
## Modified �����Ń_�E�����[�h�̃J�E���g����� 2009/06/07 END
=cut

ModPerl::Util::exit();

__END__
