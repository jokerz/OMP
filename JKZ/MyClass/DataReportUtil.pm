#******************************************************
# @desc      画像を扱うモジュールImageMagick, GD
#            画像のサイズを変更したり、データを下にグラフを生成
#            Excelファイル生成など
# @package    JKZ::DataReportUtil
# @access    
# @author    Iwahase Ryo 
# @create    2009/08/03
# * @update 2009/12/22 不要・開発時のコード・コメント削除
# @version    1.0
#******************************************************
package MyClass::DataReportUtil;

use strict;
our $VERSION = '1.0';


#******************************************************
# @desc        ImageMagickで画像サイズを変更
# @param    fh $key $value {image_path, new_image_path, size} 
# @param    
# @return    $object
#******************************************************
sub convertImageSizeImageMagick {
    my $dataset = shift;

    require Image::Magick;
    my $img = Image::Magick->new;

    my ($err, $image_data);

    $err = $img->BlobToImage($dataset->{image_path});
    $err =$img->Scale( geometry=>$dataset->{size} );
    die "Unable to Scale image $! \n" if $err;
    $err = $img->Write(filename=>$dataset->{new_image_path});
    die "Unable to Write image $! \n" if $err;


}

#******************************************************
# @access    データを下にグラフを生成する
# @desc        
# @param    大量のパラメータがあるので下記参照
# @param    
#{
#    graphsize        => {
#        width    => グラフの横幅,
#        height    => グラフの縦幅,
#    },
#    font_size        => {
#        title_font        => title_font_size,
#        legend_font        => legend_font_size,
#        x_axis_font        => x_axis_font_size,
#        x_label_font    => x_label_font_size,
#        y_axis_font        => y_axis_font_size,
#        y_label_font    => y_label_font_size,
#    },
#    graphimage_path    => file_path_to_graph_filename,
#    graphimage_name    => graph_filename,
#    halfsize_image    => 1, # 半分のサイズのグラフ画像を生成すか？画像名は同じディレクトリで
#    graph_set        => {
#    ## ここはGDのsetメソッドの引数と同じもの
#    },
#}
# @return    boolean 1 / undef
#******************************************************
sub createGraph {
    my $dataset = shift;

    ## 縦棒グラフ
    #use GD::Graph::bars;
    ## 横棒グラフ 
    #use GD::Graph::hbars;
    ## 色々グラフ
    use GD::Graph::mixed;
    # システムテーブルのカラー名を使用可にする
    use GD::Graph::colour qw( :files );
    use GD::Text;

    ## グラフのサイズ（値が無い場合はデフォルトで640x480とする)
    my $width    = $dataset->{graphsize}->{width}  || 640;
    my $height    = $dataset->{graphsize}->{height} || 480;

    my $graph = GD::Graph::mixed->new( $width, $height );

#    GD::Graph::colour::read_rgb( "/home/webmaster/Counter/rgb.txt" ) or
#      die( "Can't read colours" );
 ## systemcolor directory depends on system
    GD::Graph::colour::read_rgb( "/usr/X11R6/lib/X11/rgb.txt" ) or
      die( "Can't read colours" );

    $graph->set(
            title            => $dataset->{graph_set}->{title},              ## グラフのタイトル
            t_margin         => $dataset->{graph_set}->{t_margin},           ## Top マージン
            b_margin         => $dataset->{graph_set}->{b_margin},           ## Bottom マージン
            l_margin         => $dataset->{graph_set}->{l_margin},           ## Left マージン
            r_margin         => $dataset->{graph_set}->{r_margin},           ## Right マージン
            x_label          => $dataset->{graph_set}->{x_label},            ## 横軸((Y軸)軸)の説明
            x_label_position => $dataset->{graph_set}->{x_label_position},   ## X軸ラベルの文字の位置。0～1の値。0:左寄せ　1:右寄せ　1/2:中央　デフォルト：3/4
            y_label          => $dataset->{graph_set}->{y_label},            ## 縦軸(Y軸)の説明
            y_label_position => $dataset->{graph_set}->{y_label_position},   ## Y軸ラベルの文字の位置。0～1の値。0:下詰め　1:上詰め　1/2:中央　デフォルト：1/
            y_max_value      => $dataset->{graph_set}->{y_max_value},        ## Y軸の最大値
            show_values      => $dataset->{graph_set}->{show_values},        ## 1にすると各データポイントの値を表示する デフォルト0。
            values_format    => $dataset->{graph_set}->{value_format},       ## データポイントの値の表示フォーマット(Perl sprintfの引数)
            types            => @{ $dataset->{graph_set}->{types} },
            dclrs            => @{ $dataset->{graph_set}->{dclrs} },         ## グラフの色を無名配列でリストする
            axislabelclr     => $dataset->{graph_set}->{axislabelclr},       ## 軸目盛の値の色を黒とします
            #legend_placement=> $dataset->{graph_set}->{legend_placement},   ## 凡例を置く場所 2つの文字  B+[L|C|R] (Bottom+[Left|Center|Right]  Rigth+[Top|Center|Bottom] )
            legend_placement => 'BR',    ## 凡例を置く場所 2つの文字  B+[L|C|R] (Bottom+[Left|Center|Right]  Rigth+[Top|Center|Bottom] )
            borderclrs       => $dataset->{graph_set}->{borderclrs},
            bgclr            => $dataset->{graph_set}->{bgclr},              ## グラフの背景色
            fgclr            => $dataset->{graph_set}->{fgclr},              ## グラフの前景色
            boxclr           => $dataset->{graph_set}->{boxclr},             ## グラフ内の背景色
            accentclr        => $dataset->{graph_set}->{accentclr},          ## グラフの外枠の色
            shadowclr        => $dataset->{graph_set}->{shadowclr},          ## グラフの影の色
            #y_max_value     => ,
            y_tick_number    => $dataset->{graph_set}->{y_tick_number},      ## 縦軸(Y軸)を刻む数
            y_label_skip     => $dataset->{graph_set}->{y_label_skip},       ## 数値の表示幅この場合だと y_tick_numberが10だから 20 40 60 80 …
            x_label_skip     => $dataset->{graph_set}->{x_label_skip},       ## 指定した数毎にX軸目盛の値を表示
            x_ticks          => $dataset->{graph_set}->{x_ticks},            ## 1:trueならば、X軸に目盛が描かれます  0:X軸に目盛を描かない
            x_tick_offset    => $dataset->{graph_set}->{x_tick_offset},      ## 最初の出力目盛をx_tick_offsetの値分飛ばす
            overwrite        => $dataset->{graph_set}->{overwrite},          ## 0:違うデータセットの棒は隙間無く表示（デフォルト） 1:互いの前に重なる 2:上に積み重ね（この場合cumulateを使用する)
            line_types       => $dataset->{graph_set}->{line_types},         ##線グラフの線の種類を無名配列でリストする（ 1:実線　2:ダッシ　3:点線　4:点線 )
            line_width       => $dataset->{graph_set}->{line_width},         ## 線グラフの太さ
            box_axis         => $dataset->{graph_set}->{box_axis},           ## 0:軸を箱状にしない。軸はY軸、X軸の基線のみが描かれる 1:軸を箱状にする。軸の外枠線を線で描くデフォルトは1
            zero_axis_only   => $dataset->{graph_set}->{zero_axis_only},     ## 0:デフォルト。1:Yの値が0の軸が描かれグラフの下の軸が描かれない
            long_ticks       => $dataset->{graph_set}->{long_ticks},         ## グラフ全体を横切る目盛線を引き
            markers          => @{ $dataset->{graph_set}->{markers} },       ## 点、点付折れ線グラフで使われる点の種類を無名配列でリストする（ 1:塗り四角　2:四角　3:十字　4:クロス十字　5:塗り菱形　6:菱形　7:塗り丸　8:丸 ）
            makers_size      => $dataset->{graph_set}->{makers_size},        ## 点、点付折れ線グラフで使われる点のサイズ（デフォルト 4）
            bar_width        => $dataset->{graph_set}->{bar_width},          ## 棒グラフの幅
            #shadow_depth        => $dataset->{graph_set}->{},               ## 影の深さ。正の値は右／下の影 負の値は左／上の影 デフォルトは0
            bar_spacing      => $dataset->{graph_set}->{bar_spacing},        ## 棒グラフ間の幅
            cumulate         => $dataset->{graph_set}->{cumulate},           ## データセットが積算される（棒グラフ、面グラフ）
        #   shadow_depth     => $dataset->{graph_set}->{},                   ## グラフの影の幅
            skip_undef       => $dataset->{graph_set}->{skip_undef},         ## 1:undef(未定義）データところは線を連続させない。 ０は連続させるdefualt
    );

    $graph->set_legend( @{ $dataset->{legend} } );

    ## TrueTypeフォントディレクトリをポイント
    #GD::Text->font_path( "/usr/share/fonts/japanese/TrueType");# コレは上と同じ
    #$graph->set_title_font( "IPAGothic", 14 );
    #$graph->set_title_font( "/usr/share/fonts/japanese/TrueType/IPAGothic", 14 );
    ## font名とfontサイズ
    $graph->set_title_font( "/usr/share/fonts/japanese/TrueType/ipam.otf", $dataset->{font_size}->{title_font} );        ## title表題のフォントのTrue Fontファイル名のパスとFontの大きさ
    $graph->set_legend_font( "/usr/share/fonts/japanese/TrueType/ipam.otf", $dataset->{font_size}->{legend_font} );        ## 凡例のフォントのTrue Fontファイル名のパスとFontの大きさ
    $graph->set_x_axis_font( "/usr/share/fonts/japanese/TrueType/ipam.otf ", $dataset->{font_size}->{x_axis_font} );    ## X軸の値のフォント（目盛）のTrue Fontファイル名のパスとFontの大きさ
    $graph->set_x_label_font( "/usr/share/fonts/japanese/TrueType/ipam.otf", $dataset->{font_size}->{x_label_font} );    ## X軸ラベルフォントのTrue Fontファイル名のパスとFontの大きさ
    $graph->set_y_axis_font( "/usr/share/fonts/japanese/TrueType/ipam.otf", $dataset->{font_size}->{y_axis_font} );        ## Y軸の値のフォント（目盛）のTrue Fontファイル名のパスとFontの大きさ
    $graph->set_y_label_font( "/usr/share/fonts/japanese/TrueType/ipam.otf", $dataset->{font_size}->{y_label_font} );    ## Y軸ラベルフォントのTrue Fontファイル名のパスとFontの大きさ

    my $image = $graph->plot( @{ $dataset->{data} });

    my $fullpath_to_image = sprintf("%s/%s", $dataset->{graphimage_path}, $dataset->{graphimage_name});
    my $fullpath_to_image2 = sprintf("%s/_%s", $dataset->{graphimage_path}, $dataset->{graphimage_name});

my $png = $image->png();

    open( OUT, "> $fullpath_to_image") or return undef;
    binmode OUT;
    print OUT $image->png();
    close OUT;

if ($dataset->{halfsize_image}) {
    convertImageSizeImageMagick({
            #image_path    => $fullpath_to_image,
            image_path     => $png,
            new_image_path => $fullpath_to_image2,
            size           => (($width / 3)*2),
    });
}

    return 1;
}


1;

__END__
