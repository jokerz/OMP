#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::MyPageMedia
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Wed Mar 10 18:29:05 2010
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
package MyClass::JKZDB::MyPageMedia;

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
	my $table = 'OMP.tMyPageMediaF';
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
$self->{columnslist}->{ad_name}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{point}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{mediacategory_id}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{carrier}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{ad_16words_text}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[7];
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
$self->{columns}->{ad_name},
$self->{columns}->{point},
$self->{columns}->{mediacategory_id},
$self->{columns}->{carrier},
$self->{columns}->{ad_16words_text},
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
		push( @{ $sqlref->[0] }, "ad_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_id} ) if $param->{ad_id} != "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "ad_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_name} ) if $param->{ad_name} ne "";
		push( @{ $sqlref->[0] }, "point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point} ) if $param->{point} != "";
		push( @{ $sqlref->[0] }, "mediacategory_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{mediacategory_id} ) if $param->{mediacategory_id} != "";
		push( @{ $sqlref->[0] }, "carrier" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{carrier} ) if $param->{carrier} != "";
		push( @{ $sqlref->[0] }, "ad_16words_text" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{ad_16words_text} ) if $param->{ad_16words_text} ne "";
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


1;

