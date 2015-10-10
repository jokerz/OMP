#******************************************************
# @desc		会員ポイントランキングプラグイン
# @package	MyClass::Plugin::UserPointRanking
# @author	Iwahase Ryo
# @create	2010/03/12
# @version	1.00
#******************************************************

package MyClass::Plugin::UserPointRanking;

use strict;
use warnings;
no warnings 'redefine';
use base 'MyClass::Plugin';

use MyClass::WebUtil;

#******************************************************
# @desc		hook  会員ポイントランキング１覧表示
# @param	
# @param	
# @return	
#******************************************************
sub userpointranking :Hook('HOOK.USERPOINTRANKING') {
    my ($self, $c, $arg) = @_;

    my $return_obj = {};
    my $yyyymm = MyClass::WebUtil::GetTime(6);
  ## ランキングオブジェクトファイル
    my $userpointranking_objectfile = sprintf("%s/%s.obj", $c->cfg->param('USERPOINT_RANK_DIR'), $yyyymm);

    my $aryref;
    eval {
        $aryref = MyClass::WebUtil::publishObj( { file=>$userpointranking_objectfile } );
    };
    $return_obj->{LoopRankingList} = $#{ $aryref };
    for (my $i = 0; $i <= $return_obj->{LoopRankingList}; $i++) {
        $return_obj->{owid}->[$i]      = $aryref->[$i]->[0];
        $return_obj->{nickname}->[$i]  = $aryref->[$i]->[1];
        $return_obj->{SUM_POINT}->[$i] = $aryref->[$i]->[2];
        $return_obj->{my_rank}->[$i]   = $i+1;
    }

    $return_obj->{'If.HOOK.USERPOINTRANKING'} = 1;

    return $return_obj;
}




#******************************************************
# @desc		会員ランキングのポイント取得先広告リスト
# @param	rk 
# @return	
#******************************************************
sub list_ad_by_userrank :Method {
    my ($self, $c, $args) = @_;

	my $q    = $c->query();
    my $a    = $q->param('a');
    my $o    = $q->param('o');
	my $rank = $q->param('rk');

    my $return_obj = {};

    my $yyyymm = MyClass::WebUtil::GetTime(6);
  ## ランキングオブジェクトファイル
    my $userpointranking_objectfile = sprintf("%s/%s.obj", $c->cfg->param('USERPOINT_RANK_DIR'), $yyyymm);

    my $aryref;
    eval {
        $aryref = MyClass::WebUtil::publishObj( { file=>$userpointranking_objectfile } );
    };

    ## 配列の要素数は実際のランクより-1のため
    my $ranker = $aryref->[$rank-1];
    $return_obj->{owid}      = $ranker->[0];
    $return_obj->{nickname}  = $ranker->[1];
    $return_obj->{SUM_POINT} = $ranker->[2];
    $return_obj->{my_rank}   = $rank;
    $return_obj->{LoopADList} = $#{ $ranker->[3] };
    for (my $j = 0; $j <= $return_obj->{LoopADList}; $j++) {
        $return_obj->{ad_id}->[$j]   = $ranker->[3]->[$j]->[0];
        $return_obj->{ad_name}->[$j] = $ranker->[3]->[$j]->[1];
        $return_obj->{PPTBKURL}->[$j] = sprintf("/%s?guid=ON&ad_id=%s", $c->cfg->param('POINT_BACK_ADVERTISEMENT_SCRIPT_NAME'), $return_obj->{ad_id}->[$j]);
    }

    $return_obj;
}


#sub previous_userpointranking {}

sub class_component_plugin_attribute_detect_cache_enable { 0 }

1;