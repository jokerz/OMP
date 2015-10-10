#******************************************************
# @desc		コンテンツダウンロードカウンター
# @package	JKZ::JKZDownloadCounter
# @access	public
# @author	Iwahase Ryo
# @create	2009/06/07
# @version	1.00
#******************************************************
package MyClass::JKZDownloadCounter;

use 5.008005;
our $VERSION = '1.00';

use strict;

use MyClass::WebUtil;
use MyClass::UsrWebDB;
use MyClass::JKZDB::DownloadCounter;

#******************************************************
# @access	public
# @desc		コンストラクタ
# @param	obj { carrier, product_id }
#******************************************************
sub new {
	my $class = shift;
	my $hash  = shift if @_;
	my $self = {};
	my $dbh = MyClass::UsrWebDB::connect();
	$self = {
		dbh			=> $dbh,
		carrier		=> $hash->{carrier},
		product_id	=> $hash->{product_id},
	};

	return bless($self, $class);
}


#******************************************************
# @access	public
# @desc		コンテンツダウンロードカウトを実行
# @param	obj	carrier, product_id
# @return	ログのインサートに失敗しても続行
#******************************************************
sub insertCounter {
	my $self = shift;

	my $dbh = $self->{dbh};

	my $DownloadCounter = MyClass::JKZDB::DownloadCounter->new($dbh);

	$DownloadCounter->executeUpdate(
							{ carrier => $self->{carrier}, product_id => $self->{product_id} }
						);

	$self->_closeCounter();
}


#******************************************************
# @access	
# @desc		最終処理を実施
# @desc		データベース切断
# @param	
# @return	
#******************************************************
sub _closeCounter {
	my $self = shift;
	$self->{dbh}->disconnect();
}


1;

__END__

