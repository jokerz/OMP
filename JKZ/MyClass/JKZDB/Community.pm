#******************************************************
# @desc        
#            
# @package    MyClass::JKZDB::Community
# @access    public
# @author    Iwahase Ryo AUTO CREATE BY createClassDB
# @create    Fri Jun 11 19:25:19 2010
# @version    1.30
# @update    2008/05/30 executeUpdate処理の戻り値部分
# @update    2008/03/31 JKZ::DB::JKZDBのサブクラス化
# @update    2009/02/02 ディレクトリ構成をJKZ::JKZDBに変更
# @update    2009/02/12 リスティング処理を追加
# @update    2009/09/28 executeUpdateメソッドの処理変更
# @version    1.10
# @version    1.20
# @version    1.30
#******************************************************
package MyClass::JKZDB::Community;

use 5.008005;
use strict;
our $VERSION ='1.30';

use base qw(MyClass::JKZDB);


#******************************************************
# @access    public
# @desc        コンストラクタ
# @param    
# @return    
# @author    
#******************************************************
sub new {
    my ($class, $dbh) = @_;
    my $table = 'OMP.tCommunityM';
    return $class->SUPER::new($dbh, $table);
}


#******************************************************
# @access    
# @desc        SQLを実行します。
# @param    $sql
#            @placeholder
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
$self->{columnslist}->{community_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{status_flag}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{community_name}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{community_category_id}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{community_description}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{community_image_id}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{community_member_flag}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{community_topic_flag}->[$i] = $aryref->[$i]->[7];
$self->{columnslist}->{community_admin_owid}->[$i] = $aryref->[$i]->[8];
$self->{columnslist}->{community_admin_nickname}->[$i] = $aryref->[$i]->[9];
$self->{columnslist}->{community_admin_id}->[$i] = $aryref->[$i]->[10];
$self->{columnslist}->{community_total_member}->[$i] = $aryref->[$i]->[11];
$self->{columnslist}->{registration_date}->[$i] = $aryref->[$i]->[12];
$self->{columnslist}->{expire_date}->[$i] = $aryref->[$i]->[13];
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
$self->{columns}->{community_id},
$self->{columns}->{status_flag},
$self->{columns}->{community_name},
$self->{columns}->{community_category_id},
$self->{columns}->{community_description},
$self->{columns}->{community_image_id},
$self->{columns}->{community_member_flag},
$self->{columns}->{community_topic_flag},
$self->{columns}->{community_admin_owid},
$self->{columns}->{community_admin_nickname},
$self->{columns}->{community_admin_id},
$self->{columns}->{community_total_member},
$self->{columns}->{registration_date},
$self->{columns}->{expire_date}
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
# @access    public
# @desc        レコード更新処理
#            プライマリキー条件によってINSERTないしはUPDATEの処理を行ないます。
# @param    
# @return    
#******************************************************
sub executeUpdate {
    my ($self, $param) = @_;

    my $sqlMoji;
    #******************************************************
    # TYPE    : arrayreference
    #            [
    #             [ columns name array],        0
    #             [ placeholder array ],        1
    #             [ values array        ],        2
    #            ]
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
        #push( @{ $sqlref->[0] }, "community_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_id} ) if $param->{community_id} != "";
        push( @{ $sqlref->[0] }, "status_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{status_flag} ) if $param->{status_flag} != "";
        push( @{ $sqlref->[0] }, "community_name" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_name} ) if $param->{community_name} ne "";
        push( @{ $sqlref->[0] }, "community_category_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_category_id} ) if $param->{community_category_id} != "";
        push( @{ $sqlref->[0] }, "community_description" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_description} ) if $param->{community_description} ne "";
        push( @{ $sqlref->[0] }, "community_image_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_image_id} ) if $param->{community_image_id} != "";
        push( @{ $sqlref->[0] }, "community_member_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_member_flag} ) if $param->{community_member_flag} != "";
        push( @{ $sqlref->[0] }, "community_topic_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_topic_flag} ) if $param->{community_topic_flag} != "";
        push( @{ $sqlref->[0] }, "community_admin_owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_admin_owid} ) if $param->{community_admin_owid} != "";
        push( @{ $sqlref->[0] }, "community_admin_nickname" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_admin_nickname} ) if $param->{community_admin_nickname} ne "";
        push( @{ $sqlref->[0] }, "community_admin_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_admin_id} ) if $param->{community_admin_id} ne "";
        push( @{ $sqlref->[0] }, "community_total_member" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{community_total_member} ) if $param->{community_total_member} != "";
        push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";
        push( @{ $sqlref->[0] }, "expire_date" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{expire_date} ) if $param->{expire_date} ne "";

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

