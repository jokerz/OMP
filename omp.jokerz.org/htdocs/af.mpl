#******************************************************
# @desc        アフィリエイト・広告経由時の処理
#            広告コードチェック 有効期限のチェック guid取得 DBにログ格納
# @access    public
# @author    Iwahase Ryo
# @create    2010/01/26
# @update    
#
#******************************************************
use strict;
use vars qw($cfg);

BEGIN {

    my $config = $ENV{'JKZ_WAF_CONFIG'};

    require MyClass::Config;
    $cfg = MyClass::Config->new($config);

    unshift @INC, $cfg->param('MYLIB_DIR') . '/JKZ';
    unshift @INC, $cfg->param('MYLIB_DIR') . '/lib';
}
{
    use MyClass::JKZMobile;
    use MyClass::UsrWebDB;
    use MyClass::JKZLogger;
    use MyClass::JKZDB::Affiliate;
    use MyClass::JKZDB::AffiliateAccessLog;

    my $agent       = MyClass::JKZMobile->new();
    my $carrier     = $agent->getCarrierCode();
    $carrier        = 2 ** $carrier;
    my $guid        = $agent->getDCMGUID();
    my $subno       = $agent->getSubscribeNumber();
    my $useragent   = $ENV{'HTTP_USER_AGENT'};
    my $q           = CGI->new ();
    ## 広告コード取得
    my $acd         = $q->param('acd');
    my $dbh         = MyClass::UsrWebDB::connect();
    my $myAffiliate = MyClass::JKZDB::Affiliate->new($dbh);

    #**********************************
    #
    # 広告コードに問題が無い場合はDBデータをいれ、リダイレクト
    # 以外は通常にリダイレクト
    #**********************************
    my $ref = $myAffiliate->fetchParameNameAndReturnUrl($acd);

    ## パラメータ名と成果送信先URLの取得OKの場合
    if ( exists($ref->{param_name1}) && exists($ref->{return_url}) ) {
        ## tAffiliateMのparam_name1(受信パラメータ名)値から受信されるパラメータの値を取得
        my $afcd       = $q->param($ref->{param_name1});
        my $return_url = $ref->{return_url};
        my $myLog      = MyClass::JKZDB::AffiliateAccessLog->new($dbh);

        $myLog->executeUpdate({
                    acd        => $acd,
                    guid       => $guid,
                    afcd       => $afcd,
                    return_url => $return_url,
                    subno      => $subno,
                    useragent  => $useragent,
                    carrier    => $carrier,
        });

#        my $logger = MyClass::JKZLogger->new( { acd => $acd } );
#        $logger->saveMediaAccessLog();
#        $logger->closeLogger();
    }

    my $siteurl = sprintf("http://1mp.1mp.jp?acd=%s", $acd);

    print "Location: $siteurl\n\n";

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}
