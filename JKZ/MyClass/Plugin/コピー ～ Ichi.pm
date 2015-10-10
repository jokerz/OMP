#******************************************************
# @desc        位置情報プラグイン
# @package    MyClass::Plugin::Ichi
# @author    Iwahase Ryo
# @create    2010/06/14
# @version    1.00
#******************************************************

package MyClass::Plugin::Ichi;

use strict;
use warnings;
no warnings 'redefine';
use base 'MyClass::Plugin';

use MyClass::WebUtil;
use MyClass::JKZSession;
use MyClass::JKZDB::IchiLog;
use MyClass::JKZDB::MyIchi;

## 全ての携帯キャリア
use JKZ::Ichi::iArea;
use Data::Dumper;


#******************************************************
# @desc     位置登録履歴
# @param    mc 
# @return   hashobj  
#******************************************************
sub viewlist_ichi_history :Method {
    my ($self, $c, $args) = @_;

    my $return_obj;
    my $owid = $c->owid();
    my ($s_owid, $s_ciphered) = split(/::/, $c->query->param('s'));

   ## 暗号コードと会員ID不一致もしくはエラー
    unless ($owid == $s_owid && MyClass::WebUtil::decipher($s_owid, $s_ciphered)) {
        $return_obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $c->ERROR_MSG("ERR_MSG99"));
        return $return_obj;
    }

    my $dbh = $c->getDBConnection();
    my $myIchiLog = MyClass::JKZDB::IchiLog->new($dbh);
    my $aryref    = $myIchiLog->getSpecificValuesSQL( {
                        columnslist => [
                            'ichi_id',
                            'owid',
                            'distance',
                            'iArea_name',
                            'iArea_prefecture',
                            'registration_date',
                        ],
                        whereSQL    => "owid=?",
                        orderbySQL  => "ichi_id ASC",
#                       limitSQL    => "$offset, $condition_limit",
                        placeholder => [$owid],
                    } );
    $return_obj->{LoopIchiHistoryList} = $#{ $aryref->{ichi_id} };

    map {
        foreach my $key (%{ $aryref }) {
            $return_obj->{$key}->[$_] = $aryref->{$key}->[$_];
        }
        
        $return_obj->{distance}->[$_]         = 0 if 1 == $return_obj->{ichi_id}->[$_];
        $return_obj->{distance}->[$_]         = sprintf("%d", $return_obj->{distance}->[$_]);
        $return_obj->{total_distance}         += $return_obj->{distance}->[$_];
        $return_obj->{iArea_name}->[$_]       = MyClass::WebUtil::convertByNKF('-s', $return_obj->{iArea_name}->[$_]);
        $return_obj->{iArea_prefecture}->[$_] = MyClass::WebUtil::convertByNKF('-s', $return_obj->{iArea_prefecture}->[$_]);

        ( $return_obj->{MMDD}->[$_], $return_obj->{hhmmss}->[$_] ) = split(/ /, $return_obj->{registration_date}->[$_]);
        $return_obj->{MMDD}->[$_]             = substr($return_obj->{MMDD}->[$_], 6, 10);
        $return_obj->{MMDD}->[$_]             =~ s!-!/!;
        $return_obj->{hhmmss}->[$_]           = substr($return_obj->{hhmmss}->[$_], 0, 5);

    } 0..$return_obj->{LoopIchiHistoryList};

    $return_obj->{total_distance} = sprintf("%d", $return_obj->{total_distance});

    return $return_obj;
}


