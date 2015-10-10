#******************************************************
# @desc      ������
# 
# @package   MyClass::JKZApp::AppMember
# @access    
# @author    Iwahase Ryo 
# @create    2009/07/30
# @update    2009/11/26  ���������memberstatus_flag��ǉ�
#                        ������̉����ʂɕs���o�^�����ǉ�
#                        ����ڍ׉�ʂŕs���o�^����ɃX�e�[�^�X�ύX�@�\
# @version    
#******************************************************
package MyClass::JKZApp::AppMember;

use 5.008005;
our $VERSION = '1.00';
use strict;

use base qw(MyClass::JKZApp);
use MyClass::JKZDB::Member;
use MyClass::JKZDB::UserRegistLog;
use MyClass::JKZDB::MailAddressLog;
use MyClass::JKZDB::PointLog;

use Data::Dumper;

#******************************************************
# @access    public
# @desc        �R���X�g���N�^
# @param    
# @return    
#******************************************************
sub new {
    my ($class, $cfg) = @_;

    return $class->SUPER::new($cfg);
}


#******************************************************
# @access    public
# @desc        �e�N���X�̃��\�b�h
# @param    
#******************************************************
sub dispatch {
    my $self = shift;
#    $self->{q}->autoEscape (0);
    !defined($self->query->param('action')) ? $self->action('formMember') : $self->action();

    $self->SUPER::dispatch();
}

