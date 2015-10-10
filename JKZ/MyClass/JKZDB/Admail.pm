#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::Admail
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Mon Feb  1 11:08:57 2010
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
package MyClass::JKZDB::Admail;

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
	my $table = 'OMP.tAdmail';
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
$self->{columnslist}->{admailno}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{fromaddress}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{sendmax}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{senddate}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{sendend}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{status}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{client}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{presentpoint}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{presentlimit}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{sendd}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{sendj}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{sende}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{sendo}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{subjectd}->[$i] = $aryref->[$i]->[13];
$self->{columnslist}->{subjectj}->[$i] = $aryref->[$i]->[14];
$self->{columnslist}->{subjecte}->[$i] = $aryref->[$i]->[15];
$self->{columnslist}->{subjecto}->[$i] = $aryref->[$i]->[16];
$self->{columnslist}->{contentsd}->[$i] = $aryref->[$i]->[17];
$self->{columnslist}->{contentsj}->[$i] = $aryref->[$i]->[18];
$self->{columnslist}->{contentse}->[$i] = $aryref->[$i]->[19];
$self->{columnslist}->{contentso}->[$i] = $aryref->[$i]->[20];
$self->{columnslist}->{condition}->[$i] = $aryref->[$i]->[21];
$self->{columnslist}->{sqlcond}->[$i] = $aryref->[$i]->[22];
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
$self->{columns}->{admailno},
$self->{columns}->{fromaddress},
$self->{columns}->{sendmax},
$self->{columns}->{senddate},
$self->{columns}->{sendend},
$self->{columns}->{status},
$self->{columns}->{client},
$self->{columns}->{presentpoint},
$self->{columns}->{presentlimit},
$self->{columns}->{sendd},
$self->{columns}->{sendj},
$self->{columns}->{sende},
$self->{columns}->{sendo},
$self->{columns}->{subjectd},
$self->{columns}->{subjectj},
$self->{columns}->{subjecte},
$self->{columns}->{subjecto},
$self->{columns}->{contentsd},
$self->{columns}->{contentsj},
$self->{columns}->{contentse},
$self->{columns}->{contentso},
$self->{columns}->{condition},
$self->{columns}->{sqlcond}
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

	$self->{columns}->{admailno} = $param->{admailno};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{admailno} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "admailno" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{admailno} ) if $param->{admailno} != "";
		push( @{ $sqlref->[0] }, "fromaddress" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{fromaddress} ) if $param->{fromaddress} ne "";
		push( @{ $sqlref->[0] }, "sendmax" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sendmax} ) if $param->{sendmax} != "";
		push( @{ $sqlref->[0] }, "senddate" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{senddate} ) if $param->{senddate} ne "";
		push( @{ $sqlref->[0] }, "sendend" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sendend} ) if $param->{sendend} ne "";
		push( @{ $sqlref->[0] }, "status" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status} ) if $param->{status} != "";
		push( @{ $sqlref->[0] }, "client" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{client} ) if $param->{client} ne "";
		push( @{ $sqlref->[0] }, "presentpoint" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{presentpoint} ) if $param->{presentpoint} != "";
		push( @{ $sqlref->[0] }, "presentlimit" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{presentlimit} ) if $param->{presentlimit} ne "";
		push( @{ $sqlref->[0] }, "sendd" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sendd} ) if $param->{sendd} != "";
		push( @{ $sqlref->[0] }, "sendj" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sendj} ) if $param->{sendj} != "";
		push( @{ $sqlref->[0] }, "sende" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sende} ) if $param->{sende} != "";
		push( @{ $sqlref->[0] }, "sendo" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sendo} ) if $param->{sendo} != "";
		push( @{ $sqlref->[0] }, "subjectd" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subjectd} ) if $param->{subjectd} ne "";
		push( @{ $sqlref->[0] }, "subjectj" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subjectj} ) if $param->{subjectj} ne "";
		push( @{ $sqlref->[0] }, "subjecte" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subjecte} ) if $param->{subjecte} ne "";
		push( @{ $sqlref->[0] }, "subjecto" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subjecto} ) if $param->{subjecto} ne "";
		push( @{ $sqlref->[0] }, "contentsd" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{contentsd} ) if $param->{contentsd} ne "";
		push( @{ $sqlref->[0] }, "contentsj" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{contentsj} ) if $param->{contentsj} ne "";
		push( @{ $sqlref->[0] }, "contentse" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{contentse} ) if $param->{contentse} ne "";
		push( @{ $sqlref->[0] }, "contentso" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{contentso} ) if $param->{contentso} ne "";
		push( @{ $sqlref->[0] }, "condition" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{condition} ) if $param->{condition} ne "";
		push( @{ $sqlref->[0] }, "sqlcond" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sqlcond} ) if $param->{sqlcond} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE admailno= '$self->{columns}->{admailno}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


1;

