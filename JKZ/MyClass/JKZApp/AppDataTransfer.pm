#******************************************************
# @desc      コンテンツのデータ管理クラス flash deco template
# @package   MyClass::JKZApp::AppDataTransfer
# @access    public
# @author    Iwahase Ryo
# @create    2009/05/28
# @update    2009/07/02    画像データ変換と登録機能追加
# @update                 _convertImageForEmoji  _convertImageForPuchiDecoDecome _convertImageForDecoTmpltFlash
# @update    2009/07/02    AM convert_insert_SampleImage
# 依存ライブラリのインスコ 2010/1/16
# Data-TemporaryBag-0.09
# SWF-File-0.42
# SWF-Header-0.04
#
# @version   1.00
#******************************************************
package MyClass::JKZApp::AppDataTransfer;

use 5.008005;
our $VERSION = '1.00';

use strict;
use Carp qw(confess);


use base qw(MyClass::JKZApp);

use MyClass::WebUtil;

use MyClass::JKZApp::AppImage;
use MyClass::JKZDB::ProductSwf;
use MyClass::JKZDB::ProductDecoTmplt;
use MyClass::JKZDB::ProductImage;

use SWF::Header;


#******************************************************
# @access    public
# @desc        コンストラクタ
# @param    
# @return    
#******************************************************
sub new {
    my ($class, $cfg) = @_;

    return $class->SUPER::new($cfg);
}


#******************************************************
# @access    public
# @desc        親クラスのメソッド
# @param    
#******************************************************
sub dispatch {
    my $self = shift;

    $self->SUPER::dispatch();
}


sub uploadDecoTmpltFile {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    #********************************
    # 一連のエラー処理
    #********************************
    if (!$q->param('product_id')) {
        $obj->{ERRORMSG}      = '対象データがありません。';
        $obj->{IfHistoryBack} = 1;
        return $obj;
    }

    my $productm_id = $q->param('product_id');

    ## 新規のときはauto_incrementでDB依存。データ更新時は単一処理だけなのでoｋ
    my $id = defined($q->param('id')) && 0 < $q->param('id') ? $q->param('id') : "-1";

    ## ファイルハンドル
    my ($fhd, $fhs, $fha);
    ## マイムタイプ
    my ($mime_type_docomo, $mime_type_softbank, $mime_type_au);
    ## ファイルサイズ
    my ($file_size_docomo, $file_size_softbank, $file_size_au);
    ## 実データ
    my ($dmt, $hmt, $khm);

    ## データベースに格納する値保持レファレンス
    my $InsertData;

    $InsertData->{id}          = $id;
    $InsertData->{productm_id} = $productm_id;

    #**********************************
    ## DoCoMo
    #**********************************
    if ( $fhd = $q->upload('dmt') ) {

        ## DoCoMoのMime-type取得 uploadInfoだとtextになるため指定
        #$mime_type_docomo    = $q->uploadInfo($fhd)->{'Content-Type'};
        $mime_type_docomo    = 'application/x-decomail-template';

        ## DoCoMoのファイルサイズ取得
        $file_size_docomo = (stat($fhd))[7];

        ## SoftBankのファイルサイズ取得
        $file_size_softbank = (stat($fhs))[7];

        (read($fhd, $dmt, -s $fhd) == -s $fhd)
            or confess ("Can't read data file: $!");

        #********************
        # データセット
        #********************
        $InsertData->{dmt}              = $dmt;
        $InsertData->{mime_type_docomo} = $mime_type_docomo;
        $InsertData->{file_size_docomo} = $file_size_docomo;

        $obj->{mime_type_docomo}        = $mime_type_docomo;
        $obj->{file_size_docomo}        = $file_size_docomo;

    }

    #**********************************
    ## SoftBank
    #**********************************
    if ( $fhs = $q->upload('hmt') ) {

        ## SoftBankのMime-type取得
        #$mime_type_softbank    = $q->uploadInfo($fhs)->{'Content-Type'};
        $mime_type_softbank    = 'application/x-htmlmail-template';
        ## SoftBankのファイルサイズ取得
        $file_size_softbank = (stat($fhs))[7];

        (read($fhs, $hmt, -s $fhs) == -s $fhs)
            or confess ("Can't read data file: $!");

        #********************
        # データセット
        #********************
        $InsertData->{hmt}                    = $hmt;
        $InsertData->{mime_type_softbank}    = $mime_type_softbank;
        $InsertData->{file_size_softbank}    = $file_size_softbank;

        $obj->{mime_type_softbank}            = $mime_type_softbank;
        $obj->{file_size_softbank}            = $file_size_softbank;

    }

    #**********************************
    ## AU
    #**********************************
    if ( $fha = $q->upload('khm') ) {

        ## AUのMime-type取得
        #$mime_type_au        = $q->uploadInfo($fha)->{'Content-Type'};
        $mime_type_au = 'application/x-kddi-htmlmail';
        ## AUのファイルサイズ取得
        $file_size_au = (stat($fha))[7];

        (read($fha, $khm, -s $fha) == -s $fha)
            or confess ("Can't read data file: $!");

        #********************
        # データセット
        #********************
        $InsertData->{khm}          = $khm;
        $InsertData->{mime_type_au} = $mime_type_au;
        $InsertData->{file_size_au} = $file_size_au;

        $obj->{mime_type_au}        = $mime_type_au;
        $obj->{file_size_au}        = $file_size_au;
    }


    if (!$self->_storeDeCoTmpltData($InsertData)) {
        $obj->{ERROR_MSG} = "DecoTmpltFile Data Insert Failed Operation is aborted";
        ## DBインサート失敗
        $obj->{IfFailUploadDecoTmplt} = 1;

            return $obj;

    } else {
          $obj->{IfSuccessUploadDecoTmplt} = 1;
          $obj->{product_id} = $productm_id;

    ## Modified 2009/07/02 BEGIN
        if (!$self->convert_insert_SampleImage()) {
            $obj->{ERROR_MSG} = "Image Data Insert Failed Operation is aborted";
            ## DBインサート失敗
            $obj->{IfInsertSampleImageDBFail} = 1;
            return $obj;
        }

        $obj->{IfInsertSampleImageDBSuccess} = 1;
    ## Modified 2009/07/02 END
          return $obj;
    }

}


