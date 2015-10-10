package MyClass::Plugin::Horoscope;

use strict;
use warnings;
use base 'MyClass::Plugin';

#use base 'Class::Component::Plugin';

# 占い情報取得するなら
#use WebService::JugemKey::Horoscope;
use WebUtil;


#******************************************************
# @access	
# @desc		本日占い情報を取得
# @return	
#******************************************************
sub getHoroscopeToday :Method {

	#***********************
	# args には {guid} {CGI} オブジェクト
	#***********************
	my ($self, $c, $args) = @_;

	use JKZ::UsrWebDB;

#	my $sysid = $c->user_guid;# || 'plugin_test';
	my $memcached = JKZ::UsrWebDB::MemcacheInit();

	#***********************
	# まずは会員が生年月日を登録しているかの判定
	#***********************
#	my $cacheObj = $memcached->get("MYSDKmemberdata:$sysid");


	#***********************
	# 占い処理部分
	#***********************
	my $thismonth = WebUtil::GetTime("6");
	$thismonth =~ s!-!/!;

	#***********************
	# キャッシュデータがあればキャッシュを利用する
	#***********************
	my $obj = $memcached->get("horoscope:$thismonth");
	if (!$obj) {
		use WebService::JugemKey::Horoscope;
	    my $horoscope = WebService::JugemKey::Horoscope->new({
        	      api_key => '',
    	          secret  => '',
	          });
		$obj = $horoscope->fetch();
		$memcached->add("horoscope:$thismonth", $obj, 1000);
	}

	my $myBirthday = '1975/09/05';
	my $pkg = __PACKAGE__;
	my $msg = sprintf("<br />PLUGGED METHOD : %s::getHoroscopeToday <br />", $pkg);

	my $tmpobj = $obj->get_today( { birthday => $myBirthday } );
	my $return_obj = {
		horoscope_sign		=> WebUtil::convertByNKF('-s', $tmpobj->{sign}),
		horoscope_content	=> WebUtil::convertByNKF('-s', $tmpobj->{content}),
		ERROR_MSG			=> $msg,
	};

	map {
		my $pic = '<img src="/image/' . $_ . '.gif" />&nbsp;';
		$return_obj->{$_} = ($tmpobj->{$_} =~ /[0-9]/ && 'rank' ne $_) ? $pic x $tmpobj->{$_} : WebUtil::convertByNKF('-s', $tmpobj->{$_})
	} keys %{ $tmpobj };

	return ($return_obj);

}


1;