#******************************************************
# @desc     位置情報での近所リスト
# @param    mc 
# @return   hashobj  
#******************************************************
sub viewlist_neighbor :Method {
    my ($self, $c, $args) = @_;
    my $iArea_areaid = $c->query->param('iAid');
    #my $iArea_code        = $c->query->param('iAcode');
    #my ($iArea_areaid, $iArea_sub_areaid) = $iArea_code =~ /^(\d{3})(\d{2})$/;
    my $return_obj;

    if (!$iArea_areaid) {
        $return_obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $c->ERROR_MSG("ERR_MSG99"));
        return $return_obj;
    }

    my $namespace = $c->waf_name_space() . 'neighborlist';
    my $memcached = $c->initMemcachedFast();
    $return_obj   = $memcached->get("$namespace:$iArea_areaid");

    if (!$return_obj) {
        my $owid   = $c->owid();
        my $sql    = sprintf("SELECT i.owid, pr.nickname, pr.profile_bit, pr.selfintroduction FROM %s.tMyIchi i LEFT JOIN %s.tProfilePageSettingM pr ON i.owid=pr.owid WHERE i.iArea_areaid=?", $c->waf_name_space(), $c->waf_name_space());
        my $dbh    = $c->getDBConnection();
        my $aryref = $dbh->selectall_arrayref($sql, { Columns => {} }, $iArea_areaid);

        $return_obj->{LoopNeighborList} = $#{ $aryref };
        if (0 <= $return_obj->{LoopNeighborList}) {
            $return_obj->{IfExistsNeighbor} = 1;
            $return_obj->{total_neighbor} = $return_obj->{LoopNeighborList};
            #for (my $i == 0; $i <= $return_obj->{LoopNeighborList}; $i++) {
            map {
                    $return_obj->{toid}->[$_]                      = $aryref->[$_]->{owid};
                    $return_obj->{neighbor_nickname}->[$_]         = $aryref->[$_]->{nickname};
                    $return_obj->{neighbor_profile_bit}->[$_]      = $aryref->[$_]->{profile_bit};
                    $return_obj->{neighbor_selfintroduction}->[$_] = MyClass::WebUtil::yenRyenN2br($aryref->[$_]->{selfintroduction});
                    # ここで設定をしてキャッシュに格納するとキャッシュが有効の間全員同じになるためNG
                    #$return_obj->{LNEIGHBORURL}->[$_]              = $c->NEIGHBORURL();
                    ( 0 != $_ % 2 ) ? $return_obj->{IfEven}->[$_]  = 1 : $return_obj->{IfOdd}->[$_] = 1 ;
            } 0 .. $return_obj->{LoopNeighborList};
            #}

            $return_obj->{iArea_name} = $c->attrAccessUserData('iArea_name');
        }
        else {
            $return_obj->{IfNotExistsNeighbor} = 1;
        }
        $memcached->add("$namespace:$iArea_areaid", $return_obj, 600);
    }

    my $LNEIGHBORURL = sprintf("%s,", $c->NEIGHBORURL()) x ( $return_obj->{LoopNeighborList} + 1 );
    @{ $return_obj->{LNEIGHBORURL} } = split(/,/, $LNEIGHBORURL);

    return $return_obj;
}


