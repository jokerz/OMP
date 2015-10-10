#******************************************************
# @desc      Apache::Session��MySQL�ŃZ�b�V�������Ǘ�����
# @package   MyClass::Session
# @access    public
# @author    Iwahase Ryo
# @create    2006/05/15
# @version   1.00
#******************************************************
package MyClass::Session;

use strict;
use DBI;
use Apache::Session::MySQL;

$MyClass::Session::errstr = "";


#******************************************************
# @desc     �R���X�g���N�^ session���J�n���܂�
# @access   public
# @param    $dbhandle
#           $session_id
# @return        
#******************************************************
sub open {
    my ($type, $dbh, $sess_id) = @_;
    my %session;
    my %attr;

    #my $dsn = "DBI:mysql:host=localhost;database=devil;mysql_read_default_group=dbdmysql;mysql_read_default_file=/etc/my.cnf";
    #my $dsn = "DBI:mysql:host=localhost;database=ApacheSession";
    my $dsn = "DBI:mysql:host=localhost;database=dOMP";
    my $user_name = "dbmaster";
    my $password = "h2g8p200";

    if (defined ($dbh))    {
        %attr = (
                Handle     => $dbh,
                LockHandle => $dbh
        );
    }
    else {
        %attr = (
                DataSource     => $dsn,
                UserName       => $user_name,
                Password       => $password,
                LockDataSource => $dsn,
                LockUserName   => $user_name,
                LockPassword   => $password
        );
    }
    eval {
        tie %session, "Apache::Session::MySQL", $sess_id, \%attr;
    };
    if ($@) {
        $MyClass::Session::errstr = $@;
        return undef;
    }

    return (bless (\%session, $type));
}


#******************************************************
# @desc        �L�������t����session���J�n���܂�
# @access    public
# @param    $dbhandle
#            $session_id
# @return    
#******************************************************
sub open_with_expiration {
    my $self = &open (@_);

    if (defined($self) && defined ($self->expires()) && $self->expires () < $self->now()) {
        $MyClass::Session::errstr = sprintf ("Session %s has expired", $self->session_id());
        $self->delete();
        $self = undef;
    }

    return ($self);
}


#******************************************************
# @desc      �A�N�Z�b�T���\�b�h
#            ������1�̏ꍇ�̓Z�b�V�������ڂ�ݒ�
#            ������2�̏ꍇ�̓Z�b�V�������ڂɒl��ݒ�
# @access    public
# @param     $string_name
#            $string_value
# @return    
#******************************************************
sub attr {
    my $self = shift;

    return (undef) unless @_;
    $self->{$_[0]} = $_[1] if @_ > 1;

    return ($self->{$_[0]});
}


#******************************************************
# @desc        �Z�b�V����ID��Ԃ�
# @access    public
# @param    
# @return    session_id
#******************************************************
sub session_id {
    my $self = shift;

    return ($self->{_session_id});
}


#******************************************************
# @desc        
# @access    private
# @param    
# @return    
#******************************************************
sub expires_1 {
    my $self = shift;

    return ($self->attr ("#<expires>#", @_));
}

use Time::Local;


#******************************************************
# @desc        �L��������ݒ�
# @access    public
# @param    
# @return    
#******************************************************
sub expires {
    my $self = shift;
    my $expires;

    $self->{"#<expires>#"} = [ gmtime ($_[0]) ] if @_;
    #$self->{"#<expires>#"} = [ $_[0] ] if @_;

    #$expires = $self->{"#<expires>#"};
    $expires = timegm (@{$expires}) if defined ($expires);

    return ($expires);
}


#******************************************************
# @desc        ���݂̎���
# @access    public
# @param    
# @return    time
#******************************************************
sub now { return (time()); }


#******************************************************
# @desc        �Z�b�V��������܂�/session_id��������
#            �Z�b�V������open�ōēx�Z�b�V�����𕜌�
# @access    public
# @param    
# @return    
#******************************************************
sub close {
    my $self = shift;

    untie (%{$self});
}


#******************************************************
# @desc        �Z�b�V�������폜
#            �폜�����Z�b�V�����ւ͍ăA�N�Z�X�ł��Ȃ�
# @access    public
# @param    
# @return    time
#******************************************************
sub delete {
    my $self = shift;

    tied (%{$self})->delete();
}

1;
