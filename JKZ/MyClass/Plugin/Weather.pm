#******************************************************
# @desc		お天気プラグイン
# @package	MyClass::Plugin::Weather
# @author	Iwahase Ryo
# @create	2010/01/08
# @update	
# @version	1.00
#******************************************************

package MyClass::Plugin::Weather;

use strict;
use warnings;
no warnings 'redefine';
use base 'MyClass::Plugin';
use XML::TreePP;

use MyClass::UsrWebDB;
use MyClass::WebUtil;

sub weather :Hook('HOOK.WEATHER') {

	my ($self, $c, $args) = @_;

	#my $period = $_[0] ? shift : 'today';
	my $period = 'today';	

	## xml取得先の天気地域コード
	my @weather_area_code = (1,17,22,25,20,27,31,54,56,58,60,67,63,70,50,44,46,48,75,72,40,34,38,42,77,79,81,82,84,86,95,92,88,90,97,101,103,104,107,110,122,118,124,114,128,132,136);
	my $keycode = $period . '_' . $weather_area_code[(log($c->attrAccessUserData("prefecture")) / log(2)) - 1];
	#my $keycode = $period . '_' . '13'; 

	my $memcached = MyClass::UsrWebDB::MemcacheInit();

	my $obj = $memcached->get("weather:$keycode");
	if (!$obj) {

		## 天気予報取得地域を会員居住区に合わせる
		my $param = 'city='
				  . $weather_area_code[(log($c->attrAccessUserData("prefecture")) / log(2)) - 1]
				  . '&day='
				  . $period
				  ;

		my $weather_url = $c->cfg->param('WEATHER_HACK_URL')
						. $param
						;

		my $tpp = XML::TreePP->new();
		$obj = $tpp->parsehttp( GET => $weather_url );
		$memcached->add("weather:$keycode", $obj, 3600);
	}

	my $return_obj = {};
	$return_obj->{weather_area}	=   MyClass::WebUtil::convertByNKF('-s', $obj->{lwws}->{title});
	$return_obj->{max_temperature}= !ref ($obj->{lwws}->{temperature}->{max}->{celsius}) ? $obj->{lwws}->{temperature}->{max}->{celsius} : '--';
	$return_obj->{min_temperature}= !ref ($obj->{lwws}->{temperature}->{min}->{celsius}) ? $obj->{lwws}->{temperature}->{min}->{celsius} : '--';
	
	#$return_obj->{weather}		= WebUtil::mbconvertU2S($obj->{lwws}->{telop});
	$return_obj->{weather}		= MyClass::WebUtil::convertByNKF('-s', $obj->{lwws}->{telop});
	
	$return_obj->{weather_icon}	= $obj->{lwws}->{image}->{url};


	$return_obj->{'If.HOOK.WEATHER'} = 1;
    $return_obj;
}

sub class_component_plugin_attribute_detect_cache_enable { 0 }

1;