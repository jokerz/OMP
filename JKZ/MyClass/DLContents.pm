#******************************************************
# @desc		ダウンロードコンテンツ処理
# @package	JKZ::JKZUI::DLContents
# @access	public
# @author	Iwahase Ryo
# @create	2009/03/06
# @update	
# @version	1.00
#******************************************************
package JKZ::JKZUI::DLContents;

use strict;
use warnings;
use 5.008005;
our $VERSION = '1.00';

use base qw(JKZ::JKZUI::UIMember);

#use JKZ::JKZSession;
#use JKZ::JKZDB::Member;

use Data::Dumper;

#******************************************************
# @access	public
# @desc		コンストラクタ
# @param	
# @return	
#******************************************************
sub new {
	my ($class, $cfg) = @_;

	return $class->SUPER::new($cfg);
}


sub run {
	my $self = shift;

	$self->SUPER::run();
}


#******************************************************
# @access	public
# @desc		dispatch パラメーターの値により処理を決定
# @param	
# @return	
#******************************************************
sub dispatch {
	my $self = shift;
	my $method = $self->getAction();

	$self->setMicrotime("t0");

	#*************************************
	# 会員か非会員認証とセッション開始 Modofied 2009/03/02
	# ダウンロードクラスのため認証成功でhtml出力はしない。認証NGの場合はエラー画面出力
	#*************************************
	if ($self->can_login()) {
		$self->can($method) ? $self->$method() : $self->printErrorPage();
	} else {
		my $obj = {};
		$obj->{MAINURL} = $self->MAIN_URL(1);
		$obj->{MAINURL} .= '&_orid=' . $self->attrAccessUserData("_orid");
		$obj->{ERROR_MSG} = $self->_ERROR_MSG("ERR_MSG10");
		$self->setTmpltID(2);
		$self->_processUserHtml($obj);
	}
}


sub _checkPublish {
	my $self = shift;
}
#******************************************************
# @access	public
# @desc		コンテンツのダウンロード
# @param	
# @return	
#******************************************************
sub dl_contents {
	my $self = shift;
	my $q = $self->getCgiQuery();

	#****************************
	# ポイント確認と消費
	#****************************
	my $guid = $self->attrAccessUserData("_sysid");
	my $publish = $self->PUBLISH_DIR() . '/3/' . $guid;

	## とりあえず、OKかNGかのフラグ
	my $DLFLAG	= 0;
	## オブジェクトフラグ
	my $OFLAG	= 0;

	## オブジェクトがある場合はポイント使わない（とりあえず)
	eval {
		my $historyobj = WebUtil::publishObj( { file=>$publish } );
	};
	if ($@) {
	#unless (defined($historyobj)) {}
		my $obj =$self->purchase();
		## pointのチェックと消費OK
		if ($obj->{ReqOK}) {
			$DLFLAG = 1;
		}
	} else {
		$DLFLAG = 1;
		$OFLAG	= 1;
	}

	if ($DLFLAG) {
		my $p_err=0;
		my $data;

		my $dldir		= $self->DL_CONTENTS_DIR();
		my $contents_id = $q->param('p');
		my $filename	= $contents_id . '.pdf';
		my $dlfile		= $dldir . '/' . $filename;

		my $type = WebUtil::figContentType($filename);

		open( FILE, $dlfile );
		binmode FILE;

		read( FILE, $data, -s FILE );

		#****************************
		# ユーザにプッシュ
		#****************************
		my $length = -s FILE;
		print 'Content-Length: '.$length."\n";
		printf "Content-disposition: attachment; filename=\"%s\""."\n", $filename;	#ユーザに見せるファイル名　関連なし
		printf "Content-Type: %s" . "\n\n", $type;

		$p_err = print $data;

		if($p_err == 0 ) {
			#&ShowMsg('ダウンロードエラーです', 0, "");
		} else { ## 正常処理完了のため
			## オブジェクトの生成
			if (!$OFLAG) {
				my $publishobj = {
					guid		=> $guid,
					product_id	=> $contents_id,
					dl_file		=> $filename,
					type		=> $type,
					dl_date		=> WebUtil::GetTime("0"),
				};
				WebUtil::publishObj({file=>$publish, obj=>$publishobj});
			}
		}
		close( FILE );
	}
}

1;
__END__
