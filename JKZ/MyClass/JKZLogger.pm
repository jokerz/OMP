#******************************************************
# @desc		アクセスログ・ページログデータベースにデータを格納する
# @package	MyClass::JKZLogger
# @access	public
# @author	Iwahase Ryo
# @create	2010/01/12
# @update   2010/01/26 saveAccessLog savePageViewLogを追加
# @update   2010/02/26 ページビューをとるときにtmplt_nameに変更(もともとはtmplt_id)
# @update   2010/03/19 商品ページログ追加
# @version	1.00
#******************************************************
package MyClass::JKZLogger;

use 5.008005;
our $VERSION = '1.00';

use strict;

use MyClass::WebUtil;
use MyClass::UsrWebDB;
use MyClass::JKZDB::AccessLog;
use MyClass::JKZDB::PageViewLog;
use MyClass::JKZDB::LoginLog;
use MyClass::JKZDB::AdvAccessLog;
use MyClass::JKZDB::MediaAccessLog;
use MyClass::JKZDB::ProductViewLog;

#******************************************************
# @access	public
# @desc		コンストラクタ
# @param	obj owid carrier, guid, acd, tmplt_id, tmplt_name
#******************************************************
sub new {
    my $class = shift;
    my $hash  = shift if @_;
    my $self = {};
    my $dbh = MyClass::UsrWebDB::connect();
    $self = {
        dbh         => $dbh,
        owid        => undef,
        guid        => undef,
        carrier     => undef,
        acd         => undef,
        #tmplt_id	=> undef,
        tmplt_name  => undef,
        ip          => undef,
        host        => undef,
        useragent   => undef,
        referer		=> undef,
        product_id  => undef,
        product_name=> undef,
    };

    bless($self, $class);

    $self->{owid}         = $hash->{owid};
    $self->{guid}         = $hash->{guid};
    $self->{carrier}      = $hash->{carrier};
    $self->{acd}          = $hash->{acd}  || 'NULL'; ## なければ文字列"NULL"を挿入
    #$self->{tmplt_id}	  = $hash->{tmplt_id} if exists($hash->{tmplt_id});
    $self->{tmplt_name}   = $hash->{tmplt_name} if exists($hash->{tmplt_name});
    $self->{product_id}   = $hash->{product_id} if exists($hash->{product_id});
    $self->{product_name} = $hash->{product_name} if exists($hash->{product_name});
    $self->_initialize();

    return($self);
}


#******************************************************
# @access	private
# @desc		
#******************************************************
sub _initialize {
    my $self = shift;

    my $remoteinfo      = MyClass::WebUtil::getIP_Host();
    $self->{ip}         = $remoteinfo->{ip};
    $self->{host}       = $remoteinfo->{host};
    $self->{useragent}  = $remoteinfo->{agent};
    $self->{referer}    = $remoteinfo->{referer};

    return $self;
}


#******************************************************
# @access	public
# @desc		アクセスログをとります。
# @param	
# @return	ログのインサートに失敗しても続行
#******************************************************
sub saveAccessLog {
    my $self = shift;

    my $insertData  = {
        id        => -1,
        acd       => $self->{acd},
        carrier   => 2 ** $self->{carrier},
        guid      => $self->{guid},
        ip        => $self->{ip},
        host      => $self->{host},
        useragent => $self->{useragent},
        referer   => $self->{referer},
    };

    my $dbh = $self->{dbh};
    my $myAccessLog = MyClass::JKZDB::AccessLog->new($dbh);
## yyyymmに変更 2010/02/26
## table名＋ _ ＋ yyyymm の場合はswitchMRG_MyISAMTableSQLメソッド
    $myAccessLog->switchMRG_MyISAMTableSQL( {separater=>'_',value=>MyClass::WebUtil::GetTime("5")} );

## テーブル名がtXyyyyF_MMのため変更
# %02d 月 つきの指定が無い場合全体になる。
    #$myAccessLog->switchDataBaseSQL(MyClass::WebUtil::GetTime("11"));
    $myAccessLog->executeUpdate($insertData);
}