#******************************************************
# @desc     位置情報登録
# @param    mc 
# @return   hashobj  
#                  areagroup         大地域
#                  area              地域
#                  distance          移動距離
#                  ドコモ [ddd.mm.ss.ss]  ソフトバンク[ddd,mm,ss,ss] AU
#                   上記フォーマットをddd,mm,ss,ssに変換してから距離計算を実行
#                  startpoint_ido    開始緯度
#                  startpoint_keido  開始経度
#                  endpoint_ido      終了緯度
#                  endpoint_keido    終了経度
#
#               AUのから返されるパラメータ
#                ● device:gpsone?url=http://omp.1mp.jp/loc_EZ.mpl&ver=1&datum=0&unit=0&acry=0&number=0
#                  &fm=0
#                  &alt=80
#                  &time=20100706180017
#                  &lat=+35.41.25.30
#                  &ver=1
#                  &unit=0
#                  &majaa=20
#                  &smin=22
#                  &vert=20
#                  &datum=0
#                  &lon=+139.42.26.67
#                  &smaj=54
#
#                ● device:location?url=http://omp.1mp.jp/loc_EZ.mpl
#                   &unit=dms
#                   &lat=35.41.34.75
#                   &lon=139.42.18.75
#                   &datum=tokyo
#
#
#
# @reutrn          { iArea_region iArea_name iArea_areacode iArea_areaid iArea_sub_areaid  iArea_prefecture }
#
#
#******************************************************
sub regist_area :Method {
    my ($self, $c, $args) = @_;

    my $q        = $c->query();
    my $areacode = $q->param('AREACODE');

    my ( $arg1, $arg2 );
    my ( $lat, $lon, $geo, $xacc, $area, $region );

    my $iArea;

    if ( 1 == $c->attrAccessUserData("carriercode") ) {
  #***************************
  # ドコモ処理
  #***************************
        $lat  = $q->param('LAT');
        $lon  = $q->param('LON');
        $geo  = $q->param('GEO');
        $xacc = $q->param('XACC');
        $arg1 = $q->param('arg1');
        $arg2 = $q->param('arg2');

        $iArea = JKZ::Ichi::iArea->figureout_from_areacode($areacode);

    }
    elsif ( 2 == $c->attrAccessUserData("carriercode") ) {
  #***************************
  # ソフトバンク処理
  #***************************
        my @pos = split(/E/, $q->param('pos'));

        $pos[0] =~ s/^N(.*?)/$1/;
        $lat    = $pos[0];
        $lon    = $pos[1];
        $geo    = $q->param('geo');
        $xacc   = $q->param('x-acr');

        my ($t_lat, $t_lon) = ($lat, $lon);
      ## ドコモエリアコードを出すためにフォーマットを変更
        $t_lat =~ s!^(\d+)\.(\d+)\.(\d+)\.(\d+)!$1$2$3\.$4!;
        $t_lon =~ s!^(\d+)\.(\d+)\.(\d+)\.(\d+)!$1$2$3\.$4!;

      ## ドコモエリアコード取得
        $iArea = JKZ::Ichi::iArea->figureout_from_GeoIP($t_lat, $t_lon, $geo, "dmsn");

    }
    elsif ( 3 == $c->attrAccessUserData("carriercode") ) {
  #***************************
  # AU処理
  #***************************
        $lat  = $q->param('lat');
        $lon  = $q->param('lon');
        $geo  = $q->param('datum');
        $xacc = $q->param('XACC');
        $arg1 = $q->param('arg1');
        $arg2 = $q->param('arg2');

    }

    #my $geo      = $q->param('GEO');  # 測地
    #my $xacc     = $q->param('XACC'); # 測位レベル

  #***************************
  # 移動距離計算用にフォーマットを整える ddd,mm,ss.ss
  #***************************
    my $regex = qr/(\d+)\.(\d+)\.(\d+)\.(\d+)/;
    $lat      =~ s/$regex/$1,$2,$3\.$4/;
    $lon      =~ s/$regex/$1,$2,$3\.$4/;

    my $return_obj = {};
    my $sysid      = $c->user_guid();
    my $owid       = $c->owid();
    my $dbh        = $c->getDBConnection();
    my $IchiLog    = MyClass::JKZDB::IchiLog->new($dbh);

   ## 前回の位置登録データがある場合は入れ替える 以前に登録したものがスタートポイントとなる
    my $previous = $IchiLog->fetch_lastIchiLog($owid);
    if ($previous) {
        $return_obj->{startpoint_ido}   = $previous->{endpoint_ido};
        $return_obj->{startpoint_keido} = $previous->{endpoint_keido};
    }

#undef $IchiLog;

    $return_obj->{endpoint_ido}     = &format($lat);
    $return_obj->{endpoint_keido}   = &format($lon);
    my $distance                    = sprintf("%.4f", &distance($return_obj->{startpoint_ido}, $return_obj->{startpoint_keido}, $return_obj->{endpoint_ido}, $return_obj->{endpoint_keido}));
    $return_obj->{distance}         = $distance;

   ## 今回の位置情報のインサート

  #***************************
  # 位置情報
  #***************************
    $return_obj->{iArea_region}     = MyClass::WebUtil::convertByNKF('-s', $iArea->region());
    $return_obj->{iArea_name}       = MyClass::WebUtil::convertByNKF('-s', $iArea->name());
    $return_obj->{iArea_prefecture} = MyClass::WebUtil::convertByNKF('-s', $iArea->prefecture()); ## 都道府県
    $return_obj->{iArea_areacode}   = $iArea->areacode(); ## 5桁のドコモエリアコード
    $return_obj->{iArea_areaid}     = $iArea->areaid(); ## 3桁のID
    $return_obj->{iArea_sub_areaid} = $iArea->sub_areaid(); ## 2桁のサブID
    $return_obj->{ichi_id}          = -1;
    $return_obj->{owid}             = $owid;

    $IchiLog->executeUpdate( { 
        ichi_id          => $return_obj->{ichi_id},
        owid             => $return_obj->{owid},
        distance         => $distance,
        iArea_region     => $return_obj->{iArea_region},
        iArea_name       => $return_obj->{iArea_name},
        iArea_prefecture => $return_obj->{iArea_prefecture},
        iArea_code       => $return_obj->{iArea_areacode},
        iArea_areaid     => $return_obj->{iArea_areaid},
        iArea_sub_areaid => $return_obj->{iArea_sub_areaid},
        startpoint_ido   => $return_obj->{startpoint_ido},
        startpoint_keido => $return_obj->{startpoint_keido},
        endpoint_ido     => $return_obj->{endpoint_ido},
        endpoint_keido   => $return_obj->{endpoint_keido},
     } );


    my $myIchi = MyClass::JKZDB::MyIchi->new($dbh);
    $myIchi->executeUpdate( {
        owid             => $owid,
        ichi_id          => $IchiLog->mysqlInsertIDSQL(),
        distance         => $distance,
        iArea_region     => $return_obj->{iArea_region},
        iArea_name       => $return_obj->{iArea_name},
        iArea_prefecture => $return_obj->{iArea_prefecture},
        iArea_code       => $return_obj->{iArea_areacode},
        iArea_areaid     => $return_obj->{iArea_areaid},
        iArea_sub_areaid => $return_obj->{iArea_sub_areaid},
        startpoint_ido   => $return_obj->{startpoint_ido},
        startpoint_keido => $return_obj->{startpoint_keido},
        endpoint_ido     => $return_obj->{endpoint_ido},
        endpoint_keido   => $return_obj->{endpoint_keido},
      } );

    ## キャッシュ情報をクリア
    my $namespace = $c->waf_name_space() . 'memberdata';
    $c->initMemcachedFast()->delete("$namespace:$sysid");
    my $sess_ref = MyClass::JKZSession->open($sysid);
    $sess_ref->clear_session() if defined $sess_ref;

    $return_obj;
}


