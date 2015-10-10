#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::PointLog
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Thu Jan  7 12:48:01 2010
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
package MyClass::JKZDB::PointLog;

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
	my $table = 'OMP.tPointLogF';
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
$self->{columnslist}->{owid}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{guid}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{type_of_point}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{id_of_type}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{point}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{session_id}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[7];
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
$self->{columns}->{owid},
$self->{columns}->{guid},
$self->{columns}->{type_of_point},
$self->{columns}->{id_of_type},
$self->{columns}->{point},
$self->{columns}->{session_id},
$self->{columns}->{registration_date}
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
		push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
		push( @{ $sqlref->[0] }, "guid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{guid} ) if $param->{guid} != "";
		push( @{ $sqlref->[0] }, "type_of_point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{type_of_point} ) if $param->{type_of_point} != "";
		push( @{ $sqlref->[0] }, "id_of_type" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{id_of_type} ) if $param->{id_of_type} != "";
		push( @{ $sqlref->[0] }, "point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point} ) if $param->{point} != "";
		push( @{ $sqlref->[0] }, "session_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{session_id} ) if $param->{session_id} != "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
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


#******************************************************
# @desc     pointログ取得
#           registration_dateの指定がない場合当月分 
# @param    hashobj   { owid, registration_date , orderbySQL, offsetSQL, limitSQL}
# @param    
# @return   arrayobj  [ {id, owid, type_of_point, id_of_type, point, session_id, registration_date } ]
# データは月単位で戻す
#******************************************************
sub fetch_point_logSQL {
    my $self    = shift;
    my $hashobj = shift;

    return if !exists($hashobj->{owid}) || 0 > $hashobj->{owid};
    my @placeholder;
    my $sqlMoji = sprintf("SELECT * FROM %s WHERE owid=?", $self->table);
    push(@placeholder, $hashobj->{owid});

    if (exists($hashobj->{registration_date})) {
        $sqlMoji .= " AND DATE_FORMAT(registration_date, '%Y-%m')=DATE_FORMAT(?, '%Y-%m')";
        push(@placeholder, $hashobj->{registration_date});
    }
    else {
        $sqlMoji .= " AND DATE_FORMAT(registration_date, '%Y-%m')=DATE_FORMAT(CURDATE(), '%Y-%m')";
    }
    
    $sqlMoji .= sprintf(" ORDER BY %s DESC", $hashobj->{orderbySQL}) if exists($hashobj->{orderbySQL});
    $sqlMoji .= sprintf(" LIMIT %s, %s", $hashobj->{offsetSQL}, $hashobj->{limitSQL} ) if exists($hashobj->{offsetSQL}) && exists($hashobj->{limitSQL});
    
    my $return_obj = $self->dbh->selectall_arrayref($sqlMoji, { Columns => {} }, @placeholder);

    return $return_obj;
}



1;
__END__