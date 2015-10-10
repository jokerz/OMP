#******************************************************
# @desc        �O���֑J�� �|�C���g�o�b�N�L���̏���
#            �R�[�h�`�F�b�N  guid�擾 DB�Ƀ��O�i�[
# @access    public
# @author    Iwahase Ryo
# @create    2010/02/04
# @update    
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
   ## �L���R�[�h�������ꍇ�I��
    my $q = CGI->new();
    use MyClass::JKZMobile;

    my $agent   = MyClass::JKZMobile->new();
    my $carrier = $agent->getCarrierCode();
    my $guid    = $agent->getDCMGUID();

    if ( !$q->param('ad_id') || !$guid ) {
        print "Content-Type: text/html\n\n";
        print "�G���[\n";
        print $guid,"\n", $q->param('ad_id'),"\n";
        exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
    }

    
    use MyClass::UsrWebDB;
    use MyClass::JKZDB::Media;
    use MyClass::JKZDB::MediaAccessLog;


    my $useragent   = $ENV{'HTTP_USER_AGENT'};

    ## �L���R�[�h�擾
    my $ad_id   = $q->param('ad_id');
    my $dbh     = MyClass::UsrWebDB::connect();
    my $myMedia = MyClass::JKZDB::Media->new($dbh);

## �R�[�h�擾�����Ƃ��ăL�����A ad_id, status_flg

    #**********************************
    #
    # �L���R�[�h�ɖ�肪�����ꍇ��DB�f�[�^������A���_�C���N�g
    # �ȊO�͒ʏ�Ƀ��_�C���N�g
    #**********************************
    my $adref = $myMedia->fetchAdUrlPointByAdID({ ad_id => $ad_id, carrier => (2 ** $carrier) });

    unless (exists($adref->{ad_url})) {
      return;
    } else {
        my $ad_url              = $adref->{ad_url};
        my $ad_point            = $adref->{point};
        my $ad_price_per_regist = $adref->{price_per_regist};
        my $send_param_name     = $adref->{send_param_name};

        require CGI::Session;
        my $session    = CGI::Session->new(undef, undef, { Directory => '/home/vhosts/JKZ/tmp/.session' });
        my $session_id = $session->id;
        my $myLog      = MyClass::JKZDB::MediaAccessLog->new($dbh);

        $myLog->executeUpdate(
                {
                    session_id       => $session_id,
                    ad_id            => $ad_id,
                    ad_point         => $ad_point,
                    price_per_regist => $ad_price_per_regist,
                    guid             => $guid,
                    carrier          => 2 ** $carrier,
                    useragent        => $useragent,
                }, -1
        );

        $session->close;
        $session->delete;

        my $location = sprintf("%s&%s=%s", $ad_url, $send_param_name, $session_id);
        print "Location: $location\n\n";
    }

    exists $ENV{MOD_PERL} ? ModPerl::Util::exit() : exit();
}
