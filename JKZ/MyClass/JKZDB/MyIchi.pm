#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::MyIchi
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY createClassDB
# @create	Thu Jul  1 12:59:22 2010
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
package MyClass::JKZDB::MyIchi;

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
	my $table = 'OMP.tMyIchi';
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
$self->{columnslist}->{owid}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{ichi_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{distance}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{iArea_code}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{iArea_areaid}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{iArea_sub_areaid}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{iArea_region}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{iArea_name}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{iArea_prefecture}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{startpoint_ido}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{startpoint_keido}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{endpoint_ido}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{endpoint_keido}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[13];
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
$self->{columns}->{owid},
$self->{columns}->{ichi_id},
$self->{columns}->{distance},
$self->{columns}->{iArea_code},
$self->{columns}->{iArea_areaid},
$self->{columns}->{iArea_sub_areaid},
$self->{columns}->{iArea_region},
$self->{columns}->{iArea_name},
$self->{columns}->{iArea_prefecture},
$self->{columns}->{startpoint_ido},
$self->{columns}->{startpoint_keido},
$self->{columns}->{endpoint_ido},
$self->{columns}->{endpoint_keido},
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

#	$self->{columns}->{owid} = $param->{owid};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
#	if ($self->{columns}->{owid} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
		push( @{ $sqlref->[0] }, "ichi_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ichi_id} ) if $param->{ichi_id} != "";
		push( @{ $sqlref->[0] }, "distance" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{distance} ) if $param->{distance} ne "";
		push( @{ $sqlref->[0] }, "iArea_code" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{iArea_code} ) if $param->{iArea_code} != "";
		push( @{ $sqlref->[0] }, "iArea_areaid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{iArea_areaid} ) if $param->{iArea_areaid} != "";
		push( @{ $sqlref->[0] }, "iArea_sub_areaid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{iArea_sub_areaid} ) if $param->{iArea_sub_areaid} != "";
		push( @{ $sqlref->[0] }, "iArea_region" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{iArea_region} ) if $param->{iArea_region} ne "";
		push( @{ $sqlref->[0] }, "iArea_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{iArea_name} ) if $param->{iArea_name} ne "";
		push( @{ $sqlref->[0] }, "iArea_prefecture" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{iArea_prefecture} ) if $param->{iArea_prefecture} ne "";
		push( @{ $sqlref->[0] }, "startpoint_ido" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{startpoint_ido} ) if $param->{startpoint_ido} ne "";
		push( @{ $sqlref->[0] }, "startpoint_keido" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{startpoint_keido} ) if $param->{startpoint_keido} ne "";
		push( @{ $sqlref->[0] }, "endpoint_ido" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{endpoint_ido} ) if $param->{endpoint_ido} ne "";
		push( @{ $sqlref->[0] }, "endpoint_keido" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{endpoint_keido} ) if $param->{endpoint_keido} ne "";
		#push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

#		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
        $sqlMoji = sprintf(
            "INSERT INTO %s (%s) VALUES (%s) ON DUPLICATE KEY UPDATE ichi_id='%s', distance='%s', iArea_code='%s', iArea_areaid='%s', iArea_sub_areaid='%s', iArea_region='%s',
              iArea_name='%s', iArea_prefecture='%s', startpoint_ido='%s', startpoint_keido='%s', endpoint_ido='%s', endpoint_keido='%s';",
                $self->{table},
                join(',', @{ $sqlref->[0] }),
                join(',', @{ $sqlref->[1] }),
                $param->{ichi_id},
                $param->{distance},
                $param->{iArea_code},
                $param->{iArea_areaid},
                $param->{iArea_sub_areaid},
                $param->{iArea_region},
                $param->{iArea_name},
                $param->{iArea_prefecture},
                $param->{startpoint_ido},
                $param->{startpoint_keido},
                $param->{endpoint_ido},
                $param->{endpoint_keido}
        );

		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value
=pod
	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE owid= '$self->{columns}->{owid}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}
=cut
## Modified 2009/09/29 END
}


1;

