#******************************************************
# @desc      
#            
# @package    MyClass::JKZDB::MyMessageBoard
# @access    public
# @author    Iwahase Ryo AUTO CREATE BY createClassDB
# @create    Tue Jul  6 13:22:43 2010
# @version    1.30
# @update    2008/05/30 executeUpdate処理の戻り値部分
# @update    2008/03/31 JKZ::DB::JKZDBのサブクラス化
# @update    2009/02/02 ディレクトリ構成をJKZ::JKZDBに変更
# @update    2009/02/12 リスティング処理を追加
# @update    2009/09/28 executeUpdateメソッドの処理変更
# @version   1.10
# @version   1.20
# @version   1.30
#******************************************************
package MyClass::JKZDB::MyMessageBoard;

use 5.008005;
use strict;
our $VERSION ='1.30';

use base qw(MyClass::JKZDB);


#******************************************************
# @access    public
# @desc      コンストラクタ
# @param     
# @return    
# @author    
#******************************************************
sub new {
    my ($class, $dbh) = @_;
    my $table = 'OMP.tMyMessageBoardF';
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
$self->{columnslist}->{msg_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{toid}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{owid}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{private_flag}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{message}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{neighbor_nickname}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{nickname}->[$i] = $aryref->[$i]->[6];
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
$self->{columns}->{msg_id},
$self->{columns}->{toid},
$self->{columns}->{owid},
$self->{columns}->{private_flag},
$self->{columns}->{message},
$self->{columns}->{neighbor_nickname},
$self->{columns}->{nickname},
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
    #             [ values array      ],        2
    #            ]
    #******************************************************
    my $sqlref;
    my $rv;

    if ($self->{this_dbh} == "") {
        #エラー処理
    }

    $self->{columns}->{msg_id} = $param->{msg_id};
    $self->{columns}->{toid}   = $param->{toid};

    ## ここでPrimaryKeyが設定されている場合はUpdate
    ## 設定がない場合はInsert
    if ($self->{columns}->{msg_id} < 0) {

        #************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
        #push( @{ $sqlref->[0] }, "msg_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{msg_id} ) if $param->{msg_id} != "";
        push( @{ $sqlref->[0] }, "toid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{toid} ) if $param->{toid} != "";
        push( @{ $sqlref->[0] }, "owid" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{owid} ) if $param->{owid} != "";
        push( @{ $sqlref->[0] }, "private_flag" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{private_flag} ) if $param->{private_flag} != "";
        push( @{ $sqlref->[0] }, "message" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{message} ) if $param->{message} ne "";
        push( @{ $sqlref->[0] }, "neighbor_nickname" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{neighbor_nickname} ) if $param->{neighbor_nickname} ne "";
        push( @{ $sqlref->[0] }, "nickname" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{nickname} ) if $param->{nickname} ne "";
        push( @{ $sqlref->[0] }, "registration_date" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{registration_date} ) if $param->{registration_date} ne "";

        #************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

        $sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s);", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
        $rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

        return $rv; # return value

    } else {

        map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
        $sqlMoji = sprintf("UPDATE $self->{table} SET %s =?  WHERE toid= '$self->{columns}->{toid}' AND msg_id='$self->{msg_id}';", join('=?,', @{ $sqlref->[0] }));
        $rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

        return $rv; # return value

    }
}


#******************************************************
# @desc     掲示板からメッセージの削除
# @param    hash { toid, msg_id }
# @param    
# @return   
#******************************************************
sub remove_message {
    my $self    = shift;
    my $ref     = shift || return undef;

    my $sqlMoji = sprintf("DELETE FROM %s WHERE toid=? AND msg_id=?;", $self->table);
    my $rv      = $self->dbh->do($sqlMoji, undef, $ref->{toid}, $ref->{msg_id});

    return $rv;


}



1;

