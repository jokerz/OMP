#******************************************************
# @desc        
#            
# @package    MyClass::JKZDB::BannerCount
# @access    public
# @author    Iwahase Ryo AUTO CREATE BY ./createClassDB
# @create    Tue Jan 12 18:36:13 2010
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
package MyClass::JKZDB::BannerCount;

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
    my $table = 'OMP.tBannerCountF';
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
$self->{columnslist}->{bannerm_id}->[$i] = $aryref->[$i]->[0];
$self->{columnslist}->{bannerdatam_id}->[$i] = $aryref->[$i]->[1];
$self->{columnslist}->{bannerdataf_id}->[$i] = $aryref->[$i]->[2];
$self->{columnslist}->{clickdate}->[$i] = $aryref->[$i]->[3];
$self->{columnslist}->{click}->[$i] = $aryref->[$i]->[4];
$self->{columnslist}->{impression}->[$i] = $aryref->[$i]->[5];
$self->{columnslist}->{last_click}->[$i] = $aryref->[$i]->[6];
$self->{columnslist}->{last_impression}->[$i] = $aryref->[$i]->[7];
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
$self->{columns}->{bannerm_id},
$self->{columns}->{bannerdatam_id},
$self->{columns}->{bannerdataf_id},
$self->{columns}->{clickdate},
$self->{columns}->{click},
$self->{columns}->{impression},
$self->{columns}->{last_click},
$self->{columns}->{last_impression}
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
    my ($self, $param, $flag) = @_;

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

    $self->{columns}->{bannerm_id}     = $param->{bannerm_id};
    $self->{columns}->{bannerdatam_id} = $param->{bannerdatam_id};
    $self->{columns}->{bannerdataf_id} = $param->{bannerdataf_id};
    $self->{columns}->{clickdate}      = $param->{clickdate};

    ## ここでPrimaryKeyが設定されている場合はUpdate
    ## 設定がない場合はInsert
    #if ($self->{columns}->{clickdate} < 0) {
    if ($flag < 0) {
        ##1. AutoIncrementでない場合はここで最大値を取得
        ##2. 挿入 

## Modified 2009/09/29 BEGIN

        #************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED BEGIN ************************
        push( @{ $sqlref->[0] }, "bannerm_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bannerm_id} ) if $param->{bannerm_id} != "";
        push( @{ $sqlref->[0] }, "bannerdatam_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bannerdatam_id} ) if $param->{bannerdatam_id} != "";
        push( @{ $sqlref->[0] }, "bannerdataf_id" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{bannerdataf_id} ) if $param->{bannerdataf_id} != "";
        push( @{ $sqlref->[0] }, "clickdate" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{clickdate} ) if $param->{clickdate} ne "";
        push( @{ $sqlref->[0] }, "click" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{click} ) if $param->{click} != "";
        push( @{ $sqlref->[0] }, "impression" ), push( @{ $sqlref->[1] }, "?" ), push( @{ $sqlref->[2] }, $param->{impression} ) if $param->{impression} != "";
        push( @{ $sqlref->[0] }, "last_click" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{last_click} ) if $param->{last_click} ne "";
        push( @{ $sqlref->[0] }, "last_impression" ), push( @{ $sqlref->[1] }, "NOW()" );#, push( @{ $sqlref->[2] }, $param->{last_impression} ) if $param->{last_impression} ne "";

        #************************ AUTO GENERATED COLUMNS AND PLACEHOLDERS HAS BENN COMBINED   END ************************

        $sqlMoji = sprintf("INSERT INTO %s (%s) VALUES (%s)", $self->{table}, join(',', @{ $sqlref->[0] }), join(',', @{ $sqlref->[1] }));
        $sqlMoji .= " ON DUPLICATE KEY UPDATE click=click+1;";

        $rv = $self->executeQuery($sqlMoji, $sqlref->[2]);

        return $rv; # return value

    } else {

        map { exists ($self->{columns}->{$_}) ? push (@{ $sqlref->[0] }, $_) && push (@{ $sqlref->[1] }, $param->{$_}) : ""} keys %$param;
        $sqlMoji = sprintf("UPDATE $self->{table} SET %s =? WHERE
 bannerm_id     = '$self->{columns}->{bannerm_id}' AND
 bannerdatam_id = '$self->{columns}->{bannerdatam_id}' AND
 bannerdataf_id = '$self->{columns}->{bannerdataf_id}' AND
 clickdate      ='$self->{columns}->{clickdate}';", join('=?,', @{ $sqlref->[0] }));

        $rv = $self->executeQuery($sqlMoji, $sqlref->[1]);

        return $rv; # return value

    }

## Modified 2009/09/29 END
}


#******************************************************
# @desc     SET click=click+1を実行
# @param    hash obj { 
# @param    
# @return   
#******************************************************
sub updateClick {
    my $self = shift;
    my $args = shift;

    my $sqlMoji = sprintf("UPDATE %s SET click=click+1, last_click=NOW() WHERE bannerm_id=? AND bannerdatam_id =? bannerdataf_id=? AND clickdate=?", $self->table);
    my $rc = $self->dbh->do($sqlMoji, undef, $args->{bannerm_id}, $args->{bannerdatam_id}, $args->{bannerdataf_id}, $args->{clickdate}); 

    return $rc;
}


#******************************************************
# @desc     
# @param    
# @param    
# @return   
#******************************************************
sub getSUMCLICKIMPRESSIONByID {
    my $self = shift;
    unless (@_) {
        ## 引数がない場合はエラー
        return;
    }
    my ($id1, $id2) = @_;
    my $sqlMoji = sprintf("SELECT SUM(click) AS SUMCLICK, SUM(impression) AS SUMIMPRESSION FROM %s WHERE bannerm_id=? AND bannerdatam_id=?;", $self->table);

    my @array = $self->dbh->selectrow_array($sqlMoji, undef, $id1, $id2);

    return (\@array);
}


#******************************************************
# @desc     登録バナーの集計データをIDと掲載期間の年から取得
# @param    id1, id2 year
# @return    
#******************************************************
sub getSumOfClickAndImpressionByID_Period {
    my $self = shift;
    unless (@_) {
        ## 引数がない場合はエラー
        return;
    }
    my ($id1, $id2, $year) = @_;

    my $table = $self->switchMRG_MyISAMTableSQL({ separater=>'_',value=>$year });
    my $sqlMoji = sprintf("SELECT SUM(click) AS SUMCLICK, SUM(impression) AS SUMIMPRESSION FROM %s WHERE bannerm_id=? AND bannerdatam_id=?;", $table);

    my @array = $self->dbh->selectrow_array($sqlMoji, undef, $id1, $id2);

    return (\@array);
}


1;