#******************************************************
# @desc     2地点の緯度経度から移動距離を計算
# @param    緯度、経度は ddd,mm,ss.sのフォーマット
# @return   距離
#******************************************************
sub distance {
    my ($startido, $startkeido, $endido, $endkeido) = @_;

    my $pi       = atan2(1, 1) * 4;

    $startido    = $pi * $startido / 180;
    $startkeido  = $pi * $startkeido / 180;
    $endido      = $pi * $endido / 180;
    $endkeido    = $pi * $endkeido / 180;

    my $tmp1     = 6378.137 / (sqrt(1 - 0.006694470 * sin($startido) ** 2));
    my $a        = $tmp1 * cos($startido) * cos($startkeido);
    my $b        = $tmp1 * cos($startido) * sin($startkeido);
    my $c        = $tmp1 * (1 - 0.006694470) * sin($startido);
    my $tmp2     = 6378.137 / (sqrt(1 - 0.006694470 * sin($endido) ** 2));
    my $d        = $tmp2 * cos($endido) * cos($endkeido);
    my $e        = $tmp2 * cos($endido) * sin($endkeido);
    my $f        = $tmp2 * (1 - 0.006694470) * sin($endido);

    my $distance = 6378.137 * 2 * &asin(sqrt(($a - $d) ** 2 + ($b - $e) ** 2 + ($c - $f) ** 2) / (6378.137 * 2));

    return $distance;
}


sub asin {
    return (atan2($_[0], sqrt(1 - $_[0] ** 2)));
}


sub format {
    my $do = shift;

    if ($do =~ /(\d+\.?\d*),(\d+\.?\d*),(\d+\.?\d*)/) {
        $do = $1 + ($2 / 60) + ($3 / 3600);
    }
    elsif ($do =~ /(\d+\.?\d*),(\d+\.?\d*)/) {
        $do  = $1 + ($2 / 60);
    }
    return $do;
}


sub class_component_plugin_attribute_detect_cache_enable { 0 }

1;