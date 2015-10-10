#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::OrderDetail
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Wed Feb  3 18:00:30 2010
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
package MyClass::JKZDB::OrderDetail;

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
	my $table = 'OMP.tOrderDetailF';
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
$self->{columnslist}->{orderstatus_flag}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{owid}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{product_id}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{qty}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{point}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{tanka}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{deliver_date}->[$i] = $aryref->[$i]->[8];
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
$self->{columns}->{id},
$self->{columns}->{ordernum},
$self->{columns}->{orderstatus_flag},
$self->{columns}->{owid},
$self->{columns}->{product_id},
$self->{columns}->{qty},
$self->{columns}->{point},
$self->{columns}->{tanka},
$self->{columns}->{deliver_date},
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

	$self->{columns}->{id} = $param->{id};
	$self->{columns}->{ordernum} = $param->{ordernum};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	#if ($self->{columns}->{ordernum} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 
    if (0 > $flag) {
## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{id} ) if $param->{id} != "";
		push( @{ $sqlref->[0] }, "ordernum" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ordernum} ) if $param->{ordernum} ne "";
		push( @{ $sqlref->[0] }, "orderstatus_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{orderstatus_flag} ) if $param->{orderstatus_flag} != "";
		push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
		push( @{ $sqlref->[0] }, "product_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{product_id} ) if $param->{product_id} != "";
		push( @{ $sqlref->[0] }, "qty" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{qty} ) if $param->{qty} != "";
		push( @{ $sqlref->[0] }, "point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point} ) if $param->{point} != "";
		push( @{ $sqlref->[0] }, "tanka" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{tanka} ) if $param->{tanka} != "";
		push( @{ $sqlref->[0] }, "deliver_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{deliver_date} ) if $param->{deliver_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE ordernum='$self->{columns}->{ordernum}' AND id='$self->{columns}->{id}' ;", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


#******************************************************
# @access    public
# @desc     注文処理ステータス更新
#           複数の商品を注文していて2つのパラメータのうちidが無い場合は全注文商品のステータスが更新される。
# @param    hashobj  ordernum id orderstatus_flag
#******************************************************
sub updateStatus {
    my $self = shift;
    my $param = shift || return;


    my $sql =
    ( 8 == $param->{orderstatus_flag} )
    ? sprintf("UPDATE %s SET orderstatus_flag=%s, deliver_date='%s' WHERE ordernum=?", $self->table, $param->{orderstatus_flag}, $param->{deliver_date})
    : sprintf("UPDATE %s SET orderstatus_flag=%s WHERE ordernum=?", $self->table, $param->{orderstatus_flag})
    ;

    my $rv = ( exists($param->{id}) ) ?  $self->{this_dbh}->do($sql . ' AND id=?', undef, $param->{ordernum}, $param->{id}) : $self->{this_dbh}->do($sql, undef, $param->{ordernum});

    return (($rv eq '0E0') ? undef : 1);
 }


1;
__END__

