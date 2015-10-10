#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::Product
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Thu Jan  7 12:48:08 2010
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
package MyClass::JKZDB::Product;

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
	my $table = 'OMP.tProductM';
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
$self->{columnslist}->{product_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{charge_flag}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{point_flag}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{latest_flag}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{recommend_flag}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{product_name}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{product_code}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{categorym_id}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{subcategorym_id}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{smallcategorym_id}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{description}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{description_detail}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{genka}->[$i] = $aryref->[$i]->[13];
$self->{columnslist}->{tanka}->[$i] = $aryref->[$i]->[14];
$self->{columnslist}->{tanka_notax}->[$i] = $aryref->[$i]->[15];
$self->{columnslist}->{teika}->[$i] = $aryref->[$i]->[16];
$self->{columnslist}->{tmplt_id}->[$i] = $aryref->[$i]->[17];
$self->{columnslist}->{point}->[$i] = $aryref->[$i]->[18];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[19];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[20];
$self->{columnslist}->{stock}->[$i] = $aryref->[$i]->[21];
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
$self->{columns}->{product_id},
$self->{columns}->{status_flag},
$self->{columns}->{charge_flag},
$self->{columns}->{point_flag},
$self->{columns}->{latest_flag},
$self->{columns}->{recommend_flag},
$self->{columns}->{product_name},
$self->{columns}->{product_code},
$self->{columns}->{categorym_id},
$self->{columns}->{subcategorym_id},
$self->{columns}->{smallcategorym_id},
$self->{columns}->{description},
$self->{columns}->{description_detail},
$self->{columns}->{genka},
$self->{columns}->{tanka},
$self->{columns}->{tanka_notax},
$self->{columns}->{teika},
$self->{columns}->{tmplt_id},
$self->{columns}->{point},
$self->{columns}->{registration_date},
$self->{columns}->{lastupdate_date},
$self->{columns}->{stock}
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

	$self->{columns}->{product_id} = $param->{product_id};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{product_id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "product_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{product_id} ) if $param->{product_id} != "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "charge_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{charge_flag} ) if $param->{charge_flag} != "";
		push( @{ $sqlref->[0] }, "point_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point_flag} ) if $param->{point_flag} != "";
		push( @{ $sqlref->[0] }, "latest_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{latest_flag} ) if $param->{latest_flag} != "";
		push( @{ $sqlref->[0] }, "recommend_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{recommend_flag} ) if $param->{recommend_flag} != "";
		push( @{ $sqlref->[0] }, "product_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{product_name} ) if $param->{product_name} ne "";
		push( @{ $sqlref->[0] }, "product_code" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{product_code} ) if $param->{product_code} ne "";
		push( @{ $sqlref->[0] }, "categorym_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{categorym_id} ) if $param->{categorym_id} != "";
		push( @{ $sqlref->[0] }, "subcategorym_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subcategorym_id} ) if $param->{subcategorym_id} != "";
		push( @{ $sqlref->[0] }, "smallcategorym_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{smallcategorym_id} ) if $param->{smallcategorym_id} != "";
		push( @{ $sqlref->[0] }, "description" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{description} ) if $param->{description} ne "";
		push( @{ $sqlref->[0] }, "description_detail" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{description_detail} ) if $param->{description_detail} ne "";
		push( @{ $sqlref->[0] }, "genka" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{genka} ) if $param->{genka} != "";
		push( @{ $sqlref->[0] }, "tanka" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{tanka} ) if $param->{tanka} != "";
		push( @{ $sqlref->[0] }, "tanka_notax" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{tanka_notax} ) if $param->{tanka_notax} != "";
		push( @{ $sqlref->[0] }, "teika" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{teika} ) if $param->{teika} != "";
		push( @{ $sqlref->[0] }, "tmplt_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{tmplt_id} ) if $param->{tmplt_id} != "";
		push( @{ $sqlref->[0] }, "point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point} ) if $param->{point} != "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
		push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";
		push( @{ $sqlref->[0] }, "stock" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{stock} ) if $param->{stock} != "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE product_id= '$self->{columns}->{product_id}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


1;