#******************************************************
# @access    
# @desc        ��������t�H�[��
# @param    
# @param    
# @return    
#******************************************************
sub formMember {
    my $self = shift;

    #my $obj = $self->fetchMediaList();
    my $namespace = $self->waf_name_space();
    my $obj = {};
    my $dbh = $self->getDBConnection();
    my $aryref = $dbh->selectall_arrayref("SELECT acd, client_name FROM $namespace.tAffiliateM ORDER BY registration_date DESC;", { Columns => {} });
    $obj->{LoopACDList} = $#{$aryref};
    my $tmpkey = 'p';
    for (my $i = 0; $i <= $obj->{LoopACDList}; $i++) {
        map { $obj->{$tmpkey . $_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc        ��������o��
# @return    
#******************************************************

sub countMember {
    my $self      = shift;
    my $q         = $self->query;
    my $dbh       = $self->getDBConnection();
    my $namespace = $self->waf_name_space();
    my $obj       = {};

    my $sql       = sprintf("
SELECT 
 COUNT(IF(sex=2 AND carrier=2,owid,NULL)) AS 'MD',
 COUNT(IF(sex=2 AND carrier=4,owid,NULL)) AS 'MS',
 COUNT(IF(sex=2 AND carrier=8,owid,NULL)) AS 'MA',
 COUNT(IF(sex=4 AND carrier=2,owid,NULL)) AS 'WD',
 COUNT(IF(sex=4 AND carrier=4,owid,NULL)) AS 'WS',
 COUNT(IF(sex=4 AND carrier=8,owid,NULL)) AS 'WA',
 COUNT(IF(carrier=2,owid,NULL)) AS 'TD',
 COUNT(IF(carrier=4,owid,NULL)) AS 'TS',
 COUNT(IF(carrier=8,owid,NULL)) AS 'TA',
 COUNT(IF(sex=4,owid,NULL)) AS 'TW',
 COUNT(IF(sex=2,owid,NULL)) AS 'TM',
 COUNT(IF(sex&6,owid,NULL)) AS 'T'
 FROM %s.tMemberM
 WHERE status_flag=2
", $namespace);

    my $hashref = $dbh->selectrow_hashref($sql);
    map { $obj->{$_} = $hashref->{$_} } keys %{ $hashref };

    return ($obj);
}


#******************************************************
# @access    public
# @desc      ����|�C���g�����L���O
# @param    
# @return    
#******************************************************
sub pointRanking {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    if ($q->param('submit')) {
        my $frsdate = $q->param('frsdate');
        my $fredate = $q->param('fredate');
        my @searchquery;
        my @searchquerymessage;
        if ($frsdate) {
            $frsdate =~ s!/!-!g;
            push(@searchquery, "DATE_FORMAT(p.registration_date, '%Y-%m-%d') >= '$frsdate'");
            push(@searchquerymessage, "�o�^���������F[ $frsdate ]");
        }
        if ($fredate) {
            $fredate =~ s!/!-!g;
            push(@searchquery, "DATE_FORMAT(p.registration_date, '%Y-%m-%d') <= '$fredate'");
            push(@searchquerymessage, "�o�^��������F[ $fredate ]");
        }
        my $sql = "SELECT p.owid, SUM(p.point) AS SUM_POINT, m.nickname FROM tPointLogF p LEFT JOIN tMemberM m ON p.owid=m.owid   WHERE p.type_of_point & 7";

        if (0 < @searchquery) {
            $sql .= sprintf(" AND %s", join(' AND ', @searchquery));
        }
        
        $sql .= " GROUP BY p.owid   ORDER BY SUM_POINT DESC LIMIT 30";

        $obj->{SEARCHQUERYMESSAGE} = join('�@', @searchquerymessage);

        my $dbh = $self->getDBConnection();
        $dbh->do('USE JKZ_WAF');
        $dbh->do('set names sjis');

        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} } );

        $obj->{LoopSearchPointRankingList} = $#{ $aryref };
        $obj->{IfSearchResultExists} = 1;
        for (my $i = 0; $i <= $obj->{LoopSearchPointRankingList}; $i++) {
            map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{ $aryref };
        }

     }
     return $obj;

}


#******************************************************
# @access    public
# @desc        ����f�[�^����
# @param    
# @return    
#******************************************************
sub searchMember {
    my $self      = shift;
    my $q         = $self->query();
    my $obj       = {};
    my $namespace = $self->waf_name_space();
    ## Modified 20100324
    my %hashsearchwords = $q->Vars();
    map { $obj->{'s_' . $_} = $hashsearchwords{$_} } keys %hashsearchwords;

    #*************************
    # �L���㗝�X���X�g����
    #*************************
    my $dbh = $self->getDBConnection();
    my $AAaryref = $dbh->selectall_arrayref("SELECT acd, client_name FROM $namespace.tAffiliateM ORDER BY registration_date DESC;", { Columns => {} });
    $obj->{LoopACDList} = $#{$AAaryref};
    my $tmpkey = 'p';
    for (my $i = 0; $i <= $obj->{LoopACDList}; $i++) {
        map { $obj->{$tmpkey . $_}->[$i] = $AAaryref->[$i]->{$_} } keys %{ $AAaryref };
    }

    #*************************
    # ������������
    #*************************
    my %condition = ();
    $condition{columnslist} = ['owid', 'status_flag', 'memberstatus_flag', 'mailstatus_flag', 'mobilemailaddress', 'carrier', 'subno', 'guid', 'sex', 'adv_code', 'useragent', 'registration_date', 'withdraw_date', 'reregistration_date',];

    my @searchquery;
    ## ���������̓��e
    my @searchquerymessage;
    my ($status_flag, $memberstatus_flag, $carrier, $adv_code, $sex, $personality, $bloodtype, $occupation, $prefecture, $mailstatus_flag);

    my $cookie_name = $self->{cfg}->param('COOKIE_NAME') . 'searchcondition';

    my $record_limit    = 50;
    my $offset          = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;

    my $MAXREC_SQL = "SELECT COUNT(owid) FROM $namespace.tMemberM ";

    if ($q->MethGet() && defined($q->param('off'))) {
        my $cookie = $q->cookie($cookie_name);

        my ($whereSQL, $orderbySQL, $holder)                 = split (/,/, $cookie);
        ( $condition{whereSQL}, $obj->{SEARCHQUERYMESSAGE} ) = split(/::/, $whereSQL);
        @{ $condition{placeholder} }                         = split(/ /, $holder);
        $condition{orderbySQL}                               = $orderbySQL;

        $MAXREC_SQL .= sprintf(" WHERE %s", $condition{whereSQL}) if $condition{whereSQL} ne "";

    }
    else {

        #*************************
        # ���ID mid fsmid -> start point femid -> end point
        #*************************
        if ($q->param('fsmid')) { #|| $q->param('femid')) {
            my @fsmid;
            my $fsplaceholder;
            my @param = $q->param('fsmid');
            if (0 < $#param) {
                #$fsmid = join(',', @param);
                @fsmid = @param;
                $fsplaceholder = ',?' x $#fsmid;
            }
            else {
                my $mid = $param[0];
                $mid =~ s/^[\s|,]+//g;
                $mid =~ s/[\s|,]+$//g;
                $mid =~ s/[\s|,]+/,/g;
                @fsmid = split(/,/, $mid);
                $fsplaceholder = ',?' x $#fsmid;
            }

            push(@searchquery, sprintf("owid IN(?%s)", $fsplaceholder));

            push(@{ $condition{placeholder} }, @fsmid);

            push(@searchquerymessage, sprintf("���ID�F[ %s ]", join(' ', @fsmid)));

        } else {
            push @searchquerymessage, "���ID�F[ �w��Ȃ� ]";
        }

        #*************************
        # �ő̎���NO(subno)
        #*************************
        if ($q->param('subno')) {
            my $subno = $q->param('subno');
            ( push(@searchquery, sprintf("subno REGEXP '^%s*'", $subno)) );
            push(@searchquerymessage, "�ő̎���NO�F[ $subno ]");
        } else {
            push @searchquerymessage, "�ő̎���NO�F[ �w��Ȃ� ]";
        }

        #*************************
        # guid/subno
        #*************************
        if ($q->param('guid')) {
            my $guid = $q->param('guid');
            ( push(@searchquery, 'guid = ?') && push(@{ $condition{placeholder} }, $guid) );
            push(@searchquerymessage, "dcmguid/x-jphone-uid�F[ $guid ]");
        } else {
            push @searchquerymessage, "dcmguid/x-jphone-uid�F[ �w��Ȃ� ]";
        }

        #*************************
        # ���[�����ڽ
        #*************************
        if ($q->param('mobilemailaddress')) {
            my $mobilemailaddress = $q->param('mobilemailaddress') if MyClass::WebUtil::Looks_Like_Email($q->param('mobilemailaddress'));
            ( push(@searchquery, 'mobilemailaddress= ?') && push(@{ $condition{placeholder} }, $mobilemailaddress) );
            push(@searchquerymessage, "���[���A�h���X�F[ $mobilemailaddress ]");
        } else {
            push @searchquerymessage, "���[���A�h���X�F[ �w��Ȃ� ]";
        }

        #*************************
        # �o�^��� �S��Ԃ��I������Ă���Ƃ��͏����Ƃ��Ȃ�
        # ���v�l7 0(1) �� 1(2) �{��� 2(4) �މ�
        # 1�̉���r�� 2009/09/14
        #*************************
        if ($q->param('status_flag')) {
            map { $status_flag += 2 ** $_ } $q->param('status_flag');

# Modified 2010/03/25 BEGIN

                    ( 2 == $status_flag ) ? $obj->{IfsMemberStatus}          = 1 :
                    ( 4 == $status_flag ) ? $obj->{IfsWithdrawnMemberStatus} = 1 :
                                            $obj->{IfsAllStatus}             = 1 ;
# Modified 2010/03/25 END

            unless (6 == $status_flag) {
                push(@searchquery, 'status_flag = ?');
                push(@{ $condition{placeholder} }, $status_flag);
                push( @searchquerymessage, (2 == $status_flag ? "�����ԁF[ ��� ]" : "�����ԁF[ �މ��� ]") );
            } else {
                push @searchquerymessage, "�����ԁF[ �w�薳�� ]";
            }
        }

        #*************************
        # �L�����A �S���I������Ă�Ƃ��͏����Ƃ��Ȃ�
        # ���v�l�̕ύX(���̑����폜�������ߍ��v�l��14)
        #*************************
        if ($q->param('carrier')) {
            map { $carrier += 2 ** $_ } $q->param('carrier');

# Modified 2010/03/25 BEGIN
                    ( 14 == $carrier ) ? $obj->{IfsAllCarrier}     = 1 :
                    ( 2  == $carrier ) ? $obj->{IfsDoCoMo}         = 1 :
                    ( 4  == $carrier ) ? $obj->{IfsSoftBank}       = 1 :
                    ( 8  == $carrier ) ? $obj->{IfsAU}             = 1 :
                    ( 12 == $carrier ) ? $obj->{IfsSoftBankAU}     = 1 :
                    ( 6  == $carrier ) ? $obj->{IfsDoCoMoSoftBank} = 1 :
                                         $obj->{IfsDoCoMoAU}       = 1 ;
# Modified 2010/03/25 END

            unless (14 == $carrier) {
                push(@searchquery, 'carrier & ?');
                push(@{ $condition{placeholder} }, $carrier);

                my $search_carrier =
                    ( 4  == $carrier ) ? "�L�����A�F[ SoftBank ]"        :
                    ( 8  == $carrier ) ? "�L�����A�F[ AU ]"              :
                    ( 12 == $carrier ) ? "�L�����A�F[ SoftBank AU ]"     :
                    ( 6  == $carrier ) ? "�L�����A�F[ DoCoMo SoftBank ]" :
                    ( 10 == $carrier ) ? "�L�����A�F[ DoCoMo AU ]"       :
                                          "�L�����A�F[ DoCoMo ]"         ;
                push( @searchquerymessage, $search_carrier );
            } else {
                push( @searchquerymessage, "�L�����A�F[ �w��Ȃ� ]" );
            }
        }

        #*************************
        # ���[���A�h���X�o�^���
        # ���v�l7 0(1) �� 1(2) �{��� 2(4) �މ�
        # 1�̉���r�� 2009/09/17
        #*************************
        # �����ăT�C�g�ŋ󃁁[���o�^�̂��ߕs�v
=pod
        if ($q->param('mailstatus_flag')) {
            $mailstatus_flag = $q->param('mailstatus_flag');
            unless (0 == $mailstatus_flag) {
                push(@searchquery, 'mailstatus_flag = ?');
                push(@{ $condition{placeholder} }, $mailstatus_flag);
                push( @searchquerymessage, (2 == $mailstatus_flag ? "���[���A�h���X�o�^�F[ �o�^�L�� ]" : "���[���A�h���X�o�^�F[ �o�^���� ]") );
            } else {
                push @searchquerymessage, "���[���A�h���X�o�^�F[ �w�薳�� ]";
            }
        }
=cut

        #*************************
        # �����ʓo�^��� 2009/11/28
        # envconf.cfg�̔z��� 0(1) 315�~    1(2) 2000�~    2(3) �_�E�����[�h    3(4) ����    4(5) �s���o�^���
        #                ������ ��  �ʏ�         ���m��P        �_�E�����[�h         ����         �s�����
        # DataBase Table�̒l    2            4            8                    16            32
        #*************************

        if ($q->param('memberstatus_flag')) {
            $memberstatus_flag = $q->param('memberstatus_flag');
            if (1 == $memberstatus_flag) {
                $obj->{Ifs_OKMember}    = 1;
            }
            elsif (5 == $memberstatus_flag) {
                $obj->{Ifs_NotOKMember} = 1;
            }
            else {
                $obj->{Ifs_BothMember}  = 1;
            }
            unless (0 == $memberstatus_flag) {
                $memberstatus_flag = 2 ** $memberstatus_flag;
                push(@searchquery, 'memberstatus_flag = ?');
                push(@{ $condition{placeholder} }, $memberstatus_flag);
                push( @searchquerymessage, (2 == $memberstatus_flag ? "�����ʁF[ ����o�^��� ]" : "�����ʁF[ �s���o�^��� ]") );
            } else {
                push @searchquerymessage, "�����ʁF[ �w�薳�� ]";
            }
        }

        #*************************
        # �L���R�[�h
        #*************************
        if ($q->param('adv_code')) {
            $adv_code = $q->param('adv_code');
            push(@searchquery, 'adv_code = ?');
            push(@{ $condition{placeholder} }, $adv_code);
            push @searchquerymessage, "�L���R�[�h�F[ $adv_code ]";
        } else {
            push @searchquerymessage, "�L���R�[�h�F[ �w��Ȃ� ]";
        }

        #*************************
        # �o�^��
        #*************************
        if($q->param('frsdate') eq ''){
            push @searchquerymessage, "�o�^���������F[ �w��Ȃ� ]";
        }else{
            my $frsdate = $q->param('frsdate');
            ( push(@searchquery , "registration_date >= ?") && push(@{ $condition{placeholder} }, $frsdate) );
            push @searchquerymessage, "�o�^���������F[ $frsdate ]";
        }
        if($q->param('fredate') eq ''){
            push @searchquerymessage, "�o�^��������F[ �w��Ȃ� ]";
        }else{
            my $fredate = $q->param('fredate');
            ( push(@searchquery , "registration_date <= ?") && push(@{ $condition{placeholder} }, $fredate) );
            push @searchquerymessage, "�o�^��������F[ $fredate ]";
        }

        #*************************
        # ���� �j���̏ꍇ�͏����Ƃ��Ȃ�
        #*************************
        if ($q->param('sex')) {
            map { $sex += 2 ** $_ } $q->param('sex');
# Modified 2010/03/25 BEGIN
=pod
                    ( 2 == $sex ) ? $obj->{IfsMale}   = 1 :
                    ( 4 == $sex ) ? $obj->{IfsFemale} = 1 :
                                    $obj->{IfsAllSex} = 1 ;
=cut
# Modified 2010/03/25 END
            unless (6 == $sex) {
                push(@searchquery, 'sex & ?');
                push(@{ $condition{placeholder} }, $sex);
            } else {
                push @searchquerymessage, "���ʁF[ �w��Ȃ� ]";
            }
        }

        #*************************
        # �N���
        #*************************
        if ($q->param('frsage') eq '') {
            push @searchquerymessage, "�N����F[ �w��Ȃ� ]";
        }else {
            my $frsage = $q->param('frsage');
            push(@searchquery, " YEAR(DATE_SUB(NOW(), INTERVAL TO_DAYS(DATE_FORMAT(CONCAT(year_of_birth, month_of_birth, date_of_birth), '%Y-%m-%d')) DAY)) >= ?");
            push(@{ $condition{placeholder} }, $frsage);
            push @searchquerymessage, "�N����F[ $frsage ]";
        }

        #*************************
        # �N����
        #*************************
        if ($q->param('freage') eq '') {
            push @searchquerymessage, "�N�����F[ �w��Ȃ� ]";
        }else {
            my $freage = $q->param('freage');
            push(@searchquery, " YEAR(DATE_SUB(NOW(), INTERVAL TO_DAYS(DATE_FORMAT(CONCAT(year_of_birth, month_of_birth, date_of_birth), '%Y-%m-%d')) DAY)) <= ?");
            push(@{ $condition{placeholder} }, $freage);
            push @searchquerymessage, "�N�����F[ $freage ]";
        }

        #*************************
        # �މ��
        #*************************
        if($q->param('fdsdate') eq ''){
            push @searchquerymessage, "�މ���������F[ �w��Ȃ� ]";
        }else{
            my $fdsdate = $q->param('fdsdate');
            ( push(@searchquery , "withdraw_date >= ?") && push(@{ $condition{placeholder} }, $fdsdate) );
            push @searchquerymessage, "�މ���������F[ $fdsdate ]";
        }
        if($q->param('fdedate') eq ''){
            push @searchquerymessage, "�މ��������F[ �w��Ȃ� ]";
        }else{
            my $fdedate = $q->param('fdedate');
            ( push(@searchquery , "withdraw_date <= ?") && push(@{ $condition{placeholder} }, $fdedate) );
            push @searchquerymessage, "�މ��������F[ $fdedate ]";
        }

        $obj->{SEARCHQUERYMESSAGE} = join('�@', @searchquerymessage);

        #*************************
        # �n��
        #*************************
        if ($q->param('personality')) {
            map { $personality += 2 ** $_ } $q->param('personality');
            push(@searchquery, 'personality & ?');
            push(@{$condition{placeholder}}, $personality);
        }

        #*************************
        # ���t�^ �S���I������Ă�Ƃ��͏����Ƃ��Ȃ�
        #*************************
        if ($q->param('bloodtype')) {
            map { $bloodtype += 2 ** $_ } $q->param('bloodtype');
            unless (30 == $bloodtype) {
                push(@searchquery, 'bloodtype & ?');
                push(@{$condition{placeholder}}, $bloodtype);
            }
        }

        #*************************
        # �E��
        #*************************
        if ($q->param('occupation')) {
            map { $occupation += 2 ** $_ } $q->param('occupation');
            push(@searchquery, 'occupation & ?');
            push(@{$condition{placeholder}}, $occupation);
        }

        #*************************
        # �s���{�� �S���I������Ă���Ƃ��͏����Ƃ��Ȃ�
        #*************************
        if ($q->param('prefecture')) {
            map { $prefecture += 2 ** $_ } $q->param('prefecture');
            unless (281474976710654 == $prefecture) {
                push(@searchquery, 'prefecture & ?');
                push(@{$condition{placeholder}}, $prefecture);
            }
        }

        $condition{whereSQL} = sprintf "%s", join(' AND ', @searchquery);

        my @ORDERBY = ('registration_date', 'mid', 'carrier',);
        $condition{orderbySQL} = sprintf("%s DESC", $ORDERBY[$q->param('orderby')-1]);

        $MAXREC_SQL .= sprintf(" %s%s", (0 < @searchquery ? "WHERE " : ""),join(' AND ', @searchquery));

        my $cookiesql = join(' AND ', @searchquery);
        $cookiesql .= sprintf("::%s", $obj->{SEARCHQUERYMESSAGE});
        $cookiesql .= sprintf("\, %s", $condition{orderbySQL});
        $cookiesql .= "\,@{ $condition{placeholder} }" if defined(@{ $condition{placeholder} });

        $self->{cookie} = $self->query->cookie(
                        -name  => $cookie_name,
                        -value => $cookiesql,
                        -path  =>    '/',
                        );

    }

    $condition{limitSQL} = "$offset, $condition_limit";

    #*********************************
    ## �y�[�W���\�������N�̃i�r
    #*********************************
    my @navilink;
    my $maxrec = $dbh->selectrow_array($MAXREC_SQL, undef, @{ $condition{placeholder} });

    ## ���R�[�h����1�y�[�W�������葽���ꍇ
    if ($maxrec > $record_limit) {

        my $url = 'app.mpl?app=AppMember;action=searchMember;search=1';

    ## �O�փy�[�W�̐���
        if (0 == $offset) { ## �ŏ��̃y�[�W�̏ꍇ
            push(@navilink, "&lt;&lt;�O&nbsp;");
        } else { ## 2�y�[�W�ڈȍ~�̏ꍇ
            push(@navilink, $self->genNaviLink($url, "&lt;&lt;�O&nbsp;", $offset - $record_limit));
        }

    ## �y�[�W�ԍ�����
        for (my $i = 0; $i < $maxrec; $i += $record_limit) {

            my $pageno = int ($i / $record_limit) + 1;

            if ($i == $offset) { ###���ݕ\�����Ă��߰�ޕ�
                push (@navilink, '<font style="font-size:14px;font-weight:bold;">' . $pageno . '</font>');
            } else {
                push (@navilink, $self->genNaviLink($url, $pageno, $i));
            }
        }

    ## ���փy�[�W�̐���
        if (($offset + $record_limit) > $maxrec) {
            push (@navilink, "&nbsp;��&gt;&gt;");
        } else {
            push (@navilink, $self->genNaviLink($url, "&nbsp;��&gt;&gt;", $offset + $record_limit));
        
        }

        @navilink = map{ "$_\n" } @navilink;
        
        $obj->{pagenavi} = sprintf("<font size=-1>[�S%s�� / %s��\�\\��]</font><br />", $maxrec, $record_limit) . join(' ', @navilink);
    }
    else { ## Modified ���R�[�h���̕\����ǉ� 2009/10/29 
        $obj->{pagenavi} = sprintf("<font size=-1>[�S%s��]</font><br />", $maxrec, $record_limit);
    }

    my $MemberList = MyClass::JKZDB::Member->new($dbh);
    my $aryref = $MemberList->getSpecificValuesSQL(\%condition);

    my @status = ('', '', '<font style="color:#0000ff;">���</font>', '', '<font style="color:#ff0000;">�މ�</font>', '', '', '', '', '', '');
    ## �v�C��
    my @mailstatus = ('', '��', '����', '', '', '', '', '', '', '', '');

    ## �A�t�B���G�C�g�E�o�i�[�̍L��ID����N���C�A���g���ɕϊ����邽��
    my $mediaclientname;
    my $publishobjfile = sprintf("%s/admin/Media/AffiliateLinkBanner.obj", $self->PUBLISH_DIR());
    eval {
        $mediaclientname = MyClass::WebUtil::publishObj( { file=>$publishobjfile } );
    };

    ## Modified 2009/12/09
    ## �\������l��背�R�[�h���������ꍇ�͔z��C���f�b�N�X��-1�񃋁[�v�E���R�[�h�������Ȃ��Ƃ��͔z��̃C���f�b�N�X�l
    $obj->{LoopSearchMemberList} = ($#{ $aryref->{owid} } >= $record_limit) ? $#{ $aryref->{owid} }-1 : $#{ $aryref->{owid} };
    if (0 <= $obj->{LoopSearchMemberList}) {
        for (my $i = 0; $i <= $obj->{LoopSearchMemberList}; $i++) {
            map { $obj->{$_}->[$i] = $aryref->{$_}->[$i] } qw(owid status_flag memberstatus_flag mailstatus_flag mobilemailaddress carrier subno guid sex adv_code useragent registration_date withdraw_date reregistration_date);

            $obj->{statusDescription}->[$i]     = $status[$obj->{status_flag}->[$i]];
            $obj->{mailstatusDescription}->[$i] = $mailstatus[$obj->{mailstatus_flag}->[$i]];
            $obj->{MEMBER_STATUS}->[$i]         = $self->fetchOneValueFromConf('MEMBER_STATUS', (log($obj->{memberstatus_flag}->[$i]) / log(2)-1));
            $obj->{CARRIER}->[$i]               = $self->fetchOneValueFromConf('CARRIERNAME_JP', (log($obj->{carrier}->[$i]) / log(2)-1));
            $obj->{useragent}->[$i]             = substr($obj->{useragent}->[$i], 0, 20);
            $obj->{registration_date}->[$i]     = MyClass::WebUtil::formatDateTimeSeparator($obj->{registration_date}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 9});
            $obj->{withdraw_date}->[$i]         = MyClass::WebUtil::formatDateTimeSeparator($obj->{withdraw_date}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 9});
            $obj->{reregistration_date}->[$i]   = MyClass::WebUtil::formatDateTimeSeparator($obj->{reregistration_date}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 9});

            $obj->{client_name}->[$i] = exists( $mediaclientname->{$obj->{adv_code}->[$i]} ) ? $mediaclientname->{$obj->{adv_code}->[$i]} : "";
            ## �L�����A�͉摜
            $obj->{CARRIERPIC}->[$i] = 
                ( 8 == $obj->{carrier}->[$i] ) ? 'e' :
                ( 4 == $obj->{carrier}->[$i] ) ? 'v' :
                ( 2 == $obj->{carrier}->[$i] ) ? 'i' :
                                               'spacer';

            ## ���݂̉���Ȃ�ActiveMember�t���O���P �ȊO�͉�����t���O
            2 == $obj->{status_flag}->[$i] ? $obj->{IfActiveMember}->[$i] = 1 : $obj->{IfWithdrawMember}->[$i] = 1;
            ## �Z���̐F�����ݒ�
            $obj->{cssstyle}->[$i] =
                ( 32 == $obj->{memberstatus_flag}->[$i] ) ? 'focusFusei'
                                                          :
                ( 0 == $i % 2 ) ? (( 2 == $obj->{status_flag}->[$i] ) ? 'focusodd'  : 'focus2odd' )
                                : (( 2 == $obj->{status_flag}->[$i] ) ? 'focuseven' : 'focus2even')
                                ;

            $obj->{IfSexUnKnown}->[$i] = 1 if 1 == $obj->{sex}->[$i];
            $obj->{IfMale}->[$i]       = 1 if 2 == $obj->{sex}->[$i];
            $obj->{IfFemale}->[$i]     = 1 if 4 == $obj->{sex}->[$i];

        }
        $obj->{hit_record} = $obj->{LoopSearchMemberList}+1;
        $obj->{IfSearchResultExists} = 1;
    }
    ## �������ʂ�0���̏ꍇ�̏���
    $obj->{IfSearchResultNotExists} = 1 if 0 > $obj->{LoopSearchMemberList};

    #my $cookie_name = $self->{cfg}->param('COOKIE_NAME') . 'searchcondition';

    return $obj;
}


