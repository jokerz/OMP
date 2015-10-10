#*********************************************
#
# 画像表示スクリプト
# serveSiteImageDB.mpl
# @update 2008/09/26
# @update 2008/09/30 動作修正
# @update 2009/06/12 画像DB変更と定義変更
# @update    2010/05/07   ModPerl・Apache側で設定した環境変数から
#                        設定情報を取得して、DBアクセスするように変更
#                         memcachedのnamespaceとしてDATABASE NAME+TABLE NAMEを使用すること
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

my $q   = CGI->new();
my $id  = $q->param('i');
my $dbh = MyClass::UsrWebDB::connect({
             dbaccount => $cfg->param('DATABASE_USER'),
             dbpasswd  => $cfg->param('DATABASE_PASSWORD'),
             dbname    => $cfg->param('DATABASE_NAME'),
          });

$dbh->do('set names utf8');
my $sql                      = sprintf("SELECT mime_type, image FROM %s.tSiteImageM WHERE id=?;", $cfg->param('DATABASE_NAME'));
my ($mime_type, $image_data) = $dbh->selectrow_array($sql, undef, $id);
$dbh->disconnect();

print $q->header(-type=>$mime_type,-Content_Length=>length ($image_data));
print $image_data;

ModPerl::Util::exit();


sub Error {
    my $msg = shift;
    my $q = CGI->new();
    print $q->header(),
            $q->start_html("Error"),
            $q->p($q->escapeHTML($msg)),
            $q->end_html();
    ModPerl::Util::exit();
}
