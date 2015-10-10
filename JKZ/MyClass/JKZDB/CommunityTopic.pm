#******************************************************
# @desc		
#			
# @package	MyClass::JKZDB::CommunityTopic
# @access	public
# @author	Iwahase Ryo AUTO CREATE BY createClassDB
# @create	Fri Jun 11 19:25:37 2010
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
package MyClass::JKZDB::CommunityTopic;

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
	my $table = 'OMP.tCommunityTopicF';
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
$self->{columnslist}->{community_topic_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{community_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{community_topic_title}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{community_topic}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{community_topicowner_owid}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{community_topicowner_nickname}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{community_topicowner_id}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[7];
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
$self->{columns}->{community_topic_id},
$self->{columns}->{community_id},
$self->{columns}->{community_topic_title},
$self->{columns}->{community_topic},
$self->{columns}->{community_topicowner_owid},
$self->{columns}->{community_topicowner_nickname},
$self->{columns}->{community_topicowner_id},
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

	$self->{columns}->{community_id} = $param->{community_id};

	## ここでPrimaryKeyが設定されている場合はUpdate
	## 設定がない場合はInsert
	if ($self->{columns}->{community_id} < 0) {
		##1. AutoIncrementでない場合はここで最大値を取得
		##2. 挿入 

## Modified 2009/09/29 BEGIN

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
		push( @{ $sqlref->[0] }, "community_topic_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_topic_id} ) if $param->{community_topic_id} != "";
		push( @{ $sqlref->[0] }, "community_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_id} ) if $param->{community_id} != "";
		push( @{ $sqlref->[0] }, "community_topic_title" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_topic_title} ) if $param->{community_topic_title} ne "";
		push( @{ $sqlref->[0] }, "community_topic" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_topic} ) if $param->{community_topic} ne "";
		push( @{ $sqlref->[0] }, "community_topicowner_owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_topicowner_owid} ) if $param->{community_topicowner_owid} != "";
		push( @{ $sqlref->[0] }, "community_topicowner_nickname" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_topicowner_nickname} ) if $param->{community_topicowner_nickname} ne "";
		push( @{ $sqlref->[0] }, "community_topicowner_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_topicowner_id} ) if $param->{community_topicowner_id} ne "";
		push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
		push( @{ $sqlref->[0] }, "lastupdate_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{lastupdate_date} ) if $param->{lastupdate_date} ne "";

		#************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

		$sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
		$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

		return $rv; # return value

	} else {

		map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
		$sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE community_id= '$self->{columns}->{community_id}';", join('=?,', @{ $sqlref->[0] }));
		#$rv = $self->executeQuery($sqlMoji, $sqlref->[2]);
		$rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

		return $rv; # return value

	}

## Modified 2009/09/29 END
}


1;

