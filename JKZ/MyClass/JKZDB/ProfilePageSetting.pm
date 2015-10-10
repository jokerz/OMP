#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::ProfilePageSetting
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY createClassDB
# @create	Fri Jun 11 19:26:03 2010
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
package MyClass::JKZDB::ProfilePageSetting;

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
	my $table = 'OMP.tProfilePageSettingM';
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
$self->{columnslist}->{nickname}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{profile_bit}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{tuserimagef_id}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{selfintroduction}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{designtmplt_flag}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{designtmplt_filename}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{designtmplt_description}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[8];
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
$self->{columns}->{nickname},
$self->{columns}->{profile_bit},
$self->{columns}->{tuserimagef_id},
$self->{columns}->{selfintroduction},
$self->{columns}->{designtmplt_flag},
$self->{columns}->{designtmplt_filename},
$self->{columns}->{designtmplt_description},
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

	$self->{columns}->{owid} = $param->{owid};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{owid} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
		push( @{ $sqlref->[0] }, "nickname" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{nickname} ) if $param->{nickname} ne "";
		push( @{ $sqlref->[0] }, "profile_bit" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{profile_bit} ) if $param->{profile_bit} != "";
		push( @{ $sqlref->[0] }, "tuserimagef_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{tuserimagef_id} ) if $param->{tuserimagef_id} != "";
		push( @{ $sqlref->[0] }, "selfintroduction" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{selfintroduction} ) if $param->{selfintroduction} ne "";
		push( @{ $sqlref->[0] }, "designtmplt_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{designtmplt_flag} ) if $param->{designtmplt_flag} != "";
		push( @{ $sqlref->[0] }, "designtmplt_filename" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{designtmplt_filename} ) if $param->{designtmplt_filename} ne "";
		push( @{ $sqlref->[0] }, "designtmplt_description" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{designtmplt_description} ) if $param->{designtmplt_description} ne "";
		#push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE owid= '$self->{columns}->{owid}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


#******************************************************
# @access	public
# @desc		レコード新規追加処理
#			プライマリキーのINSERT処理を行ないます。
# @param	integer $owid
# @return	boolean
#******************************************************
sub insertOWID {
	my $self = shift;
	unless (@_) {
		## 引数がない場合はエラー
		return;
	}
	my $owid = shift;
	my $sqlMoji = "INSERT INTO " . $self->{table}
				. "(owid) VALUE (?)"
				;
	my $rv = $self->executeQuery($sqlMoji, $owid);
	## エラーの場合
	if ($rv eq '0E0') {
		return;
	}
	return 1;
}


#******************************************************
# @access	public
# @desc		ビット格納値をばらす
# 			
#******************************************************
sub makeSet {
	my $self = shift;
	unless (@_) {
		## 引数がない場合はエラー
		return;
	}
	my $owid = shift;
	my $sqlMoji = sprintf ("SELECT MAKE_SET(profile_bit, %s) ", join ' , ', map { 2**$_ } (0..10));
	   $sqlMoji .= " FROM " . $self->{table}
	   			 . " WHERE owid=?;"
	   			 ;
	my $sets = $self->{this_dbh}->selectrow_array ($sqlMoji, undef, $owid);

	return ($sets);
}


1;

