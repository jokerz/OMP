#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::BannerDataF
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Tue Jan 12 18:36:57 2010
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
package MyClass::JKZDB::BannerDataF;

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
	my $table = 'OMP.tBannerDataF';
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
$self->{columnslist}->{bannerm_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{bannerdatam_id}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{carrier}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{sex}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{personality}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{bloodtype}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{occupation}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{prefecture}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{banner_url}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{banner_text}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{image_flag}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{image_name}->[$i] = $aryref->[$i]->[13];
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
$self->{columns}->{bannerm_id},
$self->{columns}->{bannerdatam_id},
$self->{columns}->{status_flag},
$self->{columns}->{carrier},
$self->{columns}->{sex},
$self->{columns}->{personality},
$self->{columns}->{bloodtype},
$self->{columns}->{occupation},
$self->{columns}->{prefecture},
$self->{columns}->{banner_url},
$self->{columns}->{banner_text},
$self->{columns}->{image_flag},
$self->{columns}->{image_name}
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

	$self->{columns}->{bannerm_id}    = $param->{bannerm_id};
    $self->{columns}->{bannerdatam_id} = $param->{bannerdatam_id};
    $self->{columns}->{id}             = $param->{id};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		#push( @{ $sqlref->[0] }, "id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{id} ) if $param->{id} != "";
		push( @{ $sqlref->[0] }, "bannerm_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bannerm_id} ) if $param->{bannerm_id} != "";
		push( @{ $sqlref->[0] }, "bannerdatam_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bannerdatam_id} ) if $param->{bannerdatam_id} != "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "carrier" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{carrier} ) if $param->{carrier} != "";
		push( @{ $sqlref->[0] }, "sex" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sex} ) if $param->{sex} != "";
		push( @{ $sqlref->[0] }, "personality" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{personality} ) if $param->{personality} != "";
		push( @{ $sqlref->[0] }, "bloodtype" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bloodtype} ) if $param->{bloodtype} != "";
		push( @{ $sqlref->[0] }, "occupation" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{occupation} ) if $param->{occupation} != "";
		push( @{ $sqlref->[0] }, "prefecture" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{prefecture} ) if $param->{prefecture} != "";
		push( @{ $sqlref->[0] }, "banner_url" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{banner_url} ) if $param->{banner_url} ne "";
		push( @{ $sqlref->[0] }, "banner_text" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{banner_text} ) if $param->{banner_text} ne "";
		push( @{ $sqlref->[0] }, "image_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{image_flag} ) if $param->{image_flag} != "";
		push( @{ $sqlref->[0] }, "image_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{image_name} ) if $param->{image_name} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE
 bannerm_id= '$self->{columns}->{bannerm_id}' AND
 bannerdatam_id= '$self->{columns}->{bannerdatam_id}' AND
 id= '$self->{columns}->{id}';", join('=?,', @{ $sqlref->[0] }));

		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


1;

