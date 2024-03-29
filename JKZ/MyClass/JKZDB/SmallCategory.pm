#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::SmallCategory
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Thu Jan 21 12:18:17 2010
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
package MyClass::JKZDB::SmallCategory;

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
	my $table = 'OMP.tSmallCategoryM';
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
$self->{columnslist}->{smallcategory_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{categorym_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{subcategorym_id}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{smallcategory_name}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{subcategory_name}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{category_name}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{description}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[9];
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
$self->{columns}->{smallcategory_id},
$self->{columns}->{categorym_id},
$self->{columns}->{subcategorym_id},
$self->{columns}->{status_flag},
$self->{columns}->{smallcategory_name},
$self->{columns}->{subcategory_name},
$self->{columns}->{category_name},
$self->{columns}->{description},
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

	$self->{columns}->{smallcategory_id} = $param->{smallcategory_id};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{smallcategory_id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		#push( @{ $sqlref->[0] }, "smallcategory_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{smallcategory_id} ) if $param->{smallcategory_id} != "";
		push( @{ $sqlref->[0] }, "categorym_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{categorym_id} ) if $param->{categorym_id} != "";
		push( @{ $sqlref->[0] }, "subcategorym_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subcategorym_id} ) if $param->{subcategorym_id} != "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "smallcategory_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{smallcategory_name} ) if $param->{smallcategory_name} ne "";
		push( @{ $sqlref->[0] }, "subcategory_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subcategory_name} ) if $param->{subcategory_name} ne "";
		push( @{ $sqlref->[0] }, "category_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{category_name} ) if $param->{category_name} ne "";
		push( @{ $sqlref->[0] }, "description" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{description} ) if $param->{description} ne "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
		#push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE smallcategory_id= '$self->{columns}->{smallcategory_id}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


1;

