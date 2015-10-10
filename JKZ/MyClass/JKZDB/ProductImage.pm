#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::ProductImage
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Thu Jan  7 12:48:05 2010
# @version	1.30
# @update	2008/05/30 executeUpdate処理の戻り値部分
# @update	2008/03/31 JKZ::DB::JKZDBのサブクラス化
# @update	2009/02/02 ディレクトリ構成をJKZ::JKZDBに変更
# @update	2009/02/12 リスティング処理を追加
# @update	2009/09/28 executeUpdateメソッドの処理変更
# @update   2010/01/22 checkRecordメソッドに機能追加
# @version	1.10
# @version	1.20
# @version	1.30
#******************************************************
package MyClass::JKZDB::ProductImage;

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
	my $table = 'OMP.tProductImageM';
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
$self->{columnslist}->{productm_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{image}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{image1}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{image2}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{mime_type}->[$i] = $aryref->[$i]->[5];
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
$self->{columns}->{productm_id},
$self->{columns}->{image},
$self->{columns}->{image1},
$self->{columns}->{image2},
$self->{columns}->{mime_type}
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
	$self->{columns}->{productm_id} = $param->{productm_id};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
#	if ($self->{columns}->{productm_id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{id} ) if $param->{id} > 0;
		push( @{ $sqlref->[0] }, "productm_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{productm_id} ) if $param->{productm_id} != "";
		push( @{ $sqlref->[0] }, "image" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{image} ) if $param->{image} ne "";
		push( @{ $sqlref->[0] }, "image1" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{image1} ) if $param->{image1} ne "";
		push( @{ $sqlref->[0] }, "image2" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{image2} ) if $param->{image2} ne "";
		push( @{ $sqlref->[0] }, "mime_type" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{mime_type} ) if $param->{mime_type} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("REPLACE INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value
=pod
	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE productm_id= '$self->{columns}->{productm_id}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}
=cut
## Modified 2009/09/29 END
}


#******************************************************
# @access	public
# @desc		レコード削除
# @param	
# @return	boolean
#******************************************************
sub deleteImageSQL {
	my $self = shift;
	my $ref = shift;
	#my $placeholder = shift || return undef;

	my $sql = sprintf "DELETE FROM %s WHERE productm_id=? AND id=?;", $self->table;
	my $rv = $self->{this_dbh}->do($sql, undef, $ref->{productm_id}, $ref->{id});
	return $rv;
}


#******************************************************
# @access	public
# @desc		primary_keyを条件にレコードの検索
# @param	primary key $productm_id 
# @param    anything 1
# @return	return value depends on case  1 or count of records
#******************************************************
sub checkRecord {
	my $self = shift;
    my ($productm_id, $opt) = @_;

    return if !$productm_id;

    my $sql = sprintf("SELECT %s FROM %s WHERE productm_id=?", ( $opt ? "COUNT(productm_id)" : "1" ), $self->table);

    my $rv = $self->{this_dbh}->selectrow_array($sql, undef, $productm_id);

=pod
	my $param = shift || return undef;
	my $sql = ( 'HASH' eq ref $param ) : "SELECT COUNT(productm_id)" : "SELECT 1";
	
	#my $sql = sprintf "SELECT 1 FROM %s WHERE productm_id=?;", $self->table;

	if (!$self->{this_dbh}->selectrow_array($sql, undef, $productm_id)) {
		return undef;
	}
	return 1;
=cut
}


1;

