#******************************************************
# @desc		ポイントバック広告プラグイン
# @package	MyClass::Plugin::PointBackAD
# @author	Iwahase Ryo
# @create	2010/02/04
# @update	2010/03/10 マイページ表示広告処理追加
# @version	1.00
#******************************************************

package MyClass::Plugin::PointBackAD;

use strict;
use warnings;
no warnings 'redefine';
use base 'MyClass::Plugin';

use MyClass::WebUtil;
use MyClass::JKZDB::Media;
use MyClass::JKZDB::MediaCategory;
use MyClass::JKZDB::MyPageMedia;

#******************************************************
# @desc		hook  メディアのカテゴリ一覧表示
# @param	
# @param	
# @return	
#******************************************************
sub pointbackcategory :Hook('HOOK.POINTBACKCATEGORY') {
    my ($self, $c, $arg) = @_;

    my $return_obj = {};
    my $mediacategoryref = $c->getFromObjectFile({ CONFIGURATION_VALUE=>'MEDIACATEGORYLIST_OBJ' });

    $return_obj->{LoopMediaCategoryList} = $#{ $mediacategoryref };

    map {
        foreach my $key ( keys %{ $mediacategoryref->[$_] } ) {
            $return_obj->{$key}->[$_] = $mediacategoryref->[$_]->{$key};
            $return_obj->{LMCMAINURL}->[$_] = $c->MEMBERMAINURL();
        }
    } 0..$return_obj->{LoopMediaCategoryList};

    $return_obj->{'If.HOOK.POINTBACKCATEGORY'} = 1;

    return $return_obj;
}


#******************************************************
# @desc		hook  MyPage用メディア覧表示
# @param	
# @param	
# @return	
#******************************************************
sub mypagepointback :Hook('HOOK.MYPAGEPOINTBACK') {
    my ($self, $c, $arg) = @_;

    my $return_obj = {};

    $return_obj->{MEMBERMAINURL} = $c->MEMBERMAINURL;

    my $dbh = $c->getDBConnection();
    $c->setDBCharset('sjis');
    my $MyPageMediaList = MyClass::JKZDB::MyPageMedia->new($dbh);
    my $carrier   = 2**$c->user_carriercode();
    my $aryref    = $MyPageMediaList->getSpecificValuesSQL(
        {
            columnslist => [
                     'ad_id',
                     'ad_name',
                     'point',
                     'ad_16words_text',
            ],
            whereSQL    => "status_flag=2 AND carrier & ?",
#            orderbySQL  => $orderby,
            placeholder => [$carrier],
        }
    );

    $return_obj->{LoopMyPagePointBackMediaList} = $#{ $aryref->{ad_id} };

    if (0 <= $return_obj->{LoopMyPagePointBackMediaList}) {
        no strict 'refs';
        map {
            foreach my $key (%{ $aryref }) {
                $return_obj->{$key}->[$_] = $aryref->{$key}->[$_];
            }
            $return_obj->{ad_16words_text}->[$_] = MyClass::WebUtil::yenRyenN2br($return_obj->{ad_16words_text}->[$_]);
            $return_obj->{PPTBKURL}->[$_] = sprintf("/%s?guid=ON&ad_id=%s", $c->cfg->param('POINT_BACK_ADVERTISEMENT_SCRIPT_NAME'), $return_obj->{ad_id}->[$_]);
        } 0..$return_obj->{LoopMyPagePointBackMediaList};
    }

    $return_obj->{'If.HOOK.MYPAGEPOINTBACK'} = 1;

    return $return_obj;
}



