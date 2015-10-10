#******************************************************
# @desc		ニュースプラグイン
# @package	MyClass::Plugin::News
# @author	Iwahase Ryo
# @create	2010/01/11
# @update	
# @version	1.00
#******************************************************

package MyClass::Plugin::News;

use strict;
use warnings;
no warnings 'redefine';
use base 'MyClass::Plugin';

use MyClass::WebUtil;

sub news :Hook('HOOK.NEWS') {
    my ($self, $c, $args) = @_;

    ## ヤフーニュースのオブジェクト
	my $objectfile = $c->cfg->param('NEWS_CONTENTS_OBJ');
    my $obj = {};
    my $return_obj = {};
    eval {
        $obj = MyClass::WebUtil::publishObj( { file=>$objectfile } );
    };
    if ($@) {
	    print "fail \n";
	    $return_obj->{IfFailOpenYahooNews} = 1;
    }
    else {
        $return_obj->{LoopYahooNews} = $#{ $obj->{ResultSet}->{Result} };

        for (my $i = 0; $i <= $return_obj->{LoopYahooNews}; $i++) {
        	$return_obj->{news_datetime}->[$i]  = substr($obj->{ResultSet}->{Result}->[$i]->{datetime}, 5, 11);
        	$return_obj->{news_datetime}->[$i]  =~ s!T! !g;
        	$return_obj->{news_category}->[$i]  = MyClass::WebUtil::convertByNKF('-s', $obj->{ResultSet}->{Result}->[$i]->{category});
    	    $return_obj->{news_topicname}->[$i] = MyClass::WebUtil::convertByNKF('-s', $obj->{ResultSet}->{Result}->[$i]->{topicname});
        	$return_obj->{news_title}->[$i]     = MyClass::WebUtil::convertByNKF('-s', $obj->{ResultSet}->{Result}->[$i]->{title});
        	$return_obj->{news_url}->[$i]       = MyClass::WebUtil::convertByNKF('-s', $obj->{ResultSet}->{Result}->[$i]->{url});
        }
        $return_obj->{IfSuccessOpenYahooNews} = 1;
    }

    $return_obj->{'If.HOOK.NEWS'} = 1;

    $return_obj;

}

1;