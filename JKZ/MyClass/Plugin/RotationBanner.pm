#******************************************************
# @desc		ローテーションバナープラグイン
# @package	MyClass::Plugin::RotationBanner
# @author	Iwahase Ryo
# @create	2010/01/12
# @update	
# @version	1.00
#******************************************************

package MyClass::Plugin::RotationBanner;

use strict;
use warnings;
no warnings 'redefine';
use base 'MyClass::Plugin';

use MyClass::WebUtil;

sub banner :Hook('HOOK.ROTATIONBANNER') {
    my ($self, $c, $args) = @_;


	my ($self, $dbh, $bannerid) = @_;

	#******************************
	# 1. バナーデータを取得・生成
	#******************************
	my $hashbanner = {};
	my $basestr = 'BANNER';

	my $dbh = $c->getDBConnection();
	$self->setDBCharset('SJIS');

	my $sql = "SELECT id, id1 FROM tBannerDataM WHERE id1=? AND (valid_date <= NOW() AND expire_date >= NOW()) AND status_flag=? LIMIT 1;";

	my ($id, $id1) = $dbh->selectrow_array($sql, undef, $bannerid, 2);

	## 該当データが場合はreturnで終了
	if (!$id || !$id1) {
		return;
	}
	#my $aryref = $dbh->selectall_arrayref($sql, undef, $bannerid, 2);	
	#if (!$aryref) {
	#	return;
	#}

	$sql = "SELECT id, id1, id2, banner_url, banner_text, image_flag, image_name FROM tBannerDataF WHERE 
 id1=? AND id2=?
 AND status_flag=2
 AND carrier & ?
 AND sex & ?
 AND personality & ?
 AND bloodtype & ?
 AND occupation & ?
 AND prefecture & ?
";

	#******************************
	# 2. 現在有効であるバナーマスターデータから属性にあったバナー取得
	#******************************
	#foreach (@{$aryref}) {
		## index keyはid1 idとなる
		my $rowref = $dbh->selectall_arrayref($sql, { Columns => {} },
			$id1,#$_->[1],
			$id,#$_->[0],
			$c->attrAccessUserData("carrier"),
			$c->attrAccessUserData("sex"),
			$c->attrAccessUserData("personality"),
			$c->attrAccessUserData("bloodtype"),
			$c->attrAccessUserData("occupation"),
			$c->attrAccessUserData("prefecture")
		);

		## 該当データが場合はreturnで終了
		if (!$rowref || 1 > @{$rowref}) {
			return;
		}
		my $rows = @{$rowref};
		my $rand = int(rand($rows));
		my $args = '?c=' . $self->_encryptParamC()
				 . '&bid=' . $rowref->[$rand]->{id1} . ':' . $rowref->[$rand]->{id2}
				 . '&bdid=' . $rowref->[$rand]->{id}
				 ;
		#******************************
		# 3.バナーのURLﾀｸﾞを生成
		#******************************
		my $tmpstr = $basestr . $id1;
		my $img_id = $rowref->[$rand]->{id1} . $rowref->[$rand]->{id2} . $rowref->[$rand]->{id};
		$hashbanner->{$tmpstr} = 2 == $rowref->[$rand]->{image_flag}
								? '<a href="' . $self->{cfg}->param('BANNER_SCRIPT_NAME') . $args . '">'
									. '<img src="' . $self->_IMAGE_BANNER_SCRIPT_URL() . '?id=' . $img_id
									. '&b=1" /></a>'
								: '<a href="' . $self->{cfg}->param('BANNER_SCRIPT_NAME') . $args . '">' . $rowref->[$rand]->{banner_text} . '</a>'
								;

		#******************************
		# 4.バナー集計データの実行
		#******************************
		## Modified 2008/12/15
		my $tBannerCountF = 'HP_logdata.tBannerCountF_' . WebUtil::GetTime("5");

		my $cntupsql = "
 UPDATE $tBannerCountF SET impression=impression+1,last_impression=NOW()
 WHERE id1='$rowref->[$rand]->{id1}'
 AND id2='$rowref->[$rand]->{id2}' 
 AND id3='$rowref->[$rand]->{id}' 
 AND clickdate=DATE_FORMAT(NOW(), '%Y-%m-%d')
";
	    my $sth = $dbh->prepare($cntupsql);
		if ($sth->execute() < 1) {
			$dbh->do("
 INSERT INTO $tBannerCountF (id1, id2, id3, clickdate, impression, last_impression)
 VALUES ('$rowref->[$rand]->{id1}', '$rowref->[$rand]->{id2}', '$rowref->[$rand]->{id}', NOW(), 1, NOW())
 			");
		}
	## Modified 2008/12/03 END

	#******************************
	# 最後に生成したバナーURLデータを返す
	#******************************
	return $hashbanner;



}



1;