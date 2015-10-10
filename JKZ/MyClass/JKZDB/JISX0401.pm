#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::JISX0401
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Fri Feb 12 18:42:39 2010
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
package MyClass::JKZDB::JISX0401;

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
	my $table = 'CommonUse.tJISX0401';
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
$self->{columnslist}->{prefecture_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{zipcode}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{jisx0401_0402}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{prefecture_kana}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{city_kana}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{street_kana}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{prefecture}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{city}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{street}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{flg1}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{flg2}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{flg3}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{flg4}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{flg5}->[$i] = $aryref->[$i]->[13];
$self->{columnslist}->{flg6}->[$i] = $aryref->[$i]->[14];
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
$self->{columns}->{prefecture_id},
$self->{columns}->{zipcode},
$self->{columns}->{jisx0401_0402},
$self->{columns}->{prefecture_kana},
$self->{columns}->{city_kana},
$self->{columns}->{street_kana},
$self->{columns}->{prefecture},
$self->{columns}->{city},
$self->{columns}->{street},
$self->{columns}->{flg1},
$self->{columns}->{flg2},
$self->{columns}->{flg3},
$self->{columns}->{flg4},
$self->{columns}->{flg5},
$self->{columns}->{flg6}
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
=pod このテーブルは読み取り専用のため
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

	$self->{columns}->{} = $param->{};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "prefecture_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{prefecture_id} ) if $param->{prefecture_id} != "";
		push( @{ $sqlref->[0] }, "zipcode" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{zipcode} ) if $param->{zipcode} ne "";
		push( @{ $sqlref->[0] }, "jisx0401_0402" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{jisx0401_0402} ) if $param->{jisx0401_0402} != "";
		push( @{ $sqlref->[0] }, "prefecture_kana" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{prefecture_kana} ) if $param->{prefecture_kana} ne "";
		push( @{ $sqlref->[0] }, "city_kana" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{city_kana} ) if $param->{city_kana} ne "";
		push( @{ $sqlref->[0] }, "street_kana" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{street_kana} ) if $param->{street_kana} ne "";
		push( @{ $sqlref->[0] }, "prefecture" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{prefecture} ) if $param->{prefecture} ne "";
		push( @{ $sqlref->[0] }, "city" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{city} ) if $param->{city} ne "";
		push( @{ $sqlref->[0] }, "street" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{street} ) if $param->{street} ne "";
		push( @{ $sqlref->[0] }, "flg1" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{flg1} ) if $param->{flg1} != "";
		push( @{ $sqlref->[0] }, "flg2" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{flg2} ) if $param->{flg2} != "";
		push( @{ $sqlref->[0] }, "flg3" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{flg3} ) if $param->{flg3} != "";
		push( @{ $sqlref->[0] }, "flg4" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{flg4} ) if $param->{flg4} != "";
		push( @{ $sqlref->[0] }, "flg5" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{flg5} ) if $param->{flg5} != "";
		push( @{ $sqlref->[0] }, "flg6" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{flg6} ) if $param->{flg6} != "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE = '$self->{columns}->{}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}
=cut


#******************************************************
# @desc		郵便場合から住所を検索
# @param	int  $zipcode
# @return	hashobj 戻りの名前をサイトの会員マスタのカラム名にあわせる。…最悪よ。
#******************************************************
sub fetchAddressByZipCode {
    my $self    = shift;
    my $zipcode = shift || return;
    return unless $zipcode =~ /[0-9]{7}/;

    my $sql = sprintf("SELECT 
 zipcode,
 prefecture_id,
 prefecture_kana,
 city_kana,
 street_kana,
 prefecture,
 city,
 street FROM %s WHERE zipcode=?;", $self->table, $zipcode);


    my $retref;
    (
     $retref->{zip},
     $retref->{prefecture},
     $retref->{prefecture_kana},
     $retref->{city_kana},
     $retref->{street_kana},
     $retref->{prefecture_name},
     $retref->{city},
     $retref->{street}
    ) = $self->{this_dbh}->selectrow_array($sql, undef, $zipcode);

#my $retref = $self->{this_dbh}->selectrow_array($sql, { Columns => {} }, $zipcode);

    return $retref;
}

1;