#******************************************************
# @access    
# @desc        ������މ�e�[�u������f�[�^�擾����
# @param    
# @param    
# @return    
#******************************************************
sub searchUserRegistLog {
    my $self = shift;

    my $q = $self->query();

    my ($wherecondition, $hashkey) = MyClass::WebUtil::decodeMD5($q->param('yyyymmdd'));


my $sql = "SELECT * FROM tMemberM
 WHERE guid IN(
  SELECT guid FROM tUserRegistLogF
   WHERE DATE(date_of_transaction)=?
   AND status_flag=?
 )
";

warn "\n --------------\n debug \n $wherecondition \n $hashkey \n ----------------- \n";

}


#******************************************************
# @access    
# @desc        ���P�ʂŃ��A�h�o�^�󋵊m�F
# @param    
# @param    
# @return    
#******************************************************
sub viewMailAddressByMonth {
    my $self = shift;
    my $q = $self->query();

    my $obj = {};
    $obj->{action} = $self->{action};
    #*********************************
    # �N��pulldown����
    #*********************************
    my $pulldown = $self->createPeriodPullDown({year=>"year", month=>"month", range=>"0,3"});
    map { $obj->{$_} = $pulldown->{$_} } keys %{ $pulldown };

    if (defined ($q->param('year'))) {
        my ($sYear, $sMonth);
        $sYear  = $q->param('year');
        $sMonth = $q->param('month');
        #*********************************
        # �Ώی��̓��E�j���̐���
        #*********************************
        my $targetPeriod = sprintf("%04d-%02s", $sYear, $sMonth);

        #*********************************
        # �Ώی��̓��E�j���̐���
        #*********************************
        my $calender = $self->createMonthTable($sYear, $sMonth);
        map { $obj->{$_} = $calender->{$_} } keys %{ $calender };


        $obj->{Days}   = $calender->{LoopMONTH} + 3;
        $obj->{sYEAR}  = $sYear;
        $obj->{sMONTH} = $sMonth;
        $obj->{pMONTH} = $sMonth - 1;
        $obj->{nMONTH} = $sMonth + 1;
        $obj->{IfToPreviousMonth} = 1 < $sMonth ? 1 : 0;
        $obj->{IfToNextMonth}     = 12 > $sMonth ? 1 : 0;
        #*********************************
        # IfAction�u���b�N��L���ɂ���
        #*********************************
        $obj->{IfAction} = 1;
    }
    else {
        my $dbh = $self->getDBConnection();
        my $cmsMailAddressLogList = MyClass::JKZDB::MailAddressLog->new($dbh);
        $cmsMailAddressLogList->executeSelectList({whereSQL    => "type_flag=?", placeholder    => [1,]});

        $obj->{LoopMailAddressList} = $#{ $cmsMailAddressLogList->{columnslist}->{id} };
        foreach my $i (0..$obj->{LoopMailAddressList}) {
            map { $obj->{$_}->[$i] = $cmsMailAddressLogList->{columnslist}->{$_}->[$i] } keys %{ $cmsMailAddressLogList->{columnslist} };
        }
        $obj->{IfList} = 1;
    }

    return($obj);
}


