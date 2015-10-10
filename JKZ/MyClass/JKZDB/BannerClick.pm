#******************************************************
# @desc        
#            
# @package    MyClass::JKZDB::BannerClick
# @access    public
# @author    Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create    Tue Jan 12 18:36:04 2010
# @version    1.30
# @update    2008/05/30 executeUpdate�����̖߂�l����
# @update    2008/03/31 JKZ::DB::JKZDB�̃T�u�N���X��
# @update    2009/02/02 �f�B���N�g���\����JKZ::JKZDB�ɕύX
# @update    2009/02/12 ���X�e�B���O������ǉ�
# @update    2009/09/28 executeUpdate���\�b�h�̏����ύX
# @version    1.10
# @version    1.20
# @version    1.30
#******************************************************
package MyClass::JKZDB::BannerClick;

use 5.008005;
use strict;
our $VERSION ='1.30';

use base qw(MyClass::JKZDB);


#******************************************************
# @access    public
# @desc        �R���X�g���N�^
# @param    
# @return    
# @author    
#******************************************************
sub new {
    my ($class, $dbh) = @_;
    my $table = 'OMP.tBannerClickF';
    return $class->SUPER::new($dbh, $table);
}


#******************************************************
# @access    
# @desc        SQL�����s���܂��B
# @param    $sql
#            @placeholder
# @return    
#******************************************************
sub executeQuery {
    my ($self, $sqlMoji, $placeholder) = @_;

    my ($package, $filename, $line, $subroutine) = caller(1);

    if ($subroutine =~ /executeSelectList/) {
        my $aryref = $self->{this_dbh}->selectall_arrayref($sqlMoji, undef, @$placeholder);

        $self->{reccnt} = $#{$aryref};
        for (my $i = 0; $i <= $self->{reccnt}; $i++) {
#************************ AUTO GENERATED BEGIN ************************
$self->{columnslist}->{owid}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{bannerm_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{bannerdatam_id}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{point_click}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{click}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{last_click}->[$i] = $aryref->[$i]->[5];
#************************ AUTO  GENERATED  END ************************
        }
    }
    elsif ($subroutine =~ /executeSelect$/) {
        my $sth = $self->{this_dbh}->prepare($sqlMoji);
        my $row = $sth->execute(@$placeholder);
        if (0==$row || !defined($row)) {
            return 0;
        } else {
#************************ AUTO GENERATED BEGIN ************************
            (
$self->{columns}->{owid},
$self->{columns}->{bannerm_id},
$self->{columns}->{bannerdatam_id},
$self->{columns}->{point_click},
$self->{columns}->{click},
$self->{columns}->{last_click}
            ) = $sth->fetchrow_array();
#************************ AUTO  GENERATED  END ************************
        }
        $sth->finish();
    } else {
        my $rc = $self->{this_dbh}->do($sqlMoji, undef, @$placeholder);
        return $rc;
    }
}


#******************************************************
# @access    public
# @desc        ���R�[�h�X�V����
#            �v���C�}���L�[�����ɂ����INSERT�Ȃ�����UPDATE�̏������s�Ȃ��܂��B
# @param    
# @return    
#******************************************************
sub executeUpdate {
    my ($self, $param, $flag) = @_;

    my $sqlMoji;
    #******************************************************
    # TYPE    : arrayreference
    #            [
    #             [ columns name array],        0
    #             [ placeholder array ],        1
    #             [ values array        ],        2
    #            ]
    #******************************************************
    my $sqlref;
    my $rv;

    if ($self->{this_dbh} == "") {
        #�G���[����
    }

    $self->{columns}->{owid}           = $param->{owid};
    $self->{columns}->{bannerm_id}     = $param->{bannerm_id};
    $self->{columns}->{bannerdatam_id} = $param->{bannerdatam_id};
    $self->{columns}->{point_click}    = $param->{point_click};
    ## ������PrimaryKey���ݒ肳��Ă���ꍇ��Update
    ## �ݒ肪�Ȃ��ꍇ��Insert
    #if ($self->{columns}->{point_click} < 0) {
    # flag�l��ݒ肵�ăC���T�[�g(-1)
    if ($flag < 0) {
        ##1. AutoIncrement�łȂ��ꍇ�͂����ōő�l���擾
        ##2. �}�� 

## Modified 2009/09/29 BEGIN

        #************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
        push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
        push( @{ $sqlref->[0] }, "bannerm_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bannerm_id} ) if $param->{bannerm_id} != "";
        push( @{ $sqlref->[0] }, "bannerdatam_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bannerdatam_id} ) if $param->{bannerdatam_id} != "";
        push( @{ $sqlref->[0] }, "point_click" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point_click} ) if $param->{point_click} ne "";
        push( @{ $sqlref->[0] }, "click" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{click} ) if $param->{click} != "";
        push( @{ $sqlref->[0] }, "last_click" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{last_click} ) if $param->{last_click} ne "";

        #************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

        $sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
        $rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

        return $rv; # return value

    } else {

        map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
        $sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE owid= '$self->{columns}->{owid}' AND bannerm_id= '$self->{columns}->{bannerm_id}' AND bannerdatam_id= '$self->{columns}->{bannerdatam_id}' AND point_click='$self->{columns}->{point_click}';", join('=?,', @{ $sqlref->[0] }));
        #$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
        $rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

        return $rv; # return value

    }

## Modified 2009/09/29 END
}


#******************************************************
# @desc     SET click=click+1�����s
# @param    
# @param    
# @return   
#******************************************************
sub updateClick {
    my $self = shift;
    my $args = shift;

    my $sqlMoji = sprintf("UPDATE %s SET click=click+1, last_click=NOW() WHERE owid=? AND bannerm_id=? AND bannerdatam_id =? AND point_click=?", $self->table);
    my $rc = $self->dbh->do($sqlMoji, undef, $args->{owid}, $args->{bannerm_id}, $args->{bannerdatam_id}, $args->{point_click}); 

    return $rc;
}


#******************************************************
# @access    
# @desc        �o�^�o�i�[�̌f�ڊ��Ԓ��̃��j�[�N�N���b�N(���P�ʂ̃��j�[�N�N���b�N���v)�E���v�N���b�N��
# @param    id1, id2 year
# @return    
#******************************************************
sub getSumOfUniqueClickAndClickByID_Period {
    my $self = shift;
    unless (@_) {
        ## �������Ȃ��ꍇ�̓G���[
        return;
    }
    my ($id1, $id2, $year) = @_;

    my $table = $self->switchMRG_MyISAMTableSQL({separater=>'_',value=>$year});
    my $sqlMoji = sprintf("SELECT COUNT(click) AS SUMUNIQUECLICK, SUM(click) AS SUMCLICK FROM %s WHERE bannerm_id=? AND bannerdatam_id=?;", $table);

    my @row = $self->dbh->selectrow_array($sqlMoji, undef, $id1, $id2);

    return (\@row);
}


1;

