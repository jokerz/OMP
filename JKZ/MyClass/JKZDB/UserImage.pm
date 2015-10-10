#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::UserImage
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY createClassDB
# @create	Fri Jun 11 19:26:08 2010
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
package MyClass::JKZDB::UserImage;

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
	my $table = 'OMP.tUserImageF';
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
$self->{columnslist}->{id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{owid}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{image}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{thumbnail_320}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{thumbnail_200}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{thumbnail_64}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{mime_type}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[7];
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
$self->{columns}->{id},
$self->{columns}->{owid},
$self->{columns}->{image},
$self->{columns}->{thumbnail_320},
$self->{columns}->{thumbnail_200},
$self->{columns}->{thumbnail_64},
$self->{columns}->{mime_type},
$self->{columns}->{lastupdate_date}
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
	my ($self, $param) = @_;

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

	$self->{columns}->{owid} = $param->{owid};

	## ������PrimaryKey���ݒ肳��Ă���ꍇ��Update
	## �ݒ肪�Ȃ��ꍇ��Insert
	if ($self->{columns}->{owid} < 0) {
		##1. AutoIncrement�łȂ��ꍇ�͂����ōő�l���擾
		##2. �}�� 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{id} ) if $param->{id} != "";
		push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
		push( @{ $sqlref->[0] }, "image" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{image} ) if $param->{image} ne "";
		push( @{ $sqlref->[0] }, "thumbnail_320" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{thumbnail_320} ) if $param->{thumbnail_320} ne "";
		push( @{ $sqlref->[0] }, "thumbnail_200" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{thumbnail_200} ) if $param->{thumbnail_200} ne "";
		push( @{ $sqlref->[0] }, "thumbnail_64" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{thumbnail_64} ) if $param->{thumbnail_64} ne "";
		push( @{ $sqlref->[0] }, "mime_type" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{mime_type} ) if $param->{mime_type} ne "";
		push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE owid= '$self->{columns}->{owid}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


1;