#******************************************************
# @access    public
# @desc        ����f�[�^�\��
#            $hashkey,mid��MD5�G���R�[�h���� �ҏW���̓f�R�[�h����mid���擾
#            skey�����Ƃ���
# @param    
# @return    
#******************************************************
sub detailMember {
    my $self      = shift;
    my $q         = $self->query();
    my $namespace = $self->waf_name_space();
    my $obj       = {};

    $obj->{IfModeView} = !defined($q->param('mode')) || 'view' eq $q->param('mode') ? 1 : 0;
    $obj->{IfModeEdit} = defined($q->param('mode')) && 'edit' eq $q->param('mode') ? 1 : 0;
    #********************************
    # ������̎擾
    #********************************

    my $searchobj;
    $searchobj->{whereSQL}    = defined($q->param('owid')) ? 'owid=?' : 'guid=?';
    $searchobj->{placeholder} = defined($q->param('owid')) ? $q->param('owid') : $q->param('guid');

    my $dbh = $self->getDBConnection();

    my $memref = $self->_getMemberData($searchobj);

    my $HHMM      = MyClass::WebUtil::GetTime("14");
    my $secretkey = MyClass::WebUtil::encodeMD5($memref->{columns}->{guid}, $HHMM);
    $obj->{skey}  = $secretkey;

    if (!$memref) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG14');
    } else {
        map { $obj->{$_} = $memref->{columns}->{$_} } keys %{ $memref->{columns} };

    ## �{���E�ҏW ���ʕ��� BEGIN
        $obj->{mobilemailaddress} = $q->escapeHTML($obj->{mobilemailaddress});
        $obj->{MEMBER_STATUS}     = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('MEMBER_STATUS', (log($obj->{memberstatus_flag}) / log(2)-1)));
        $obj->{CARRIER}           = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('CARRIERNAME_JP', (log($obj->{carrier}) / log(2)-1)));
        
        ## ���̑��̺��ނ��當���ɕύX
        ## �r�b�g�l�̑ΐ��ɂ���
        $obj->{personality} = log($obj->{personality}) / log(2);
        $obj->{bloodtype}   = log($obj->{bloodtype}) / log(2);
        $obj->{occupation}  = log($obj->{occupation}) / log(2);
        $obj->{sex}         = log($obj->{sex}) / log(2);
        $obj->{prefecture}  = log($obj->{prefecture}) / log(2);

        ## ���N��������N��擾
        my $birthday = sprintf("%04d-%02d-%02d",$obj->{year_of_birth}, $obj->{month_of_birth}, $obj->{date_of_birth});
        $obj->{yourAge} = !($birthday = MyClass::WebUtil::calculateAge($birthday)) ? "" : $birthday;

        $obj->{IfActiveUser}    = 1 if 2 == $obj->{status_flag};
        $obj->{IfWithdrawnUser} = 1 if 4 == $obj->{status_flag};
        $obj->{IfSexUnKnown}    = 1 if 0 == $obj->{sex};
        $obj->{IfMale}          = 1 if 1 == $obj->{sex};
        $obj->{IfFemale}        = 1 if 2 == $obj->{sex};

        ## �A�t�B���G�C�g�E�o�i�[�̍L��ID����N���C�A���g���ɕϊ����邽�߂�
        my $mediaclientname;
        my $publishobjfile = sprintf("%s/admin/Media/AffiliateLinkBanner.obj", $self->PUBLISH_DIR());
        eval {
            $mediaclientname = MyClass::WebUtil::publishObj( { file=>$publishobjfile } );
        };
        $obj->{client_name} = exists( $mediaclientname->{$obj->{adv_code}} ) ? $mediaclientname->{$obj->{adv_code}} : "";

    ## �{���E�ҏW ���ʕ��� END
        if ($obj->{IfModeView}) { ## �����̕����͉{�����[�h������ BEGIN
            $obj->{personalityDescription} = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('PERSONALITY', $obj->{personality}));
            $obj->{bloodtypeDescription}   = $self->fetchOneValueFromConf('BLOODTYPE', $obj->{bloodtype});
            $obj->{occupationDescription}  = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('OCCUPATION', $obj->{occupation}));
            $obj->{prefectureDescription}  = MyClass::WebUtil::convertByNKF('-s', $self->fetchOneValueFromConf('PREFECTURE', $obj->{prefecture}));
        } ## �����̕����͉{�����[�h������ END
        elsif ($obj->{IfModeEdit}) { ## �����̕����͕ҏW������ BEGIN
            $obj->{IfTypeUnKnown} = 1 if 0 == $obj->{bloodtype};
            $obj->{IfTypeA}       = 1 if 1 == $obj->{bloodtype};
            $obj->{IfTypeAB}      = 1 if 2 == $obj->{bloodtype};
            $obj->{IfTypeB}       = 1 if 3 == $obj->{bloodtype};
            $obj->{IfTypeO}       = 1 if 4 == $obj->{bloodtype};

            my $prefecturelist    = $self->fetchValuesFromConf("PREFECTURE", $obj->{prefecture});
            my $personalitylist   = $self->fetchValuesFromConf("PERSONALITY", $obj->{personality});
            my $occupationlist    = $self->fetchValuesFromConf("OCCUPATION", $obj->{occupation});
            map { $obj->{$_} = $prefecturelist->{$_}  } %{ $prefecturelist };
            map { $obj->{$_} = $personalitylist->{$_} } %{ $personalitylist };
            map { $obj->{$_} = $occupationlist->{$_}  } %{ $occupationlist };
        } ## �����̕����͕ҏW������ BEGIN
    }

    ## �����ŏ�����
    my $aryref;
    no strict('refs');
    #********************************
    # ���މ��
    #********************************
    my $cmsRegistLog = MyClass::JKZDB::UserRegistLog->new($dbh);
    my $guid = $obj->{guid};
