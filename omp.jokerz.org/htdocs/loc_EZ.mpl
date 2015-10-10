#******************************************************
# @desc		AU端末用位置登録情報受け取りスクリプト
#           パラメータを受け取り、レダイレクトする
# @script   loc_EZ.mpl
# @access	public
# @author	Iwahase Ryo
# @create	2010/07/06
# @update	
#******************************************************


use strict;
use vars qw($cfg);

BEGIN {
    my $config = $ENV{'OMP_CONFIG'};
    require MyClass::Config;
    $cfg = MyClass::Config->new($config);
}
{
    use CGI::Carp qw(fatalsToBrowser);
    use CGI;
    my $q            = CGI->new();
    my %params       = $q->Vars();
    my @param        = map { sprintf("%s=%s", $_, $q->escape($params{$_})) } keys %params;
    my $redirect_url = sprintf("%s/%s?guid=ON&a=regist&o=area&%s", $cfg->param('MEMBER_MAIN_URL'), $cfg->param('MEMBER_CONTROLER_NAME'), join('&', @param));

    print "Location: $redirect_url\n\n";

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}