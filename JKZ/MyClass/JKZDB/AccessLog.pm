#******************************************************
# @desc		
#			
# @package	JKZ::JKZDB::AccessLog
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Tue Feb 24 15:00:03 2009
# @version	1.10
# @update	2008/05/30 executeUpdate処理の戻り値部分
# @update	2008/03/31 JKZ::DB::JKZDBのサブクラス化
# @update	2009/02/02 ディレクトリ構成をJKZ::JKZDBに変更
# @update	2009/02/12 リスティング処理を追加
# @version	1.10
# @version	1.20
#******************************************************
package MyClass::JKZDB::AccessLog;

use 5.008005;
use strict;
our $VERSION ='1.20';

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
	my $table = 'OMP.tAccessLogF';

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
$self->{columnslist}->{in_datetime}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{acd}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{carrier}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{guid}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{ip}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{host}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{useragent}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{referer}->[$i] = $aryref->[$i]->[8];
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
$self->{columns}->{in_datetime},
$self->{columns}->{acd},
$self->{columns}->{carrier},
$self->{columns}->{guid},
$self->{columns}->{ip},
$self->{columns}->{host},
$self->{columns}->{useragent},
$self->{columns}->{referer}
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
	my @query;
	my @placeholder;

	if ($self->{this_dbh} == "") {
		#エラー処理
	}

	$self->{columns}->{id} = $param->{id};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 
		$sqlMoji = "INSERT INTO $self->{table} (";
#************************ AUTO GENERATED BEGIN ************************
#$sqlMoji .= " id" if  $param->{id} != "";
#$sqlMoji .= " in_datetime" if  $param->{in_datetime} ne "";
$sqlMoji .= " acd" if  $param->{acd} ne "";
$sqlMoji .= " ,carrier" if  $param->{carrier} != "";
$sqlMoji .= " ,guid" if  $param->{guid} ne "";
$sqlMoji .= " ,ip" if  $param->{ip} ne "";
$sqlMoji .= " ,host" if  $param->{host} ne "";
$sqlMoji .= " ,useragent" if  $param->{useragent} ne "";
$sqlMoji .= " ,referer" if  $param->{referer} ne "";
$sqlMoji .= ") VALUES (";
#************************ AUTO  GENERATED  END ************************
#************************ AUTO GENERATED BEGIN ************************
#if ($param->{id} != "") { push @placeholder,$param->{id}; $sqlMoji .= " ?"; }
#if ($param->{in_datetime} ne "") { push @placeholder,$param->{in_datetime}; $sqlMoji .= " ?"; }
if ($param->{acd} ne "") { push @placeholder,$param->{acd}; $sqlMoji .= " ?"; }
if ($param->{carrier} != "") { push @placeholder,$param->{carrier}; $sqlMoji .= ", ?"; }
if ($param->{guid} ne "") { push @placeholder,$param->{guid}; $sqlMoji .= ", ?"; }
if ($param->{ip} ne "") { push @placeholder,$param->{ip}; $sqlMoji .= ", ?"; }
if ($param->{host} ne "") { push @placeholder,$param->{host}; $sqlMoji .= ", ?"; }
if ($param->{useragent} ne "") { push @placeholder,$param->{useragent}; $sqlMoji .= ", ?"; }
if ($param->{referer} ne "") { push @placeholder,$param->{referer}; $sqlMoji .= ", ?"; }
#************************ AUTO  GENERATED  END ************************
		$sqlMoji .= ")";

		my $rv = $self->executeQuery($sqlMoji, \@placeholder);
		# Error処理
		return $rv;
	} else {
	## ここでPrimaryKeyが設定されていることが想定される
	## Update開始
		map { exists($self->{columns}->{$_}) ? push(@query, $_) && push(@placeholder, $param->{$_}) : ""} keys %$param;

		$sqlMoji = sprintf "UPDATE $self->{table} SET %s =?  WHERE = '$self->{columns}->{id}';" , join('=?,', @query);
		my $rv = $self->executeQuery($sqlMoji, \@placeholder);
		# Error処理
		return $rv;
	}
}


1;