## Modified  2010/02/25
    my  $owid =  $obj->{owid};
=pod
    $aryref = $cmsRegistLog->getSpecificValuesSQL({
        columnslist        => [
            'status_flag', 'date_of_transaction',
        ],
        whereSQL    => 'guid=?',
        orderbySQL  => 'date_of_transaction DESC',
        limitSQL    => "5",
        placeholder => ["$guid"],
    });
=cut

    $aryref = $cmsRegistLog->getSpecificValuesSQL({
        columnslist        => [
            'status_flag', 'date_of_transaction',
        ],
        whereSQL    => 'owid=?',
        orderbySQL  => 'date_of_transaction DESC',
        limitSQL    => "5",
        placeholder => ["$owid"],
    });


    $obj->{LoopRegistLogList} = $#{ $aryref->{status_flag} };
    if (0 <= $obj->{LoopRegistLogList}) {
        $obj->{IfExistsRegistHistory} = 1;
        for (my $i = 0; $i <= $obj->{LoopRegistLogList}; $i++) {
            map { $obj->{$_}->[$i] = $aryref->{$_}->[$i] } keys %{$aryref};
            $obj->{IfRegist}->[$i]   = 1 if 2 == $aryref->{status_flag}->[$i];
            $obj->{IfWithdraw}->[$i] = 1 if 4 == $aryref->{status_flag}->[$i];
            $obj->{IfMNG}->[$i]      = 1 if 8 == $aryref->{status_flag}->[$i];
            $obj->{date_of_transaction}->[$i] = MyClass::WebUtil::formatDateTimeSeparator($obj->{date_of_transaction}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 14});
        }
    } else {
        $obj->{IfNotExistsRegistHistory} = 1;
    }

    undef($aryref);

    #********************************
    # �A�N�Z�X���𒼋�2����
    #********************************
    #my $thismonth = MyClass::WebUtil::GetTime("9"); # yyyymm
    my $thismonth = MyClass::WebUtil::GetTime("11"); # mm
    my $tAccessLogF = 'tAccessLogF_' . $thismonth;
    my $ssql = "SELECT DISTINCT(DATE_FORMAT(in_datetime, '%y/%m/%d %H:%I')) AS in_date FROM "
             . $tAccessLogF
             . " WHERE guid=?
  AND (MONTH(in_datetime) BETWEEN MONTH(DATE_SUB(NOW(), INTERVAL 1 MONTH)) AND MONTH(NOW()))
 ORDER BY in_date DESC;";

    $aryref = $dbh->selectall_arrayref($ssql, { Columns => {} }, $guid);

    $obj->{LoopAccessHistoryList} = $#{ $aryref };

    if (0 <= $#{$aryref}) {
        $obj->{IfExistsAccessHistory} = 1;
        for (my $i = 0; $i <= $#{$aryref}; $i++) {
            map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{$aryref};
        }
    }
     else {
        $obj->{IfNotExistsAccessHistory} = 1;
    }

    if ( 2 == $obj->{mailstatus_flag} ) {
        my $cmsMailAddressLog = MyClass::JKZDB::MailAddressLog->new($dbh);
        my $maillog = $cmsMailAddressLog->fetchMailAddressLogByGUID($obj->{guid});

        if (defined($maillog)) {
            $obj->{LoopMailAddressLogList} = $#{ $maillog };
            $obj->{IfExistsMailAddressLog} = 1;

            foreach my $i (0..$#{ $maillog }) {
                map { $obj->{$_}->[$i] = $maillog->[$i]->{$_} } keys %{ $maillog };
                $obj->{mailregistration_date}->[$i] = MyClass::WebUtil::formatDateTimeSeparator($obj->{mailregistration_date}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 14});
                1 == $obj->{type_flag}->[$i] ? $obj->{IfRegistMailAddress}->[$i] = 1 : $obj->{IfModifyMailAddress}->[$i] = 1;
            }
        }
    }

    #********************************
    # �|�C���g�����̎擾 ����5��
    #********************************
    my $cmsPointLog = MyClass::JKZDB::PointLog->new($dbh);