#******************************************************
# @access    private
# @desc        デコメテンプレートデータを格納
# @param
# @param
# @param
# @return    boolean
#******************************************************
sub _storeDeCoTmpltData {
    my ($self, $data) = @_;

    my $dbh = $self->getDBConnection();
    $dbh->do('set names utf8');
    my $DecoTmpltData = MyClass::JKZDB::ProductDecoTmplt->new($dbh);
    if (!$DecoTmpltData->executeUpdate($data)) {
        return -1;
    }

    return 1;
}


#******************************************************
# @access    public
# @desc        フラッシュファイルを格納
# @desc        画像更新はひとつづつ
#******************************************************
sub uploadSwfFile {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    #********************************
    # 一連のエラー処理
    #********************************
    if (!$q->param('product_id')) {
        $obj->{ERRORMSG}      = '対象データがありません。';
        $obj->{IfHistoryBack} = 1;
        return $obj;
    }
    if (!$q->param('swffile')) {
        $obj->{ERRORMSG}      = 'フラッシュファイルがありません。選択してください。';
        $obj->{IfHistoryBack} = 1;
        return $obj;
    }

    my $productm_id = $q->param('product_id');

    ## 新規のときはauto_incrementでDB依存。データ更新時は単一処理だけなのでoｋ
    my $id = defined($q->param('id')) && 0 < $q->param('id') ? $q->param('id') : "-1";
    my $fh = $q->upload('swffile');

    ## Mime-type取得
    my $mime_type = $q->uploadInfo($fh)->{'Content-Type'};

    ## ファイルサイズ取得
    my $file_size = (stat($fh))[7];

    my ($swfdata, $height, $width);

    (read($fh, $swfdata, -s $fh) == -s $fh)
        or confess ("Can't read data file: $!");

    #********************************
    # flashファイルから縦・横幅を取得
    #********************************
    my $header_data = SWF::Header->read_data($swfdata);
    $height = $header_data->{height};
    $width  = $header_data->{width};

    my $InsertData = {
        id          => $id,
        productm_id => $productm_id,
        swf         => $swfdata,
        mime_type   => $mime_type,
        file_size   => $file_size,
        height      => $height,
        width       => $width,
    };

    if (!$self->_storeSwfData($InsertData)) {
        $obj->{ERROR_MSG} = "FlashFile Data Insert Failed Operation is aborted";
        ## DBインサート失敗
        $obj->{IfFailUploadSwf} = 1;
            return $obj;
    } else {
          $obj->{IfSuccessUploadSwf} = 1;
          $obj->{filename}   = $fh;
          $obj->{product_id} = $productm_id;
          $obj->{mime_type}  = $mime_type;
          $obj->{file_size}  = $file_size;
          $obj->{height}     = $height;
          $obj->{width}      = $width;

    ## Modified 2009/07/02 BEGIN
        if (!$self->convert_insert_SampleImage()) {
            $obj->{ERROR_MSG} = "Image Data Insert Failed Operation is aborted";
            ## DBインサート失敗
            $obj->{IfInsertSampleImageDBFail} = 1;
            return $obj;
        }

        $obj->{IfInsertSampleImageDBSuccess} = 1;
    ## Modified 2009/07/02 END

          return $obj;
    }
}