#******************************************************
# @desc		メディアをカテゴリごとに表示
# @param	mc 
# @return	
#******************************************************
sub list_media_by_mc :Method {
    my ($self, $c, $args) = @_;

	my $q                = $c->query();
    my $a                = $q->param('a');
    my $o                = $q->param('o');
	my $mediacategory_id = $q->param('mc');
    my $offset           = $q->param('off') || 0;
	my $record_limit     = 20;
	my $condition_limit  = $record_limit+1;

    my $return_obj = {};

    ## Modified 2010/03/01
    ## by=pt は point を昇順でソート デフォルトは新着順
    ## by=pt_a はpointを 降順でソート
    my $sortby = $q->param('by');
    my $orderby =
       ('pt' eq $sortby)   ? 'point DESC' :
       ('pt_a' eq $sortby) ? 'point ASC'  :
                             'ad_id DESC' ;

    'pt' eq $sortby   ? $return_obj->{IfSortByPointDESC} = 1 : 
    'pt_a' eq $sortby ? $return_obj->{IfSortByPointASC}  = 1 :
                        $return_obj->{IfSortByAdID}      = 1 ;

    $return_obj->{MEMBERMAINURL} = $c->MEMBERMAINURL;

    my $dbh = $c->getDBConnection();
    $c->setDBCharset('sjis');
    my $carrier   = 2**$c->user_carriercode();
    my $MediaList = MyClass::JKZDB::Media->new($dbh);
    my $maxrec    = $MediaList->getCountSQL(
                        {
                            columns     => "ad_id",
                            whereSQL    => "mediacategory_id=? AND status_flag=? AND carrier & ?",
                            orderbySQL  => $orderby,
                            limitSQL    => "$offset, $condition_limit",
                            placeholder => [$mediacategory_id, 2, $carrier],
                        }
                    );

    my $tmpobj = $c->getFromObjectFile({ CONFIGURATION_VALUE => 'MEDIACATEGORYLIST_OBJ' , subject_id => $mediacategory_id });
    $return_obj->{mediacategory_name} = $tmpobj->{mediacategory_name};
    $return_obj->{mediacategory_id}   = $mediacategory_id;

    if ( 1 > $maxrec ) {
        $return_obj->{IfNotExistsMedia} = 1;
        return $return_obj;
    } else {
        $return_obj->{IfExistsMedia} = 1;
    }

    my @navilink;

    ## レコード数が1ページ上限数より多い場合
    if ($maxrec > $record_limit) {
        ## Modified 2010/03/01
        #my $url = sprintf("%sa=%s&o=%s&mc=%s", $c->MEMBERMAINURL, $a, $o, $mediacategory_id);
        my $url = sprintf("%sa=%s&o=%s&mc=%s&by=%s", $c->MEMBERMAINURL, $a, $o, $mediacategory_id, $sortby);

        ## 前へリンクの生成
        if (0 != $offset) { ## 最初のページじゃない場合（2ページ目以降の場合）
            $return_obj->{IfExistsPreviousPage} = 1;
            $return_obj->{PreviousPageUrl} = sprintf("%s&off=%s", $url, ($offset - $record_limit));
        }
        ## 次へリンクの生成
        if (($offset + $record_limit) < $maxrec) {
            $return_obj->{IfExistsNextPage} = 1;
            $return_obj->{NextPageUrl} = sprintf("%s&off=%s", $url, ($offset + $record_limit));
        }

        ## ページ番号生成
        for (my $i = 0; $i < $maxrec; $i += $record_limit) {

            my $pageno = int ($i / $record_limit) + 1;

            if ($i == $offset) { ###現在表示してるﾍﾟｰｼﾞ分
                push (@navilink, $pageno);
            } else {
                my $pagenate_url = sprintf("%s&off=%s", $url, $i);
                push (@navilink, $c->query->a({-href=>$pagenate_url}, $pageno));
            }
        }
        @navilink = map{ "$_\n" } @navilink;

        $return_obj->{pagenavi} = join(' ', @navilink);
    }

    $return_obj->{totalrecord} = $maxrec;


    my $aryref    = $MediaList->getSpecificValuesSQL(
        {
            columnslist => [
                     'ad_id',
                     'ad_name',
                     'point',
                     'ad_16words_text',
                     'ad_text',
            ],
            whereSQL    => "mediacategory_id=? AND status_flag=2 AND carrier & ?",
            orderbySQL  => $orderby,
            limitSQL    => "$offset, $condition_limit",
            placeholder => [$mediacategory_id, $carrier],
        }
    );

    $return_obj->{LoopPointBackMediaList} = ( $#{ $aryref->{ad_id} } >= $record_limit ) ? $#{ $aryref->{ad_id} } - 1 : $#{ $aryref->{ad_id} };

    if (0 <= $return_obj->{LoopPointBackMediaList}) {
        no strict 'refs';
        map {
            foreach my $key (%{ $aryref }) {
                $return_obj->{$key}->[$_] = $aryref->{$key}->[$_];
            }
            $return_obj->{ad_16words_text}->[$_] = MyClass::WebUtil::yenRyenN2br($return_obj->{ad_16words_text}->[$_]);
            #$return_obj->{ad_text}->[$_] =~ s{ %%(point)%% }{ exists($return_obj->{$1}->[$_]) ? $return_obj->{$1}->[$_] : "" }gex;
            $return_obj->{ad_text}->[$_] =~ s/%%(point)%%/$return_obj->{$1}->[$_]/gex;
            $return_obj->{ad_text}->[$_] = MyClass::WebUtil::yenRyenN2br($return_obj->{ad_text}->[$_]);
            $return_obj->{PPTBKURL}->[$_] = sprintf("/%s?guid=ON&ad_id=%s", $c->cfg->param('POINT_BACK_ADVERTISEMENT_SCRIPT_NAME'), $return_obj->{ad_id}->[$_]);
        } 0..$return_obj->{LoopPointBackMediaList};
    }

    $return_obj;
}


=pod
sub pointbackad :Hook('HOOK.POINTBACKAD') {
    my ($self, $c, $args) = @_;

    my $mediacategory_id = $c->query->param('mc');

    my $dbh = $c->getDBConnection();
    $c->setDBCharset('sjis');
    my $MediaList = MyClass::JKZDB::Media->new($dbh);
    my $aryref    = $MediaList->getSpecificValuesSQL(
        {
            columnslist => [
                     'ad_id',
                     'ad_name',
                     'point',
                     'ad_16words_text',
                     'ad_text',
            ],
            whereSQL    => "mediacategory_id=? AND status_flag=2",
            placeholder => [$mediacategory_id],
            orderbySQL  => "ad_id DESC"
        }
    );

    my $return_obj = {};
    $return_obj->{LoopPointBackMediaList} = $#{ $aryref->{ad_id} };

    if (0 <= $return_obj->{LoopPointBackMediaList}) {
        map {
            foreach my $key (%{ $aryref }) {
                $return_obj->{$key}->[$_] = $aryref->{$key}->[$_];
            }
            $return_obj->{ad_16words_text}->[$_] = MyClass::WebUtil::yenRyenN2br($return_obj->{ad_16words_text}->[$_]);
            $return_obj->{ad_text}->[$_] = MyClass::WebUtil::yenRyenN2br($return_obj->{ad_text}->[$_]);
            $return_obj->{PTBKURL}->[$_] = sprintf("/%s?guid=ON&ad_id=%s", $c->cfg->param('POINT_BACK_ADVERTISEMENT_SCRIPT_NAME'), $return_obj->{ad_id}->[$_]);
        } 0..$return_obj->{LoopPointBackMediaList};

        $return_obj->{'If.HOOK.POINTBACKAD'} = 1;
    }

    $return_obj;
}
=cut

sub class_component_plugin_attribute_detect_cache_enable { 0 }

1;