## Modified 2010/02/25
=pod
    $aryref = $cmsPointLog->getSpecificValuesSQL({
        columnslist        => [
            'id', 'type_of_point', 'point', 'registration_date',
        ],
        whereSQL    => 'guid=?',
        orderbySQL  => 'registration_date DESC',
        placeholder => ["$guid"],
    });
=cut
    $aryref = $cmsPointLog->getSpecificValuesSQL({
        columnslist        => [
            'id', 'type_of_point', 'point', 'registration_date',
        ],
        whereSQL    => 'owid=?',
        orderbySQL  => 'registration_date DESC',
        placeholder => ["$owid"],
    });



    $obj->{LoopPointHistoryList} = $#{ $aryref->{id} };
    if (0 <= $obj->{LoopPointHistoryList}) {
        $obj->{IfExistsPointHistory} = 1;

        map {
            my $i = $_;
            foreach my $key (keys %{ $aryref }) {
               $obj->{$key}->[$i] = $aryref->{$key}->[$i];
            }
            $obj->{IfMinusPoint}->[$i]        = 1 if 8 == $aryref->{type_of_point}->[$i] || 32 == $aryref->{type_of_point}->[$i];
            $obj->{IfPlusPoint}->[$i]         = 1 if !$obj->{IfMinusPoint}->[$i];
            $obj->{p_registration_date}->[$i] = MyClass::WebUtil::formatDateTimeSeparator($obj->{registration_date}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 14});
            $obj->{point}->[$i]               = MyClass::WebUtil::insertComma($obj->{point}->[$i]);
        } 0..$obj->{LoopPointHistoryList};

        ## ���݂̏����߲��
        #$obj->{POINTNOW} = $pointnow;
    } else {
        $obj->{IfNotExistsPointHistory} = 1;
    }

    undef($aryref);

    #********************************
    # �w�������̎擾 ����5��
    #********************************
