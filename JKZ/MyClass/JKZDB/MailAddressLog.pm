#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::MailAddressLog
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Fri Jan  8 14:27:39 2010
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
package MyClass::JKZDB::MailAddressLog;

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
	my $table = 'OMP.tMailAddressLogF';
	return $class->SUPER::new($dbh, $table);
}


#******************************************************
# @access	
# @desc		SQLを実行します。
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
$self->{columnslist}->{guid}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{session_id}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{type_flag}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{former_mobilemailaddress}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{new_mobilemailaddress}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[8];
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
$self->{columns}->{guid},
$self->{columns}->{session_id},
$self->{columns}->{status_flag},
$self->{columns}->{type_flag},
$self->{columns}->{former_mobilemailaddress},
$self->{columns}->{new_mobilemailaddress},
$self->{columns}->{registration_date},
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
# @desc		レコード更新処理
#			プライマリキー条件によってINSERTないしはUPDATEの処理を行ないます。
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

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{id} ) if $param->{id} != "";
		push( @{ $sqlref->[0] }, "guid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{guid} ) if $param->{guid} ne "";
		push( @{ $sqlref->[0] }, "session_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{session_id} ) if $param->{session_id} ne "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "type_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{type_flag} ) if $param->{type_flag} != "";
		push( @{ $sqlref->[0] }, "former_mobilemailaddress" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{former_mobilemailaddress} ) if $param->{former_mobilemailaddress} ne "";
		push( @{ $sqlref->[0] }, "new_mobilemailaddress" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{new_mobilemailaddress} ) if $param->{new_mobilemailaddress} ne "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
		push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE id= '$self->{columns}->{id}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


#******************************************************
# @desc		guidを条件に会員メールアドレス登録・変更ログを取得
# @access	public
# @param
# @return	arrayref   @{$arrayref} $arrayref->[number]->{columns_name}
#******************************************************
sub fetchMailAddressLogByGUID {
	my $self = shift;
	my $guid = shift || return undef;

	my $sql = sprintf("SELECT type_flag, former_mobilemailaddress, new_mobilemailaddress, registration_date AS mailregistration_date FROM %s WHERE guid=?", $self->table);
	my $arrayref = $self->{this_dbh}->selectall_arrayref($sql, { Columns => {} }, $guid);

	return $arrayref;
}


1;

