#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::OrderData
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Wed Feb  3 18:00:23 2010
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
package MyClass::JKZDB::OrderData;

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
	my $table = 'OMP.tOrderDataF';
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
$self->{columnslist}->{ordernum}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{guid}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{owid}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{orderstatus_flag}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{paymeth}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{mobilemailaddress}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{used_point}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{family_name}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{first_name}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{family_name_kana}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{first_name_kana}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{prefecture}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{zip}->[$i] = $aryref->[$i]->[13];
$self->{columnslist}->{city}->[$i] = $aryref->[$i]->[14];
$self->{columnslist}->{street}->[$i] = $aryref->[$i]->[15];
$self->{columnslist}->{address}->[$i] = $aryref->[$i]->[16];
$self->{columnslist}->{tel}->[$i] = $aryref->[$i]->[17];
$self->{columnslist}->{order_date}->[$i] = $aryref->[$i]->[18];
$self->{columnslist}->{deliver_date}->[$i] = $aryref->[$i]->[19];
$self->{columnslist}->{deliver_time}->[$i] = $aryref->[$i]->[20];
$self->{columnslist}->{opinion}->[$i] = $aryref->[$i]->[21];
$self->{columnslist}->{sagawa_id}->[$i] = $aryref->[$i]->[22];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[23];
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
$self->{columns}->{ordernum},
$self->{columns}->{guid},
$self->{columns}->{owid},
$self->{columns}->{orderstatus_flag},
$self->{columns}->{paymeth},
$self->{columns}->{mobilemailaddress},
$self->{columns}->{used_point},
$self->{columns}->{family_name},
$self->{columns}->{first_name},
$self->{columns}->{family_name_kana},
$self->{columns}->{first_name_kana},
$self->{columns}->{prefecture},
$self->{columns}->{zip},
$self->{columns}->{city},
$self->{columns}->{street},
$self->{columns}->{address},
$self->{columns}->{tel},
$self->{columns}->{order_date},
$self->{columns}->{deliver_date},
$self->{columns}->{deliver_time},
$self->{columns}->{opinion},
$self->{columns}->{sagawa_id},
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
		#push( @{ $sqlref->[0] }, "id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{id} ) if $param->{id} != "";
		push( @{ $sqlref->[0] }, "ordernum" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ordernum} ) if $param->{ordernum} ne "";
		push( @{ $sqlref->[0] }, "guid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{guid} ) if $param->{guid} ne "";
		push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
		push( @{ $sqlref->[0] }, "orderstatus_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{orderstatus_flag} ) if $param->{orderstatus_flag} != "";
		push( @{ $sqlref->[0] }, "paymeth" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{paymeth} ) if $param->{paymeth} != "";
		push( @{ $sqlref->[0] }, "mobilemailaddress" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{mobilemailaddress} ) if $param->{mobilemailaddress} ne "";
		push( @{ $sqlref->[0] }, "used_point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{used_point} ) if $param->{used_point} != "";
		push( @{ $sqlref->[0] }, "family_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{family_name} ) if $param->{family_name} ne "";
		push( @{ $sqlref->[0] }, "first_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{first_name} ) if $param->{first_name} ne "";
		push( @{ $sqlref->[0] }, "family_name_kana" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{family_name_kana} ) if $param->{family_name_kana} ne "";
		push( @{ $sqlref->[0] }, "first_name_kana" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{first_name_kana} ) if $param->{first_name_kana} ne "";
		push( @{ $sqlref->[0] }, "prefecture" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{prefecture} ) if $param->{prefecture} != "";
		push( @{ $sqlref->[0] }, "zip" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{zip} ) if $param->{zip} ne "";
		push( @{ $sqlref->[0] }, "city" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{city} ) if $param->{city} ne "";
		push( @{ $sqlref->[0] }, "street" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{street} ) if $param->{street} ne "";
		push( @{ $sqlref->[0] }, "address" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{address} ) if $param->{address} ne "";
		push( @{ $sqlref->[0] }, "tel" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{tel} ) if $param->{tel} ne "";
		push( @{ $sqlref->[0] }, "order_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{order_date} ) if $param->{order_date} ne "";
		push( @{ $sqlref->[0] }, "deliver_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{deliver_date} ) if $param->{deliver_date} ne "";
		push( @{ $sqlref->[0] }, "deliver_time" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{deliver_time} ) if $param->{deliver_time} ne "";
		push( @{ $sqlref->[0] }, "opinion" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{opinion} ) if $param->{opinion} ne "";
		push( @{ $sqlref->[0] }, "sagawa_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sagawa_id} ) if $param->{sagawa_id} ne "";
		#push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

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


sub updateStatus {
    my $self = shift;
    my $ordernum = shift || return;

    my $sql = sprintf("UPDATE %s SET orderstatus_flag=8 WHERE ordernum=?", $self->table);
    my $rv = $self->{this_dbh}->do($sql, undef, $ordernum);
    return (($rv eq '0E0') ? undef : 1);
 }

1;
__END__