=pod Modified 2010/02/04
    my $sql = "SELECT d.order_date, df.tanka,df.qty,SUM(df.tanka*df.qty) AS goukei, p.product_name 
  FROM JKZ_WAF.tOrderDataF d, JKZ_WAF.tOrderDetailF df, tProductM p
   WHERE (d.guid=? AND d.ordernum=df.ordernum) AND p.product_id=df.product_id
 GROUP BY d.ordernum ORDER BY d.order_date DESC LIMIT 5;
";
    my $sql = "SELECT d.order_date, df.point AS product_point, df.qty,SUM(df.point*df.qty) AS goukei, p.product_name 
  FROM JKZ_WAF.tOrderDataF d, JKZ_WAF.tOrderDetailF df, tProductM p
   WHERE (d.guid=? AND d.ordernum=df.ordernum) AND p.product_id=df.product_id
 GROUP BY d.ordernum ORDER BY d.order_date DESC;
";
=cut

=pod
    my $sql = "SELECT d.order_date, df.point AS product_point, df.qty,SUM(df.point*df.qty) AS goukei, p.product_name 
  FROM JKZ_WAF.tOrderDataF d, JKZ_WAF.tOrderDetailF df LEFT JOIN JKZ_WAF.tProductM p
   ON df.product_id=p.product_id
   WHERE d.owid=? AND df.ordernum=d.ordernum
 GROUP BY d.ordernum
  ORDER BY d.order_date DESC;
";

    my $sql = "SELECT d.order_date, df.point AS product_point, df.qty, p.product_name 
  FROM JKZ_WAF.tOrderDataF d, JKZ_WAF.tOrderDetailF df LEFT JOIN JKZ_WAF.tProductM p
   ON df.product_id=p.product_id
   WHERE d.owid=? AND df.ordernum=d.ordernum
  ORDER BY d.order_date DESC;";

=cut
    my $sql = sprintf("SELECT d.order_date, d.ordernum, SUM(df.point*df.qty) AS sum_point
  FROM %s.tOrderDataF d, %s.tOrderDetailF df
   WHERE d.owid=? AND df.ordernum=d.ordernum
   GROUP BY d.ordernum
  ORDER BY d.order_date DESC;
", $namespace, $namespace);

    $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $owid);

    $obj->{LoopPurchaseHistoryList} = $#{ $aryref };

    if (0 <= $#{$aryref}) {
        $obj->{IfExistsPurchaseHistory} = 1;
=pod
        for (my $i = 0; $i <= $#{$aryref}; $i++) {
            map { $obj->{$_}->[$i] = $aryref->[$i]->{$_} } keys %{$aryref};
            $obj->{order_date}->[$i]    = MyClass::WebUtil::formatDateTimeSeparator($obj->{order_date}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 14});
            $obj->{goukei}->[$i]        = MyClass::WebUtil::insertComma($obj->{goukei}->[$i]);
        }
=cut
        map {
            my $i = $_;
            foreach my $key (keys %{ $aryref }) {
                $obj->{$key}->[$i] = $aryref->[$i]->{$key};
            }
            $obj->{order_date}->[$i] = MyClass::WebUtil::formatDateTimeSeparator($obj->{order_date}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 14});
            $obj->{sum_point}->[$i]  = MyClass::WebUtil::insertComma($obj->{sum_point}->[$i]);
            #$obj->{goukei}->[$i]     = $obj->{product_point}->[$i] * $obj->{qty}->[$i];
            #$obj->{goukei}->[$i]     = MyClass::WebUtil::insertComma(($obj->{goukei}->[$i]));
            #$obj->{product_point}->[$i]      = MyClass::WebUtil::insertComma($obj->{product_point}->[$i]);

        } 0..$obj->{LoopPurchaseHistoryList};

    }
     else {
        $obj->{IfNotExistsPurchaseHistory} = 1;
    }

## Modified ���݉��L���e�͕s�v�̂��߃R�����g�A�E�g 2009/08/11 END

    return $obj;
}


#******************************************************
# @access    public
# @desc        ����f�[�^�X�V
# @param    
# @return    
#******************************************************
sub updateMemberData {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};
    ## �s���h�~
    my $skey = $q->param('skey');

    my ($guid, $HHMM) = MyClass::WebUtil::decodeMD5($skey);

    unless ( $q->MethPost() || $guid) {
        ## ���폈�����s�s��
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG98');
        return $obj;
    }
    else {
        ## ���N�����̌v�Z
        if ($q->param('year_of_birth') ne "") {
            if ($q->param('month_of_birth') ne "" && 13 > $q->param('month_of_birth')) {
                if ($q->param('date_of_birth') ne "" && 32 > $q->param('date_of_birth')) {
                    my $birthday = sprintf ("%04d-%02d-%02d",$q->param('year_of_birth'), $q->param('month_of_birth'), $q->param('date_of_birth'));
                    $obj->{yourAge} = !($birthday = MyClass::WebUtil::calculateAge($birthday)) ? "" : $birthday;
                }
            }
        }

        $obj->{ERROR_MSG} .= $self->ERROR_MSG('ERR_MSG4') if $obj->{yourAge} eq "";
        ## Modified �j�b�N�l�[���ǉ� 2010/03/18
        my $nickname          = $q->param('nickname');
        my $family_name       = $q->param('family_name');
        my $first_name        = $q->param('first_name');
        my $family_name_kana  = $q->param('family_name_kana');
        my $first_name_kana   = $q->param('first_name_kana');
        my $sex               = (2 ** $q->param('sex'));
        my $year_of_birth     = $q->param('year_of_birth')  || undef;
        my $month_of_birth    = $q->param('month_of_birth') || undef;
        my $date_of_birth     = $q->param('date_of_birth')  || undef;
        my $personality       = (2 ** $q->param('personality'));
        my $bloodtype         = (2 ** $q->param('bloodtype'));
        my $occupation        = (2 ** $q->param('occupation'));
        my $prefecture        = (2 ** $q->param('prefecture'));
        my $zip               = MyClass::WebUtil::formatToNumber($q->param('zip'));
        my $city              = $q->param('city');
        my $street            = $q->param('street');
        my $address           = $q->param('address');
        my $tel               = MyClass::WebUtil::formatToNumber($q->param('tel'));


        ## Modified guid�������ɉ�����̍X�V�ɕύX 2009/09/08 BEGIN
        my $updateData = {
            guid    => $guid,
            columns => {
                nickname          => $nickname,
                family_name       => $family_name,
                first_name        => $first_name,
                family_name_kana  => $family_name_kana,
                first_name_kana   => $first_name_kana,
                personality       => $personality,
                bloodtype         => $bloodtype,
                occupation        => $occupation,
                sex               => $sex,
                year_of_birth     => $year_of_birth,
                month_of_birth    => $month_of_birth,
                date_of_birth     => $date_of_birth,
                prefecture        => $prefecture,
                zip               => $zip,
                city              => $city,
                street            => $street,
                address           => $address,
                tel               => $tel,
            },
        };

        my $dbh = $self->getDBConnection();
        my $myMember = MyClass::JKZDB::Member->new($dbh);
        ## �g�����U�N�V�����J�n
        my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);
        eval {
            $myMember->updateMemberDataByGUIDSQL($updateData);
            $dbh->commit();
        };
        ## ���s�̃��[���o�b�N
        if ($@) {
            $dbh->rollback();
            $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG8');
            $obj->{IfUpdateProfileFail} = 1;
        } else {
            $obj->{IfUpdateProfileSuccess} = 1;
        }
        MyClass::UsrWebDB::TransactFin($dbh,$attr_ref,$@);
    }

    return $obj;
}


