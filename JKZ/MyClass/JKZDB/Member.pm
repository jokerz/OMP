#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::Member
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create	Tue Jan 12 14:16:51 2010
# @version	1.30
# @update	2008/05/30 executeUpdate処理の戻り値部分
# @update	2008/03/31 JKZ::DB::JKZDBのサブクラス化
# @update	2009/02/02 ディレクトリ構成をJKZ::JKZDBに変更
# @update	2009/02/12 リスティング処理を追加
# @update	2009/09/28 executeUpdateメソッドの処理変更
# @update	2010/01/26 fetchOwIDGuIDbyIntrIDメソッド追加
# @version	1.10
# @version	1.20
# @version	1.30
#******************************************************
package MyClass::JKZDB::Member;

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
=pod
    my $arg   = shift if @_ > 0;
    my $table =
       !$arg              ? 'OMP.tMemberM'
                          :
       'HASH' eq ref $arg ? { table => 'OMP.tMemberM', table_join => $arg->{join_table} }
                          : { table => 'OMP.tMemberM', table_join => 'OMP.tProfilePageSettingM' }
                          ;
=cut
	my $table = 'OMP.tMemberM';

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
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{guid}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{subno}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{carrier}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{mobilemailaddress}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{memberstatus_flag}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{mailstatus_flag}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{sessid}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{intr_id}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{friend_intr_id}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{password}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{cryptpassword}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{HPTitle}->[$i] = $aryref->[$i]->[13];
$self->{columnslist}->{HPCategory}->[$i] = $aryref->[$i]->[14];
$self->{columnslist}->{HPURL}->[$i] = $aryref->[$i]->[15];
$self->{columnslist}->{HPeditURL}->[$i] = $aryref->[$i]->[16];
$self->{columnslist}->{nickname}->[$i] = $aryref->[$i]->[17];
$self->{columnslist}->{family_name}->[$i] = $aryref->[$i]->[18];
$self->{columnslist}->{first_name}->[$i] = $aryref->[$i]->[19];
$self->{columnslist}->{family_name_kana}->[$i] = $aryref->[$i]->[20];
$self->{columnslist}->{first_name_kana}->[$i] = $aryref->[$i]->[21];
$self->{columnslist}->{personality}->[$i] = $aryref->[$i]->[22];
$self->{columnslist}->{bloodtype}->[$i] = $aryref->[$i]->[23];
$self->{columnslist}->{occupation}->[$i] = $aryref->[$i]->[24];
$self->{columnslist}->{keyword}->[$i] = $aryref->[$i]->[25];
$self->{columnslist}->{sex}->[$i] = $aryref->[$i]->[26];
$self->{columnslist}->{year_of_birth}->[$i] = $aryref->[$i]->[27];
$self->{columnslist}->{month_of_birth}->[$i] = $aryref->[$i]->[28];
$self->{columnslist}->{date_of_birth}->[$i] = $aryref->[$i]->[29];
$self->{columnslist}->{prefecture}->[$i] = $aryref->[$i]->[30];
$self->{columnslist}->{zip}->[$i] = $aryref->[$i]->[31];
$self->{columnslist}->{city}->[$i] = $aryref->[$i]->[32];
$self->{columnslist}->{street}->[$i] = $aryref->[$i]->[33];
$self->{columnslist}->{address}->[$i] = $aryref->[$i]->[34];
$self->{columnslist}->{tel}->[$i] = $aryref->[$i]->[35];
$self->{columnslist}->{point}->[$i] = $aryref->[$i]->[36];
$self->{columnslist}->{adminpoint}->[$i] = $aryref->[$i]->[37];
$self->{columnslist}->{limitpoint}->[$i] = $aryref->[$i]->[38];
$self->{columnslist}->{pluspoint}->[$i] = $aryref->[$i]->[39];
$self->{columnslist}->{minuspoint}->[$i] = $aryref->[$i]->[40];
$self->{columnslist}->{adv_code}->[$i] = $aryref->[$i]->[41];
$self->{columnslist}->{afcd}->[$i] = $aryref->[$i]->[42];
$self->{columnslist}->{useragent}->[$i] = $aryref->[$i]->[43];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[44];
$self->{columnslist}->{withdraw_date}->[$i] = $aryref->[$i]->[45];
$self->{columnslist}->{reregistration_date}->[$i] = $aryref->[$i]->[46];
$self->{columnslist}->{lastupdate_date}->[$i] = $aryref->[$i]->[47];
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
$self->{columns}->{status_flag},
$self->{columns}->{guid},
$self->{columns}->{subno},
$self->{columns}->{carrier},
$self->{columns}->{mobilemailaddress},
$self->{columns}->{memberstatus_flag},
$self->{columns}->{mailstatus_flag},
$self->{columns}->{sessid},
$self->{columns}->{intr_id},
$self->{columns}->{friend_intr_id},
$self->{columns}->{password},
$self->{columns}->{cryptpassword},
$self->{columns}->{HPTitle},
$self->{columns}->{HPCategory},
$self->{columns}->{HPURL},
$self->{columns}->{HPeditURL},
$self->{columns}->{nickname},
$self->{columns}->{family_name},
$self->{columns}->{first_name},
$self->{columns}->{family_name_kana},
$self->{columns}->{first_name_kana},
$self->{columns}->{personality},
$self->{columns}->{bloodtype},
$self->{columns}->{occupation},
$self->{columns}->{keyword},
$self->{columns}->{sex},
$self->{columns}->{year_of_birth},
$self->{columns}->{month_of_birth},
$self->{columns}->{date_of_birth},
$self->{columns}->{prefecture},
$self->{columns}->{zip},
$self->{columns}->{city},
$self->{columns}->{street},
$self->{columns}->{address},
$self->{columns}->{tel},
$self->{columns}->{point},
$self->{columns}->{adminpoint},
$self->{columns}->{limitpoint},
$self->{columns}->{pluspoint},
$self->{columns}->{minuspoint},
$self->{columns}->{adv_code},
$self->{columns}->{afcd},
$self->{columns}->{useragent},
$self->{columns}->{registration_date},
$self->{columns}->{withdraw_date},
$self->{columns}->{reregistration_date},
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
		#push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
		push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
		push( @{ $sqlref->[0] }, "guid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{guid} ) if $param->{guid} ne "";
		push( @{ $sqlref->[0] }, "subno" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{subno} ) if $param->{subno} ne "";
		push( @{ $sqlref->[0] }, "carrier" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{carrier} ) if $param->{carrier} != "";
		push( @{ $sqlref->[0] }, "mobilemailaddress" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{mobilemailaddress} ) if $param->{mobilemailaddress} ne "";
		push( @{ $sqlref->[0] }, "memberstatus_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{memberstatus_flag} ) if $param->{memberstatus_flag} != "";
		push( @{ $sqlref->[0] }, "mailstatus_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{mailstatus_flag} ) if $param->{mailstatus_flag} != "";
		push( @{ $sqlref->[0] }, "sessid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sessid} ) if $param->{sessid} ne "";
		push( @{ $sqlref->[0] }, "intr_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{intr_id} ) if $param->{intr_id} ne "";
		push( @{ $sqlref->[0] }, "friend_intr_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{friend_intr_id} ) if $param->{friend_intr_id} ne "";
		push( @{ $sqlref->[0] }, "password" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{password} ) if $param->{password} ne "";
		push( @{ $sqlref->[0] }, "cryptpassword" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{cryptpassword} ) if $param->{cryptpassword} ne "";
		push( @{ $sqlref->[0] }, "HPTitle" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{HPTitle} ) if $param->{HPTitle} ne "";
		push( @{ $sqlref->[0] }, "HPCategory" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{HPCategory} ) if $param->{HPCategory} != "";
		push( @{ $sqlref->[0] }, "HPURL" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{HPURL} ) if $param->{HPURL} ne "";
		push( @{ $sqlref->[0] }, "HPeditURL" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{HPeditURL} ) if $param->{HPeditURL} ne "";
		push( @{ $sqlref->[0] }, "nickname" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{nickname} ) if $param->{nickname} ne "";
		push( @{ $sqlref->[0] }, "family_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{family_name} ) if $param->{family_name} ne "";
		push( @{ $sqlref->[0] }, "first_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{first_name} ) if $param->{first_name} ne "";
		push( @{ $sqlref->[0] }, "family_name_kana" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{family_name_kana} ) if $param->{family_name_kana} ne "";
		push( @{ $sqlref->[0] }, "first_name_kana" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{first_name_kana} ) if $param->{first_name_kana} ne "";
		push( @{ $sqlref->[0] }, "personality" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{personality} ) if $param->{personality} != "";
		push( @{ $sqlref->[0] }, "bloodtype" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bloodtype} ) if $param->{bloodtype} != "";
		push( @{ $sqlref->[0] }, "occupation" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{occupation} ) if $param->{occupation} != "";
		push( @{ $sqlref->[0] }, "keyword" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{keyword} ) if $param->{keyword} ne "";
		push( @{ $sqlref->[0] }, "sex" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{sex} ) if $param->{sex} != "";
		push( @{ $sqlref->[0] }, "year_of_birth" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{year_of_birth} ) if $param->{year_of_birth} ne "";
		push( @{ $sqlref->[0] }, "month_of_birth" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{month_of_birth} ) if $param->{month_of_birth} ne "";
		push( @{ $sqlref->[0] }, "date_of_birth" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{date_of_birth} ) if $param->{date_of_birth} ne "";
		push( @{ $sqlref->[0] }, "prefecture" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{prefecture} ) if $param->{prefecture} != "";
		push( @{ $sqlref->[0] }, "zip" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{zip} ) if $param->{zip} ne "";
		push( @{ $sqlref->[0] }, "city" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{city} ) if $param->{city} ne "";
		push( @{ $sqlref->[0] }, "street" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{street} ) if $param->{street} ne "";
		push( @{ $sqlref->[0] }, "address" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{address} ) if $param->{address} ne "";
		push( @{ $sqlref->[0] }, "tel" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{tel} ) if $param->{tel} ne "";
		push( @{ $sqlref->[0] }, "point" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{point} ) if $param->{point} != "";
		push( @{ $sqlref->[0] }, "adminpoint" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{adminpoint} ) if $param->{adminpoint} != "";
		push( @{ $sqlref->[0] }, "limitpoint" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{limitpoint} ) if $param->{limitpoint} != "";
		push( @{ $sqlref->[0] }, "pluspoint" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{pluspoint} ) if $param->{pluspoint} != "";
		push( @{ $sqlref->[0] }, "minuspoint" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{minuspoint} ) if $param->{minuspoint} != "";
		push( @{ $sqlref->[0] }, "adv_code" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{adv_code} ) if $param->{adv_code} ne "";
		push( @{ $sqlref->[0] }, "afcd" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{afcd} ) if $param->{afcd} ne "";
		push( @{ $sqlref->[0] }, "useragent" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{useragent} ) if $param->{useragent} ne "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
		#push( @{ $sqlref->[0] }, "withdraw_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{withdraw_date} ) if $param->{withdraw_date} ne "";
		#push( @{ $sqlref->[0] }, "reregistration_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{reregistration_date} ) if $param->{reregistration_date} ne "";
		#push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE owid= '$self->{columns}->{owid}';", join('=?,', @{ $sqlref->[0] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


#******************************************************
# @access	public
# @desc		友達紹介用IDからowidとguidを取得
# @param	string 32
# @return	hashobj { owid, guid }
#******************************************************
sub fetchOwIDGuIDbyIntrID {
	my $self = shift;
	unless (@_) {
		## 引数がない場合はエラー
		return;
	}
	## メッセージのIDと更新ステータス
	my $intr_id = shift;
    my $sql     = sprintf("SELECT owid, guid FROM %s WHERE intr_id=?;", $self->table);
    my $obj     = {};

	( $obj->{owid}, $obj->{guid} ) = $self->{this_dbh}->selectrow_array($sql, undef, $intr_id);

	return $obj;
}


#******************************************************
# @access	public
# @desc		owidからHPの登録nicknameを取得
# @param	integer $owid
# @return	nickname
#******************************************************
sub getNickNameByOWID {
	my $self = shift;
	unless (@_) {
		## 引数がない場合はエラー
		return;
	}
	## メッセージのIDと更新ステータス
	my $owid = shift;

	$self->{column}->{nickname} = $self->getOneValueSQL(
		{
			column		=> 'nickname',
			whereSQL	=> 'owid = ?',
			placeholder => ["$owid",],
		}
	);

	return $self->{column}->{nickname};
}


#******************************************************
# @access	public
# @desc		ポイントカラム更新処理 + / - をする
# @param	obj {mid=>mid, point=>10, operator=>'-'} = 10ポイントマイナス {mid=>mid, point=>10, operator=>'+'} = 10ポイントプラス
# @return	
#******************************************************
sub updatePointSQL {
	my $self	= shift;
	my $tmphash	= shift || return undef;
	unless(exists($tmphash->{owid}) || exists($tmphash->{point}) || exists($tmphash->{operator})) { return undef; }

	my $sqlMoji = sprintf "UPDATE %s SET point=(point %s ?) WHERE owid=?;", $self->{table}, $tmphash->{operator};
	my $rv = $self->{this_dbh}->do($sqlMoji, undef, $tmphash->{point}, $tmphash->{owid});
	return $rv;
}


#******************************************************
# @access	public
# @desc		カラムguidの値を条件で会員情報を更新
# @param	string	$guid
# @param	hashobj {guid => guid, columns => { column_name => value } }
#
#******************************************************
sub updateMemberDataByGUIDSQL {
	my $self = shift;
	my $hashobj = shift || return undef;

	return undef if !exists($hashobj->{guid}) || "" eq $hashobj->{guid};

	my $sqlMoji = sprintf " UPDATE %s SET %s = ? WHERE guid='%s';", $self->{table}, join( '=?,', map { $_ } keys %{$hashobj->{columns}} ), $hashobj->{guid};
	my @placeholder;
	map { push( @placeholder, $hashobj->{columns}->{$_} ) } keys %{$hashobj->{columns}};

	my $rv = $self->{this_dbh}->do($sqlMoji, undef, @placeholder);

	return $rv;
}


#******************************************************
# @access	public
# @desc		カラムsubnoの値を条件でguidを更新
# @param	hashobj { guid => guid, subno => subno }
#
#******************************************************
sub regist_guid_By_subnoSQL {
    my $self = shift;
    my $hashobj = shift || return undef;

    return undef if !exists($hashobj->{subno}) || "" eq $hashobj->{subno};

    my $sql = sprintf("UPDATE %s SET guid=? WHERE subno=?", $self->table());
    my $rv = $self->{this_dbh}->do($sql, undef, $hashobj->{guid}, $hashobj->{subno});
    return $rv;
}


#******************************************************
# @desc		会員種別が 正常登録会員の場合だけ、正常から不正に変更
# @param	guid会員のGUID
# @param	
# @return	return code
#******************************************************
sub updateMemberStatus_to_IllegalMember {
	my $self = shift;
	my $guid = shift || return undef;

	my $sql = sprintf(" UPDATE %s
 SET memberstatus_flag = CASE WHEN memberstatus_flag=2
 							THEN 32
 					ELSE memberstatus_flag END
 WHERE guid=?;", $self->{table});

	my $rv = $self->{this_dbh}->do($sql, undef, $guid);
	return $rv;
	#return (($rv eq '0E0') ? undef : 1);
}


#******************************************************
# @desc		会員を退会処理 退会会員を会員処理
# @param	guid会員のGUID
# @param	
# @return	return code
#******************************************************
sub updateMemberStatus {
	my $self = shift;
	my $guid = shift || return undef;

	my $sql = sprintf(" UPDATE %s
 SET status_flag = CASE WHEN status_flag=2
                            THEN 4
                        WHEN status_flag=4
                            THEN 2
 					    ELSE status_flag END
 WHERE guid=?;", $self->{table});

	my $rv = $self->{this_dbh}->do($sql, undef, $guid);
	return $rv;
	#return (($rv eq '0E0') ? undef : 1);
}


1;

