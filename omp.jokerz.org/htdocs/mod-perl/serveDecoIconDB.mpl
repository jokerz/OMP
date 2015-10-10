#*********************************************
# @desc      画像表示スクリプト
#            cacheデータをチェックしてcahcheデータが無い場合はDBから画像データを
#            取得して、memcacheにデータを格納
#
# @package   serveDecoIcon.mpl
# @access    public
# @author    Iwahase Ryo
# @create    2009/06/09
# @update    2009/06/18  ｓ属性が１に指定されてる場合は生画像を吐き出す=>ダウンロード時だけに生画像を吐き出す
#                        なのでs=1のときにダウンロードカウント処理を追加
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

my $namespace        = $cfg->param('DATABASE_NAME') . 'DecoIcon';
my $q                = CGI->new();
my ($product_id, $s) = ($q->param('p'), $q->param('s'));
# 画像選択パラメータのs属性が無い場合はサンプル画像を出力
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

## Modified ここでダウンロードのカウントを取る 2009/06/18 BEGIN

#***********************************
# DownloadCounter
#***********************************
=pod
if (1 == $s) {
	require MyClass::JKZMobile;
	require MyClass::JKZDownloadCounter;

	my $agent	= MyClass::JKZMobile->new();
	my $carrier = $agent->getCarrierCode();
	my $CNT		= MyClass::JKZDownloadCounter->new({
						carrier		=> 2 ** $carrier,
						product_id	=> $product_id
					});
	$CNT->insertCounter();
}
## Modified ここでダウンロードのカウントを取る 2009/06/18 END
=cut

ModPerl::Util::exit();

__END__