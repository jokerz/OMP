#******************************************************
# @desc		
#			
# @package	JKZ::JKZDB::PageViewLog
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Tue Feb 24 15:00:17 2009
# @version	1.10
# @update	2008/05/30 executeUpdate処理の戻り値部分
# @update	2008/03/31 JKZ::DB::JKZDBのサブクラス化
# @update	2009/02/02 ディレクトリ構成をJKZ::JKZDBに変更
# @update	2009/02/12 リスティング処理を追加
# @udpate	2009/02/24 このテーブルは自動インサート・更新を実行する。引数はtmplt_idのみとなり通常のUPDATE文を操作できない
# @udpate	2009/12/02 カラム carrier の追加による更新
# @version	1.10
# @version	1.20
#******************************************************
package MyClass::JKZDB::PageViewLog;

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
	my $table = 'OMP.tPageViewLogF';
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
$self->{columnslist}->{in_date}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{in_time}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{carrier}->[$i] = $aryref->[$i]->[2];
## Modified 2010/02/26
#$self->{columnslist}->{tmplt_id}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{tmplt_name}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{pvcount}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{last_pv}->[$i] = $aryref->[$i]->[5];
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
$self->{columns}->{in_date},
$self->{columns}->{in_time},
$self->{columns}->{carrier},
## Modified 2010/02/26
#$self->{columns}->{tmplt_id},
$self->{columns}->{tmplt_name},
$self->{columns}->{pvcount},
$self->{columns}->{last_pv}
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
#			このテーブルは引数としてtmplt_idだけとする
#			*** このテーブルは通常と違う処理をする。primarykeyの重複時はpvcountをupdateする
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

=pod
	$self->{columns}->{} = $param->{};
	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 
=cut

	$sqlMoji = "INSERT INTO $self->{table} (";
#************************ AUTO GENERATED BEGIN ************************
$sqlMoji .= " in_date";
$sqlMoji .= " ,in_time";
$sqlMoji .= " ,carrier"  if  $param->{carrier}  != "";
# Modified 2010/02/26
#$sqlMoji .= " ,tmplt_id" if  $param->{tmplt_id} != "";
$sqlMoji .= " ,tmplt_name" if  $param->{tmplt_name} ne "";
$sqlMoji .= " ,pvcount";
$sqlMoji .= ") VALUES (";
#************************ AUTO  GENERATED  END ************************
#************************ AUTO GENERATED BEGIN ************************
$sqlMoji .= " CURDATE()";
$sqlMoji .= ", DATE_FORMAT(NOW(), '%H')";
## Modified 2009/12/02
if ($param->{carrier}  != "") { push @placeholder,$param->{carrier};  $sqlMoji .= ", ?"; }
# Modified 2010/02/26
#if ($param->{tmplt_id} != "") { push @placeholder,$param->{tmplt_id}; $sqlMoji .= ", ?"; }
if ($param->{tmplt_name} ne "") { push @placeholder,$param->{tmplt_name}; $sqlMoji .= ", ?"; }
$sqlMoji .= ", 1";
#************************ AUTO  GENERATED  END ************************
$sqlMoji .= ")";

#******************************************************************************************
# 特別処理追加 primarykeyが存在するときは、pvcountカウンターを+1更新処理を実行
# また、ログテーブルなので明示的更新は無いのでUPDATE文はコメントアウト
#******************************************************************************************
$sqlMoji .= " ON DUPLICATE KEY UPDATE pvcount=pvcount+1";

		my $rv = $self->executeQuery($sqlMoji, \@placeholder);
		# Error処理
		return $rv;

=pod
	} else {
	## ここでPrimaryKeyが設定されていることが想定される
	## Update開始
		map { exists ($self->{columns}->{$_}) ? push (@query, $_) && push (@placeholder, $param->{$_}) : ""} keys %$param;

		#$sqlMoji = sprintf "UPDATE $self->{table} SET %s =?, lastupdate_date=NOW() WHERE id= '$self->{columns}->{id}';" , join ('=?,', @query);
		$sqlMoji = sprintf "UPDATE $self->{table} SET %s =?  WHERE = '$self->{columns}->{}';" , join ('=?,', @query);
		my $rv = $self->executeQuery ($sqlMoji, \@placeholder);
		# Error処理
		return $rv;
	}
=cut
}


1;

