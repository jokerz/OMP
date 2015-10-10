#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::AffiliateAccessLog
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Thu Jan  7 12:47:32 2010
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
package MyClass::JKZDB::AffiliateAccessLog;

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
	my $table = 'OMP.tAffiliateAccessLogF';
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
$self->{columnslist}->{guid}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{acd}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{afcd}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{return_url}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{subno}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{in_datetime}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{useragent}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{carrier}->[$i] = $aryref->[$i]->[8];
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
$self->{columns}->{guid},
$self->{columns}->{acd},
$self->{columns}->{afcd},
$self->{columns}->{return_url},
$self->{columns}->{subno},
$self->{columns}->{in_datetime},
$self->{columns}->{useragent},
$self->{columns}->{carrier}
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

	#$self->{columns}->{guid} = $param->{guid};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	#if ($self->{columns}->{guid} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "in_date" ), push( @{ $sqlref->[1] }, "DATE_FORMAT(CURDATE(),'%y%m%d')" );#, push( @{ $sqlref->[2] }, $param->{in_date} ) if $param->{in_date} ne "";
		push( @{ $sqlref->[0] }, "guid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{guid} ) if $param->{guid} ne "";
		push( @{ $sqlref->[0] }, "acd" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{acd} ) if $param->{acd} ne "";
		push( @{ $sqlref->[0] }, "afcd" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{afcd} ) if $param->{afcd} ne "";
		push( @{ $sqlref->[0] }, "return_url" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{return_url} ) if $param->{return_url} ne "";
		push( @{ $sqlref->[0] }, "subno" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subno} ) if $param->{subno} ne "";
		#push( @{ $sqlref->[0] }, "in_datetime" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{in_datetime} ) if $param->{in_datetime} ne "";
		push( @{ $sqlref->[0] }, "useragent" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{useragent} ) if $param->{useragent} ne "";
		push( @{ $sqlref->[0] }, "carrier" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{carrier} ) if $param->{carrier} != "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		#$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
        $sqlMoji = sprintf(
            "INSERT INTO %s (%s) VALUES (%s) ON DUPLICATE KEY UPDATE acd='%s', afcd='%s', return_url='%s';",
                $self->{table},
                join(',', @{ $sqlref->[0] }),
                join(',', @{ $sqlref->[1] }),
                $param->{acd},
                $param->{afcd},
                $param->{return_url}
        );

		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value
=pod
	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE guid= '$self->{columns}->{guid}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}
=cut

## Modified 2009/09/29 END
}


#******************************************************
# @desc		アクセス時間・GUIDと広告コードで広告コードとセッションIDを取得
# @access	public
# @param	guid
# @return	ref { acd, afcd, return_url,  trns_date}  || undef
#           trn_date->transaction_date (%Y%m%d%H%i%S 20100612130522)
#******************************************************
sub fetchAcdAfcdByDateTimeGuid {
	my $self = shift;
	my $guid = shift || return undef;

    my $sql = "SELECT acd, afcd, return_url, DATE_FORMAT(NOW(), '%Y%m%d%H%i%S') AS trns_date FROM "
             . $self->{table}
             . " WHERE guid=? AND DATE_FORMAT(in_date, '%y%m%d') = DATE_FORMAT(CURDATE(),'%y%m%d')"
             ;

	my $ref;
	if (($ref->{acd}, $ref->{afcd}, $ref->{return_url}, $ref->{trns_date}) = $self->{this_dbh}->selectrow_array($sql, undef, $guid)) {
		return $ref;
	}
	else { return undef; }
}

1;