#******************************************************
# @access    private
# @desc        フラッシュファイルを格納
# @param
# @param
# @param
# @return    boolean
#******************************************************
sub _storeSwfData {
    my ($self, $data) = @_;

    my $dbh = $self->getDBConnection();
    $dbh->do('set names utf8');
    my $SwfData = MyClass::JKZDB::ProductSwf->new($dbh);
    if (!$SwfData->executeUpdate($data)) {
        return -1;
    }

    return 1;
}


#******************************************************
# @access    
# @desc        新規登録時のサンプル画像の処理とDBインサート
# @param    fh
# @param    
# @return    boolean
#******************************************************
sub convert_insert_SampleImage {
    my $self        = shift;
    my $q           = $self->query();
    my $productm_id = $q->param('product_id');
    my $fh          = $q->upload('image');
    #**********************************
    # パラメータがcategorym_idの場合は新規 2 4 8 16 32 自然対数を出す
    # パラメータがcategory_idの場合は既存画像を変更 1 2 3 4 5
    # 1 2,3 4,5 枠組みで処理メソッドを変える
    #**********************************
    my $subcategory_id =
    ( defined($q->param('subcategorym_id')) ) ?  $q->param('subcategorym_id') :
    ( defined($q->param('subcategory_id')) )  ?  $q->param('subcategory_id')  :
                                              undef                     ;

    my $convertmethod = [
        undef,
        \&MyClass::JKZApp::AppImage::_convertImageForEmoji,
        \&MyClass::JKZApp::AppImage::_convertImageForPuchiDecoDecome,
        \&MyClass::JKZApp::AppImage::_convertImageForPuchiDecoDecome,
        \&MyClass::JKZApp::AppImage::_convertImageForDecoTmpltFlash,
        \&MyClass::JKZApp::AppImage::_convertImageForDecoTmpltFlash,
        \&MyClass::JKZApp::AppImage::_convertImageForDecoMachi,
        \&MyClass::JKZApp::AppImage::_convertImageFor,
        
    ];
    my ($image, $image1, $image2) = $convertmethod->[$subcategory_id]->($fh);


    my $mime_type = $q->uploadInfo($fh)->{'Content-Type'};

    $mime_type =~ s!(^image/)x-(png)$!$1$2!;
    $mime_type =~ s!(^image/).+?(jpeg)$!$1$2!;

    my $InsertImage = {
        productm_id => $productm_id,
        image       => $image,
        image1      => $image1,
        image2      => $image2,
        mime_type   => $mime_type,
    };

    my $obj = {};

    my $dbh = $self->getDBConnection();
    $dbh->do('set names utf8');
    my $Image = MyClass::JKZDB::ProductImageM->new($dbh);
    if (!$Image->executeUpdate($InsertImage)) {
        return -1;
    }

    return 1;
}


1;
__END__