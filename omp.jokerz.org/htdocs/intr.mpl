#******************************************************
#   intr.mpl
# @desc       友達紹介経由時の処理
#            id 有効期限のチェック guid取得 DBにログ格納
# @access    public
# @author    Iwahase Ryo
# @create    2010/02/02
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
    use MyClass::JKZDB::Member;
    use MyClass::JKZDB::FriendIntroAccessLog;

    my $agent       = MyClass::JKZMobile->new();
    my $carrier     = $agent->getCarrierCode();
    $carrier        = 2 ** $carrier;
    my $guid        = $agent->getDCMGUID();
    my $subno       = $agent->getSubscribeNumber();
    my $useragent   = $ENV{'HTTP_USER_AGENT'};
    my $q           = CGI->new ();
    ## 紹介ID取得
    my $friend_intr_id    = $q->param('fintr_id');
    my $dbh         = MyClass::UsrWebDB::connect();
    my $myMember = MyClass::JKZDB::Member->new($dbh);

    #**********************************
    #
    # 友達紹介IDFに問題が無い場合はDBデータをいれ、リダイレクト
    # 以外は通常にリダイレクト 戻り値はowid, guid
    #**********************************
    my $ref = $myMember->fetchOwIDGuIDbyIntrID($friend_intr_id);

    ## パラメータ名と成果送信先URLの取得OKの場合
    if ( exists($ref->{owid}) ) {
        my $myLog      = MyClass::JKZDB::FriendIntroAccessLog->new($dbh);

        $myLog->executeUpdate({
                    guid           => $guid,
                    friend_intr_id => $friend_intr_id,
                    friend_owid    => $ref->{owid},
                    friend_guid    => $ref->{guid},
                    useragent      => $useragent,
                    carrier        => $carrier,
        });

#        my $logger = MyClass::JKZLogger->new( { acd => $acd } );
#        $logger->saveMediaAccessLog();
#        $logger->closeLogger();
    }

    #my $siteurl = sprintf("http://1mp.1mp.jp?acd=%s", $acd);
    my $siteurl = "http://1mp.1mp.jp";

    print "Location: $siteurl\n\n";

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}
