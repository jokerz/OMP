#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::BannerData
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Tue Jan 12 18:36:30 2010
# @version	1.30
# @update	2008/05/30 executeUpdate処理の戻り値部分
# @update	2008/03/31 JKZ::DB::JKZDBのサブクラス化
# @update	2009/02/02 ディレクトリ構成をJKZ::JKZDBに変更
# @update	2009/02/12 リスティング処理を追加
# @update	2009/09/28 executeUpdateメソッドの処理変更
# @version	1.10
# @version	1.20
# @version	1.30
#******************************************************
package MyClass::JKZDB::BannerData;

use 5.008005;
use strict;
our $VERSION ='1.30';

use base qw(MyClass::JKZDB);


#******************************************************
# @access	public
# @desc		コンストラクタ
# @param	
# @return	
# @author	
#******************************************************
sub new {
	my ($class, $dbh) = @_;
	my $table = 'OMP.tBannerDataM';
	return $class->SUPER::new($dbh, $table);
}


#******************************************************
# @access	
# @desc		SQLを踀sします。
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
$self->{columnslist}->{bannerm_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{banner_name}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{point_flag}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{point}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{point_limit}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{valid_date}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{expire_date}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[9];
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
$self->{columns}->{bannerm_id},
$self->{columns}->{status_flag},
$self->{columns}->{banner_name},
$self->{columns}->{point_flag},
$self->{columns}->{point},
$self->{columns}->{point_limit},
$self->{columns}->{valid_date},
$self->{columns}->{expire_date},
$self->{columns}->{registration_date}
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
# @desc		レコード更新処理
#			プライマリキー条件によ・ﾄINSERTないしはUPDATEの処理を行ないます。
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
		#エラー処理
	}

    $self->{columns}->{id} = $param->{id};
	$self->{columns}->{bannerm_id} = $param->{bannerm_id};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設猪bない場合はInsert
	if ($self->{columns}->{id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を誌
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		#push( @{ $sqlref->[0] }, "id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{id} ) if $param->{id} != "";
		push( @{ $sqlref->[0] }, "bannerm_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bannerm_id} ) if $param->{bannerm_id} != "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "banner_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{banner_name} ) if $param->{banner_name} ne "";
		push( @{ $sqlref->[0] }, "point_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point_flag} ) if $param->{point_flag} != "";
		push( @{ $sqlref->[0] }, "point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point} ) if $param->{point} != "";
		push( @{ $sqlref->[0] }, "point_limit" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point_limit} ) if $param->{point_limit} != "";
		push( @{ $sqlref->[0] }, "valid_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{valid_date} ) if $param->{valid_date} ne "";
		push( @{ $sqlref->[0] }, "expire_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{expire_date} ) if $param->{expire_date} ne "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE bannerm_id= '$self->{columns}->{bannerm_id}' AND id='$self->{columns}->{id}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


1;

