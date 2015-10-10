#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::MessageOutBox
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY createClassDB
# @create	Fri Jun 11 19:25:59 2010
# @version	1.30
# @update	2008/05/30 executeUpdate�����̖߂�l����
# @update	2008/03/31 JKZ::DB::JKZDB�̃T�u�N���X��
# @update	2009/02/02 �f�B���N�g���\����JKZ::JKZDB�ɕύX
# @update	2009/02/12 ���X�e�B���O������ǉ�
# @update	2009/09/28 executeUpdate���\�b�h�̏����ύX
# @version	1.10
# @version	1.20
# @version	1.30
#******************************************************
package MyClass::JKZDB::MessageOutBox;

use 5.008005;
use strict;
our $VERSION ='1.30';

use base qw(MyClass::JKZDB);


#******************************************************
# @access	public
# @desc		�R���X�g���N�^
# @param	
# @return	
# @author	
#******************************************************
sub new {
	my ($class, $dbh) = @_;
	my $table = 'OMP.tMessageOutBoxF';
	return $class->SUPER::new($dbh, $table);
}


#******************************************************
# @access	
# @desc		SQL�����s���܂��B
# @param	$sql
#			@placeholder
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
$self->{columnslist}->{message_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{reply_message_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{sender_owid}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{recipient_owid}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{recipient_nickname}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{subject}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{message}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{send_date}->[$i] = $aryref->[$i]->[7];
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
$self->{columns}->{message_id},
$self->{columns}->{reply_message_id},
$self->{columns}->{sender_owid},
$self->{columns}->{recipient_owid},
$self->{columns}->{recipient_nickname},
$self->{columns}->{subject},
$self->{columns}->{message},
$self->{columns}->{send_date}
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
# @access	public
# @desc		���R�[�h�X�V����
#			�v���C�}���L�[�����ɂ����INSERT�Ȃ�����UPDATE�̏������s�Ȃ��܂��B
# @param	
# @return	
#******************************************************
sub executeUpdate {
	my ($self, $param, $flag) = @_;

	my $sqlMoji;
	#******************************************************
	# TYPE	: arrayreference
	#			[
	#			 [ columns name array],		0
	#			 [ placeholder array ],		1
	#			 [ values array		],		2
	#			]
	#******************************************************
	my $sqlref;
	my $rv;

	if ($self->{this_dbh} == "") {
		#�G���[����
	}

	$self->{columns}->{message_id} = $param->{message_id};

	## ������PrimaryKey���ݒ肳��Ă���ꍇ��Update
	## �ݒ肪�Ȃ��ꍇ��Insert
	#if ($self->{columns}->{message_id} < 0) {
		##1. AutoIncrement�łȂ��ꍇ�͂����ōő�l���擾
		##2. �}�� 
    if ($flag < 0) {
## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "message_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{message_id} ) if $param->{message_id} ne "";
		push( @{ $sqlref->[0] }, "reply_message_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{reply_message_id} ) if $param->{reply_message_id} ne "";
		push( @{ $sqlref->[0] }, "sender_owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sender_owid} ) if $param->{sender_owid} != "";
		push( @{ $sqlref->[0] }, "recipient_owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{recipient_owid} ) if $param->{recipient_owid} != "";
		push( @{ $sqlref->[0] }, "recipient_nickname" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{recipient_nickname} ) if $param->{recipient_nickname} ne "";
		push( @{ $sqlref->[0] }, "subject" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subject} ) if $param->{subject} ne "";
		push( @{ $sqlref->[0] }, "message" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{message} ) if $param->{message} ne "";
		push( @{ $sqlref->[0] }, "send_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{send_date} ) if $param->{send_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE message_id= '$self->{columns}->{message_id}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


1;