#******************************************************
# @access	public
# @desc		ページビューのログをとります。
# @param	tmplt_id
# @return	引数としてのtmplt_idが無い場合は処理を実行せずundefを返す
# @return	ログのインサートに失敗しても続行
#******************************************************
sub savePageViewLog {
    my $self       = shift;
    #my $tmplt_id   = $self->{tmplt_id};
    my $tmplt_name = $self->{tmplt_name};
    my $dbh        = $self->{dbh};

    my $myPageViewLog = MyClass::JKZDB::PageViewLog->new($dbh);
## yyyymmに変更 2010/02/26
## table名＋ _ ＋ yyyymm の場合はswitchMRG_MyISAMTableSQLメソッド
    $myPageViewLog->switchMRG_MyISAMTableSQL( {separater=>'_', value=>MyClass::WebUtil::GetTime("5")} );

## テーブル名がtXyyyyF_MMのため変更
    # %02d 月 つきの指定が無い場合全体になる。
    #$myPageViewLog->switchDataBaseSQL(MyClass::WebUtil::GetTime("11"));
    $myPageViewLog->executeUpdate(
        {
            carrier		=> 2 ** $self->{carrier},
            #tmplt_id	=> $tmplt_id,
            tmplt_name  => $tmplt_name,
        }
    );
}


#******************************************************
# @access	public
# @desc		商品ビューのログをとります。
#******************************************************
sub saveProductViewLog {
    my $self       = shift;
    my $product_id   = $self->{product_id};
    my $product_name = $self->{product_name};
    my $dbh        = $self->{dbh};

    my $myProductViewLog = MyClass::JKZDB::ProductViewLog->new($dbh);
    $myProductViewLog->executeUpdate(
        {
            carrier      => 2 ** $self->{carrier},
            product_id   => $product_id,
            product_name => $product_name,
        }
    );

}


#******************************************************
# @access	
# @desc		会員ログインログをとります。
# @param	
# @return	ログのインサートに失敗しても続行
#******************************************************
sub saveLoginLog {
    my $self = shift;

    my $insertData  = {
        owid => $self->{owid},
        guid => $self->{guid},
        host => $self->{host},
    };

    my $dbh = $self->{dbh};
    my $myLoginLog = MyClass::JKZDB::LoginLog->new($dbh);
    #$myLoginLog->switchMRG_MyISAMTableSQL( {separater=>'_',value=>MyClass::WebUtil::GetTime("11")} );
    $myLoginLog->switchDataBaseSQL(MyClass::WebUtil::GetTime("11"));
    $myLoginLog->executeUpdate($insertData);

}


#******************************************************
# @access	public
# @desc		外部リンク・公告からのアクセスログ
# @param	
# @param	
# @return	
#******************************************************
sub saveAdvAccessLog {
    my $self = shift;

    my $acd = $self->{acd};
    my $dbh = $self->{dbh};

    my $myAdvAccessLog = MyClass::JKZDB::AdvAccessLog->new($dbh);
    $myAdvAccessLog->executeUpdate({ acd => $acd });
}


#******************************************************
# @access	public
# @desc		アフィリエイトからのアクセスログ
# @param	
# @param	
# @return	
#******************************************************
sub saveMediaAccessLog {
    my $self = shift;

    my $acd = $self->{acd};
    my $dbh = $self->{dbh};

    my $myMediaAccessLog = MyClass::JKZDB::MediaAccessLog->new($dbh);
    $myMediaAccessLog->executeUpdate({ acd => $acd });
}


#******************************************************
# @access	
# @desc		最終処理を実施
# @desc		データベース切断
# @param	
# @return	
#******************************************************
sub closeLogger {
    my $self = shift;
    $self->{dbh}->disconnect();
}


1;

__END__
