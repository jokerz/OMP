#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::Affiliate
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Thu Jan  7 12:47:37 2010
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
package MyClass::JKZDB::Affiliate;

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
	my $table = 'OMP.tAffiliateM';
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
$self->{columnslist}->{acd}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{valid_date}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{expire_date}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{param_name1}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{param_name2}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{return_url}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{access_url}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{client_name}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{price}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{comment}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[12];
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
$self->{columns}->{acd},
$self->{columns}->{status_flag},
$self->{columns}->{valid_date},
$self->{columns}->{expire_date},
$self->{columns}->{param_name1},
$self->{columns}->{param_name2},
$self->{columns}->{return_url},
$self->{columns}->{access_url},
$self->{columns}->{client_name},
$self->{columns}->{price},
$self->{columns}->{comment},
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
		#エラー処理
	}

	$self->{columns}->{acd} = $param->{acd};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	#if ($self->{columns}->{acd} < 0) {}
	if (0 > $flag) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "acd" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{acd} ) if $param->{acd} ne "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "valid_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{valid_date} ) if $param->{valid_date} ne "";
		push( @{ $sqlref->[0] }, "expire_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{expire_date} ) if $param->{expire_date} ne "";
		push( @{ $sqlref->[0] }, "param_name1" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{param_name1} ) if $param->{param_name1} ne "";
		push( @{ $sqlref->[0] }, "param_name2" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{param_name2} ) if $param->{param_name2} ne "";
		push( @{ $sqlref->[0] }, "return_url" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{return_url} ) if $param->{return_url} ne "";
		push( @{ $sqlref->[0] }, "access_url" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{access_url} ) if $param->{access_url} ne "";
		push( @{ $sqlref->[0] }, "client_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{client_name} ) if $param->{client_name} ne "";
		push( @{ $sqlref->[0] }, "price" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{price} ) if $param->{price} != "";
		push( @{ $sqlref->[0] }, "comment" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{comment} ) if $param->{comment} ne "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
		#push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE acd= '$self->{columns}->{acd}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


#******************************************************
# @desc		広告コードチェック 有効期限のチェック
# @access	public
# @param
# @return	boolean 1 or undef
#******************************************************
sub validatetionSQL {
	my $self = shift;
	my $acd  = shift || return undef;
	my $sql  = sprintf("SELECT return_url FROM %s WHERE acd=? AND valid_date <= CURDATE() AND expire_date >= CURDATE()", $self->table);
	$self->{columns}->{return_url} = $self->{this_dbh}->selectrow_array($sql, undef, $acd);

	return 1;
}


#******************************************************
# @desc		広告コードチェック 戻り値に成果送信先URL
# @access	public
# @param
# @return	return_url or undef
#******************************************************
sub fetchReturnUrl {
	my $self = shift;
	my $acd  = shift || return undef;
	my $sql  = sprintf("SELECT return_url FROM %s WHERE acd=? AND valid_date <= CURDATE() AND expire_date >= CURDATE() AND status_flag=2", $self->table);
	$self->{columns}->{return_url} = $self->{this_dbh}->selectrow_array($sql, undef, $acd);

	return $self->{columns}->{return_url};
}


#******************************************************
# @desc		広告コードチェック 戻り値に成果送信先URLと受信パラメータ名を
# @access	public
# @param
# @return	ref {param_name1 , return_url} or undef
#******************************************************
sub fetchParameNameAndReturnUrl {
	my $self = shift;
	my $acd  = shift || return undef;
	my $sql  = sprintf("SELECT param_name1, return_url FROM %s WHERE acd=? AND valid_date <= CURDATE() AND expire_date >= CURDATE() AND status_flag=2", $self->table);

	my $ref;
	if ( ($ref->{param_name1}, $ref->{return_url}) = $self->{this_dbh}->selectrow_array($sql, undef, $acd) ) {
		return $ref;
	}
	else { return undef; }
}


#******************************************************
# @desc		広告の状態を更新。現在の状態の逆の状態にする
# @			status_flagが１なら２に２なら１にする
# @access	public
# @param	char $acd
# @return	boolean
#******************************************************
sub reverseupdateStatus {
	my $self = shift;
	my $acd  = shift || return undef;
	my $sql  = sprintf(" UPDATE %s
 SET status_flag = CASE WHEN status_flag=1
 							THEN 2
 						WHEN status_flag=2
 							THEN 1
 					ELSE status_flag END
 WHERE acd=?;", $self->table);

	my $rv = $self->{this_dbh}->do($sql, undef, $acd);
	return (($rv eq '0E0') ? undef : 1);

}


1;

