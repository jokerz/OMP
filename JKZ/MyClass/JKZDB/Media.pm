#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::Media
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Wed Jan 20 01:52:16 2010
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
package MyClass::JKZDB::Media;

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
	my $table = 'OMP.tMediaM';
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
$self->{columnslist}->{ad_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{point_type}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{agent_name}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{ad_name}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{ad_url}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{ad_period_flag}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{valid_date}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{expire_date}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{point}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{mediacategory_id}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{personality}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{carrier}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{price_per_regist}->[$i] = $aryref->[$i]->[13];
$self->{columnslist}->{return_url}->[$i] = $aryref->[$i]->[14];
$self->{columnslist}->{ad_16words_text}->[$i] = $aryref->[$i]->[15];
$self->{columnslist}->{ad_text}->[$i] = $aryref->[$i]->[16];
$self->{columnslist}->{param_name_for_session_id}->[$i] = $aryref->[$i]->[17];
$self->{columnslist}->{param_name_for_status}->[$i] = $aryref->[$i]->[18];
$self->{columnslist}->{param_name_for_result_session_id}->[$i] = $aryref->[$i]->[19];
$self->{columnslist}->{status_value_for_success}->[$i] = $aryref->[$i]->[20];
$self->{columnslist}->{send_param_name}->[$i] = $aryref->[$i]->[21];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[22];
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
$self->{columns}->{ad_id},
$self->{columns}->{status_flag},
$self->{columns}->{point_type},
$self->{columns}->{agent_name},
$self->{columns}->{ad_name},
$self->{columns}->{ad_url},
$self->{columns}->{ad_period_flag},
$self->{columns}->{valid_date},
$self->{columns}->{expire_date},
$self->{columns}->{point},
$self->{columns}->{mediacategory_id},
$self->{columns}->{personality},
$self->{columns}->{carrier},
$self->{columns}->{price_per_regist},
$self->{columns}->{return_url},
$self->{columns}->{ad_16words_text},
$self->{columns}->{ad_text},
$self->{columns}->{param_name_for_session_id},
$self->{columns}->{param_name_for_status},
$self->{columns}->{param_name_for_result_session_id},
$self->{columns}->{status_value_for_success},
$self->{columns}->{send_param_name},
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

	$self->{columns}->{ad_id} = $param->{ad_id};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{ad_id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		#push( @{ $sqlref->[0] }, "ad_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_id} ) if $param->{ad_id} != "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "point_type" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point_type} ) if $param->{point_type} != "";
		push( @{ $sqlref->[0] }, "agent_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{agent_name} ) if $param->{agent_name} ne "";
		push( @{ $sqlref->[0] }, "ad_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_name} ) if $param->{ad_name} ne "";
		push( @{ $sqlref->[0] }, "ad_url" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_url} ) if $param->{ad_url} ne "";
		push( @{ $sqlref->[0] }, "ad_period_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_period_flag} ) if $param->{ad_period_flag} != "";
		push( @{ $sqlref->[0] }, "valid_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{valid_date} ) if $param->{valid_date} ne "";
		push( @{ $sqlref->[0] }, "expire_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{expire_date} ) if $param->{expire_date} ne "";
		push( @{ $sqlref->[0] }, "point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point} ) if $param->{point} != "";
		push( @{ $sqlref->[0] }, "mediacategory_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{mediacategory_id} ) if $param->{mediacategory_id} != "";
		push( @{ $sqlref->[0] }, "personality" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{personality} ) if $param->{personality} != "";
		push( @{ $sqlref->[0] }, "carrier" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{carrier} ) if $param->{carrier} != "";
		push( @{ $sqlref->[0] }, "price_per_regist" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{price_per_regist} ) if $param->{price_per_regist} != "";
		push( @{ $sqlref->[0] }, "return_url" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{return_url} ) if $param->{return_url} ne "";
		push( @{ $sqlref->[0] }, "ad_16words_text" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_16words_text} ) if $param->{ad_16words_text} ne "";
		push( @{ $sqlref->[0] }, "ad_text" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_text} ) if $param->{ad_text} ne "";
		push( @{ $sqlref->[0] }, "param_name_for_session_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{param_name_for_session_id} ) if $param->{param_name_for_session_id} ne "";
		push( @{ $sqlref->[0] }, "param_name_for_status" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{param_name_for_status} ) if $param->{param_name_for_status} ne "";
		push( @{ $sqlref->[0] }, "param_name_for_result_session_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{param_name_for_result_session_id} ) if $param->{param_name_for_result_session_id} ne "";
		push( @{ $sqlref->[0] }, "status_value_for_success" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_value_for_success} ) if $param->{status_value_for_success} != "";
		push( @{ $sqlref->[0] }, "send_param_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{send_param_name} ) if $param->{send_param_name} ne "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
		#push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE ad_id= '$self->{columns}->{ad_id}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


sub maxAdID {
	my $self  = shift;
	my $sql   = sprintf("SELECT MAX(ad_id) FROM %s;", $self->table);
	return ($self->{this_dbh}->selectrow_array($sql));
	#my $maxid = $self->{this_dbh}->selectrow_array();
	#return ($maxid);
}


#******************************************************
# @desc		広告先へのad_urlとポイント数返す
# @param	期間指定があるレコード期間内かをチェックする
# @param	hashobj {ad_id carrier}
# @return	hashobj {ad_url, point}
#******************************************************
sub fetchAdUrlPointByAdID {
    my $self    = shift;
    my $hashobj = shift || return;

    return if !exists($hashobj->{ad_id}) || "" eq $hashobj->{ad_id};

    my $sql = sprintf("
 SELECT
 IF(ad_period_flag=2,
   IF(DATE(valid_date) <= DATE(NOW()) AND DATE(expire_date) >= DATE(NOW()), ad_url, NULL),
   ad_url
 ) AS ad_url,
 point,
 price_per_regist,
 send_param_name
 FROM %s WHERE ad_id=? AND status_flag=2 AND carrier & ?;", $self->table);

    my $ref;
    ( $ref->{ad_url}, $ref->{point}, $ref->{price_per_regist}, $ref->{send_param_name} ) = $self->{this_dbh}->selectrow_array($sql, undef, $hashobj->{ad_id}, $hashobj->{carrier});

    return $ref;
}


1;