#******************************************************
# type_of_point 1/2/4/16 ����׽ 8/32��ϲŽ ���i�w����ϲŽ
# 16 �Ǘ��ɂ��v���X 32�Ǘ��ɂ��}�C�i�X
#******************************************************
sub updateMemberPoint {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};
    ## �s���h�~
    my $skey = $q->param('skey');
    my ($guid, $HHMM) = MyClass::WebUtil::decodeMD5($skey);
    my $owid = $q->param('owid');

    unless ( $q->MethPost() || $guid) {
        ## ���폈�����s�s��
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG98');
        return $obj;
    }
    else {
        my $operator     = [ 
            { operator => '+', type_of_point => 16 },
            { operator => '-', type_of_point => 32 },
                           ];
            
        my $addpoint     = $q->param('addpoint');
        my $controlpoint = $q->param('controlpoint');
        my $dbh          = $self->getDBConnection();
        my $attr_ref     = MyClass::UsrWebDB::TransactInit($dbh);
        my $cmsMember    = MyClass::JKZDB::Member->new($dbh);
        my $cmsPointLog  = MyClass::JKZDB::PointLog->new($dbh);

        eval {
            $cmsMember->updatePointSQL({
                        owid     => $owid,
                        point    => $addpoint,
                        operator => $operator->[$controlpoint-1]->{operator},
             });
            $addpoint = sprintf("%s%d", $operator->[$controlpoint-1]->{operator}, $addpoint);
            $cmsPointLog->executeUpdate({
                        id            => -1,
                        owid          => $owid,
                        guid          => $guid,
                        type_of_point => $operator->[$controlpoint-1]->{type_of_point},
                        point         => $addpoint,
            });

            $dbh->commit();
        };
        ## ���s�̃��[���o�b�N
        if ($@) {
            $dbh->rollback();
            $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG8');
            $obj->{IfUpdateMemberPointFail} = 1;
        } else {
            $obj->{IfUpdateMemberPointSuccess} = 1;
        }
        MyClass::UsrWebDB::TransactFin($dbh,$attr_ref,$@);
    }

    $self->action('updateMemberData');

    return $obj;
}


#******************************************************
# @desc     �����Ԃ̕ύX
# @param    
# @return   
#******************************************************
sub updateStatus {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};
    ## �s���h�~
    my $skey = $q->param('skey');

    my ($guid, $HHMM) = MyClass::WebUtil::decodeMD5($skey);

    unless ( $q->MethPost() || $guid) {
        ## ���폈�����s�s��
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG98');
        return $obj;
    }
    else {
        my $dbh              = $self->getDBConnection();
        my $attr_ref         = MyClass::UsrWebDB::TransactInit($dbh);
        my $cmsMember        = MyClass::JKZDB::Member->new($dbh);
        my $cmsUserRegistLog = MyClass::JKZDB::UserRegistLog->new($dbh);

        eval {
            $cmsMember->updateMemberStatus($guid);
## ��肠�����Ǘ����������̒l�͂W
            $cmsUserRegistLog->executeUpdate({
                    id          => -1,
                    guid        => $guid,
                    status_flag => 8,
            });

            $dbh->commit();
        };
        ## ���s�̃��[���o�b�N
        if ($@) {
            $dbh->rollback();
            $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG8');
            $obj->{IfUpdateMemberStatusFail} = 1;
        } else {
            $obj->{IfUpdateMemberStatusSuccess} = 1;
        }
        MyClass::UsrWebDB::TransactFin($dbh,$attr_ref,$@);
    }
    $self->action('updateMemberStatus');
    return $obj;
}


#******************************************************
# @desc     ����̉����ʂ̕ύX�s���o�^�������
# @param    
# @return   
#******************************************************
sub updateMemberStatus {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};
    ## �s���h�~
    my $skey = $q->param('skey');

    my ($guid, $HHMM) = MyClass::WebUtil::decodeMD5($skey);

    unless ( $q->MethPost() || $guid) {
        ## ���폈�����s�s��
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG98');
        return $obj;
    }
    else {

        my $dbh      = $self->getDBConnection();
        my $attr_ref = MyClass::UsrWebDB::TransactInit($dbh);
        my $myMember = MyClass::JKZDB::Member->new($dbh);
        eval {
            $myMember->updateMemberStatus_to_IllegalMember($guid);
            $dbh->commit();
        };
        ## ���s�̃��[���o�b�N
        if ($@) {
            $dbh->rollback();
            $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG8');
            $obj->{IfUpdateMemberStatusFail} = 1;
        } else {
            $obj->{IfUpdateMemberStatusSuccess} = 1;
        }
        MyClass::UsrWebDB::TransactFin($dbh,$attr_ref,$@);
    }

    return $obj;
}


#******************************************************
# @access    private
# @desc        ������̎擾
# @param    interger $mid
# @return    
#******************************************************
sub _getMemberData {
    #my ($self, $mid) = @_;
    my ($self, $searchobj) = @_;

    my $dbh = $self->getDBConnection();
    my $myMember = MyClass::JKZDB::Member->new($dbh);
=pod
    if (!$myMember->executeSelect ({
        whereSQL    => 'mid=?',
        placeholder    => ["$mid"],
    })) {
        return 0;
    }
=cut

    if (!$myMember->executeSelect ({
        whereSQL    => $searchobj->{whereSQL},
        placeholder    => [$searchobj->{placeholder},],
    })) {
        return 0;
    }

    return $myMember;
}


1;
__END__
