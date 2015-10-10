#******************************************************
# @desc      �摜�Ǘ��N���X
# @package   MyClass::JKZApp::AppImage
# @access    public
# @author    Iwahase Ryo
# @create    2009/02/26
# @update    2009/05/26    AM uploadSwfFile
#                          AM _storeSwfData
# @update     2009/06/26    AM _convertImageForEmoji            ��
# @update     2009/06/26    AM _convertImageForPuchiDecoDecome    �������̃��\�b�h�͖߂�l�͕K���R�i�s������undef��Ԃ��j
# @update     2009/06/26    AM _convertImageForDecoTmpltFlash    ��
# @update     2009/06/30    MyClass::JKZDB::ProductImage�̔p�~
# @update     2010/01/16    _convertImageFor�ǉ�
# @update     2010/05/28    AM uploadImageMofDecoMachi
# @update     2010/05/28    AM _convertImageForDecoMachi
# @update     2009/06/26    
# @update     2009/06/26    
# @version    1.00
#******************************************************
package MyClass::JKZApp::AppImage;

use 5.008005;
our $VERSION = '1.00';

use strict;
use base qw(MyClass::JKZApp);

use MyClass::WebUtil;
use MyClass::JKZDB::ProductImage;
use MyClass::JKZDB::SiteImage;

use Image::Magick;

#******************************************************
# @access    public
# @desc        �R���X�g���N�^
# @param    
# @return    
#******************************************************
sub new {
    my ($class, $cfg) = @_;

    return $class->SUPER::new($cfg);
}


#******************************************************
# @access    public
# @desc        �e�N���X�̃��\�b�h
# @param    
#******************************************************
sub dispatch {
    my $self = shift;

    !defined($self->query->param('action')) ? $self->action('imageTopMenu') : $self->action();

    $self->SUPER::dispatch();
}


#******************************************************
# @access    
# @desc      
# @param     
# @param     
# @return    
#******************************************************
sub imageTopMenu {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = $self->_getSiteImageList();

    $obj->{LoopImageList} = $obj->{countRec};
    if ( 0 <= $obj->{LoopImageList}) {
        foreach my $i (0..$obj->{countRec}) {
            ## �܂����[�v������Ƃ�
            unless ($i == $obj->{LoopImageList}) {
                ## 3�̏ꍇ
                $obj->{TR}->[$i] = (0 == ($i+1) % 3 ) ? '</tr><tr><!-- auto generated end tag and begin tag -->' : "";
            } else { ## �ŏI���[�v�ŏI���̂Ƃ�
                ## 3�̏ꍇ
                $obj->{TR}->[$i] =
                    (0 == ($i+1) % 3 ) ? '</tr><!-- auto generated tr end tag -->'                         :
                    (2 == ($i+1) % 3 ) ? '<td></td></tr><!-- auto generated one pair of td tag tr end tag -->'         :
                                         '<td></td><td></td></tr><!-- auto generated two pair of td tag tr end tag -->';
            }
        }
        $obj->{IfExistsImages} = 1;
    }
    else {
        $obj->{IfNotExistsImages} = 1;
    }

    return $obj;
}


#******************************************************
# @access    
# @desc        �摜���X�g
# @param    
# @param    
# @return    
#******************************************************
sub siteImageList {
    my $self = shift;
    my $obj  = $self->_getSiteImageList();

    $obj->{LoopImageList} = $obj->{countRec};

    map { $obj->{cssstyle}->[$_] = 0 == $_ % 2 ? 'focusodd' : 'focuseven' } 0..$obj->{countRec};

    return $obj;
}


#******************************************************
# @access    private
# @desc        �摜�̃��X�g�f�[�^�擾
# @param    
# @param    
# @return    obj
#******************************************************
sub _getSiteImageList {
    my $self = shift;

    #*************************
    # �摜���̎擾
    #*************************
    my $obj = {};
    my $dbh = $self->getDBConnection();
    ## ���������h�~
    $dbh->do('set names sjis');
    my $ImageList = MyClass::JKZDB::SiteImage->new($dbh);
    $ImageList->executeSelectList ();
    $obj->{countRec} = $ImageList->countRecSQL();
    if ( 0 <= $obj->{countRec}) {
        foreach my $i (0..$obj->{countRec}) {
            map { $obj->{$_}->[$i] = $ImageList->{columnslist}->{$_}->[$i] } keys %{$ImageList->{columnslist}};
        }
    }

    return $obj;
}



#******************************************************
# @access   public
# @desc     �摜���i�[�V�K �͕���OK
# @desc     �摜�X�V�͂ЂƂÂ�
# @         ���_����B�摜�i�[����������̃y�[�W�\�����܂� 2009/02/27
#         ���C���ς�2009/08/28
#******************************************************
sub uploadSiteImage {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    if (!$q->param('image')) {
        $obj->{ERRORMSG} = '�摜������܂���B�I�����Ă��������B';
        $obj->{IfHistoryBack} = 1;

        return $obj;
    }


    my @imagef      = $q->upload('image');
    my @description = $q->param('description');

    ## �V�K�̂Ƃ���auto_increment��DB�ˑ��B�f�[�^�X�V���͒P�ꏈ�������Ȃ̂�o��
    my $id          = defined($q->param('id')) && 0 < $q->param('id') ? $q->param('id') : "-1";
    my $cnt = 0;
    foreach my $fh (@imagef) {

        my $mime_type = $q->uploadInfo($fh)->{'Content-Type'};

        require Image::Magick;
        my $imgObj = Image::Magick->new();
        my $imagedata;
        (read($fh, $imagedata, -s $fh) == -s $fh);

        my $err = $imgObj->BlobToImage($imagedata);
        die "Can't convert image data: $err" if $err;

        my ($width, $height) = $imgObj->Get('width', 'height');

        ## image/x-png �� image/pjpeg ����SB��AU�ŕ\���ł��Ȃ��̂ŏC��
        $mime_type =~ s!(^image/)x-(png)$!$1$2!;
        $mime_type =~ s!(^image/).+?(jpeg)$!$1$2!;

        use NKF;
        my $InsertImage = {
            id          => $id,
            image       => $imagedata,
            width       => $width,
            height      => $height,
            mime_type   => $mime_type,
            description => nkf('-w', $description[$cnt]),
        };

    ## Modified Replace�Ńf�[�^���i�[���Ă��邩��A�㏑���̏ꍇ��insert_id���擾�ł��Ȃ�����R�����g�A�E�g 2010/03/05 BEGIN
=pod
        my $insert_id;

        if (!($insert_id = $self->_storeSiteImage($InsertImage))) {
            $obj->{ERROR_MSG} = "Image Data Insert Failed Operation is aborted";
            ## DB�C���T�[�g���s
            $obj->{IfInsertDBFail} = 1;

            return $obj;
        } else {
            $obj->{insert_id}    = $insert_id;
            $obj->{IfInsertDBSuccess} = 1;
        }
=cut
        if (!$self->_storeSiteImage($InsertImage)) {
            $obj->{ERROR_MSG} = "Image Data Insert Failed Operation is aborted";
            ## DB�C���T�[�g���s
            $obj->{IfInsertDBFail} = 1;
            return $obj;
        } else {
            $obj->{IfInsertDBSuccess} = 1;
        }
    ## Modified Replace�Ńf�[�^���i�[���Ă��邩��A�㏑���̏ꍇ��insert_id���擾�ł��Ȃ�����R�����g�A�E�g 2010/03/05 END
        $cnt++;
    }

    $self->action('imageTopMenu');
    $self->imageTopMenu();
}


#******************************************************
# @access    public
# @desc        �摜���i�[�V�K �͕���OK �V�����o�[�W����
# @desc        �摜�X�V�͂ЂƂÂ�
#******************************************************
sub uploadImageM {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    if (!$q->param('product_id')) {
        $obj->{ERRORMSG}      = '�Ώۃf�[�^������܂���B';
        $obj->{IfHistoryBack} = 1;

        return $obj;
    }
    if (!$q->param('image')) {
        $obj->{ERRORMSG}      = '�摜������܂���B�I�����Ă��������B';
        $obj->{IfHistoryBack} = 1;

        return $obj;
    }
    ## �����A�b�v�����Ή�
    my @imagef      = $q->upload('image');
    my $productm_id = $q->param('product_id');
    my $id          = $q->param('id') || undef;
    #**********************************
    # �p�����[�^��subcategorym_id�̏ꍇ�͐V�K 1 2 3 4 5  ���R�ΐ����o��
    # �p�����[�^��subcategory_id�̏ꍇ�͊����摜��ύX 1 2 3 4 5
    # 1 2,3 4,5 �g�g�݂ŏ������\�b�h��ς���
    #**********************************
=pod
    my $subcategory_id = ( defined($q->param('subcategorym_id')) && 5 > $q->param('subcategorym_id') ) ? $q->param('subcategorym_id') :
                         ( defined($q->param('subcategory_id')) &&  5 > $q->param('subcategory_id') )  ? $q->param('subcategory_id')  :
                                                               undef
                        ;
    my $convertmethod = [
        undef,
        \&_convertImageForEmoji,
        \&_convertImageForPuchiDecoDecome,
        \&_convertImageForPuchiDecoDecome,
        \&_convertImageForDecoTmpltFlash,
        \&_convertImageForDecoTmpltFlash,
        \&_convertImageFor,
    ];
=cut

    my $subcategory_id = ( defined($q->param('subcategorym_id')) ) ? $q->param('subcategorym_id') : $q->param('subcategory_id');
    $subcategory_id = ( 3 < $subcategory_id ) ? 4 : $subcategory_id;

    my $convertmethod = [
        undef,
        \&_convertImageForEmoji,
        \&_convertImageForPuchiDecoDecome,
        \&_convertImageForPuchiDecoDecome,
        \&_convertImageForDecoTmpltFlash,
    ];

    foreach my $fh (@imagef) {

        my ($image, $image1, $image2) = $convertmethod->[$subcategory_id]->($fh);

        my $mime_type = $q->uploadInfo($fh)->{'Content-Type'};

        ## image/x-png �� image/pjpeg ����SB��AU�ŕ\���ł��Ȃ��̂ŏC��
        $mime_type =~ s!(^image/)x-(png)$!$1$2!;
        $mime_type =~ s!(^image/).+?(jpeg)$!$1$2!;

        my $InsertImage = {
            id          => $id,
            productm_id => $productm_id,
            image       => $image,
            image1      => $image1,
            image2      => $image2,
            mime_type   => $mime_type,
        };

        my $last_insert_id = $self->_storeImageM($InsertImage);
        if (!$last_insert_id) {
            $obj->{ERROR_MSG}      = "Image Data Insert Failed Operation is aborted";
            ## DB�C���T�[�g���s
            $obj->{IfInsertDBFail} = 1;

            return $obj;
        }
        else {
            $obj->{product_id}        = $productm_id;
            $obj->{IfInsertDBSuccess} = 1;
            $obj->{id}                = $last_insert_id;
        }
=pod
        if (!$self->_storeImageM($InsertImage)) {
            $obj->{ERROR_MSG}      = "Image Data Insert Failed Operation is aborted";
            ## DB�C���T�[�g���s
            $obj->{IfInsertDBFail} = 1;

            return $obj;
        } else {
            $obj->{product_id}        = $productm_id;
            $obj->{IfInsertDBSuccess} = 1;
        }
=cut
    }

    ## �L���b�V������Â��f�[�^���Ȃ������ߑS�č폜 2009/07/21
    $self->flushAllFromCache();

    return $obj;
}


#******************************************************
# @access    public
# @desc      �f�R���쐬�A�f�R�҂���p
# @desc      �J�e�S��ID��6
#******************************************************
sub uploadImageMofDecoMachi {
    my $self = shift;
    my $q    = $self->getCgiQuery();
    my $obj  = {};

    if (!$q->param('image')) {
        $obj->{IfError}       = 1;
        $obj->{ERROR_MSG}      = '�摜������܂���B�I�����Ă��������B';
        $obj->{IfHistoryBack} = 1;

        return $obj;
    }

    my $status_flag = $q->param('status_flag');
    my $latest_flag = $q->param('latest_flag');
    my $charge_flag = $q->param('charge_flag');
    my $point_flag  = $q->param('point_flag');
    my ( $category_id, $subcategory_id, $EncodedCategoryName, $EncodedSubCategoryName ) = split(/;/, $q->param('subcategory_id'));
    unless ( 6 == $category_id ) {
        $obj->{IfError}       = 1;
        $obj->{ERROR_MSG}      = '�J�e�S�����f�R�҈ȊO�͈ꊇ�o�^�͂ł��܂���B';
        $obj->{IfHistoryBack} = 1;
        return $obj;
    }

    ## �����A�b�v�����Ή�
    my @imagef       = $q->upload('image');
    my @productnames = $q->param('product_name');

    ## 20100527 _convertImageForDecoMachi�ǉ�
    my $convertmethod = [
        undef,
        \&_convertImageForEmoji,
        \&_convertImageForPuchiDecoDecome,
        \&_convertImageForPuchiDecoDecome,
        \&_convertImageForDecoTmpltFlash,
        \&_convertImageForDecoTmpltFlash,
        \&_convertImageForDecoMachi,
    ];

    ## ���̃f�[�^�͕����ł����Ă��S������
    my $updateData = {
        product_id         => -1,
        status_flag        => $status_flag,
        charge_flag        => $charge_flag,
        point_flag         => $point_flag,
        latest_flag        => $latest_flag,
        product_name       => undef,
        categorym_id       => 2 ** $category_id,
        subcategorym_id    => $subcategory_id,
        tmplt_id           => undef,
    };

    use MyClass::JKZDB::Product;
    my $dbh        = $self->getDBConnection();
    my $cmsProduct = MyClass::JKZDB::Product->new($dbh);
    my $attr_ref   = MyClass::UsrWebDB::TransactInit($dbh);

    my $idx;

    foreach my $fh (@imagef) {

        if ( "" eq $productnames[$idx] ) {
            $obj->{IfError}       = 1;
            $obj->{ERROR_MSG}     = '�R���e���c��������܂���';
            $obj->{IfHistoryBack} = 1;
            return $obj;
        }
        my ($image, $image1, $image2) = $convertmethod->[$category_id]->($fh);

        my $mime_type = $q->uploadInfo($fh)->{'Content-Type'};

        ## image/x-png �� image/pjpeg ����SB��AU�ŕ\���ł��Ȃ��̂ŏC��
        $mime_type =~ s!(^image/)x-(png)$!$1$2!;
        $mime_type =~ s!(^image/).+?(jpeg)$!$1$2!;

        eval {
            $updateData->{product_name} = $productnames[$idx];
            $dbh->do('set names sjis');
            $cmsProduct->executeUpdate($updateData);

            ## �V�K�̏ꍇ��product_id���������킩��悤�� mysqlInsertIDSQL��commit�̑O�Ŏ擾
            my $productm_id = $cmsProduct->mysqlInsertIDSQL();

            my $InsertImage = {
                productm_id => $productm_id,
                image       => $image,
                image1      => $image1,
                image2      => $image2,
                mime_type   => $mime_type,
            };

           $self->_storeImageM($InsertImage);

           $dbh->commit();

            $obj->{product_name}->[$idx]     = $productnames[$idx];
            $obj->{product_id}->[$idx]       = $productm_id;
            $obj->{category_name}->[$idx]    = $q->unescape($EncodedCategoryName);
            $obj->{subcategory_name}->[$idx] = $q->unescape($EncodedSubCategoryName);

        };
        ## ���s�̃��[���o�b�N
        if ($@) {
            $dbh->rollback();
            $obj->{IfError}        = 1;
            $obj->{ERROR_MSG}      = $self->_ERROR_MSG("ERR_MSG20");
            $obj->{IfInsertDBFail} = 1;

        ## ���[�v���I������
            last;

        }

        $idx++;
    }

    $obj->{IfInsertDBSuccess} = 1 unless $obj->{IfError};
    $obj->{LoopProductList} = $idx - 1;

    ## autocommit�ݒ�����ɖ߂�
    JKZ::UsrWebDB::TransactFin($dbh, $attr_ref, $@);
    undef($cmsProduct);

    $self->flushAllFromCache();

    return $obj;
}


#******************************************************
# @access    private
# @desc        �T�C�g���摜���i�[
# @param
# @param
# @return    boolean
#******************************************************
sub _storeSiteImage {
    my ($self, $data) = @_;

    my $dbh = $self->getDBConnection();
    $dbh->do('set names utf8');
    my $Image = MyClass::JKZDB::SiteImage->new($dbh);
    if (!$Image->executeUpdate($data)) {
        return -1;
    }
    ## Modified Replace�Ńf�[�^���i�[���Ă��邩��A�㏑���̏ꍇ��insert_id���擾�ł��Ȃ�����R�����g�A�E�g 2010/03/05
    ## �T�C�g�̉摜�Ǘ��ł̓f�[�^�A�b�v��ɂ��̉摜��ID�͕s�v�������肪����
    #my  $insert_id = $Image->mysqlInsertIDSQL();
    #return $insert_id;
    return 1;
}


#******************************************************
# @access    public
# @desc        �摜�폜
# @param
# @param
# @return    boolean
#******************************************************
sub deleteSiteImage {
    my $self = shift;
    my $q    = $self->query();
    my $obj  = {};

    unless ($q->param('i')) {
        $obj->{IfNoIDSelected} = 1;
        return $obj;
    }

    my $id    = $q->param('i');
    my $dbh   = $self->getDBConnection();
    my $Image = MyClass::JKZDB::SiteImage->new($dbh);

    if (!$Image->deleteImageSQL($id)) {

            $obj->{ERROR_MSG} = "Delete Image Data Failed Operation is aborted";
            ## DB�폜���s
            $obj->{IfDeleteDBFail} = 1;
            return $obj;
    }

    $obj->{id}                 = $id;
    $obj->{IfDelelteDBSuccess} = 1;
    $self->flushAllFromCache();

    return $obj;
}


#******************************************************
# @access    public
# @desc        �摜�폜
# @param
# @param
# @return    boolean
#******************************************************
sub deleteImageM {
    my $self = shift;
    my $q = $self->query();
    unless ($q->param('p')) {

        return undef;
    }

    my $obj = {};

    my $productref;
   $productref = $q->param('p') if !$q->param('i');

   if ($q->param('i')) {
       $productref = {
           productm_id => $q->param('p'),
           id          => $q->param('i'),
       };
   }

    my $dbh         = $self->getDBConnection();
    my $Image       = MyClass::JKZDB::ProductImage->new($dbh);

    if (!$Image->deleteImageSQL($productref)) {
        $obj->{ERROR_MSG} = "Delete Image Data Failed Operation is aborted";
        $obj->{IfDeleteDBFail} = 1;

        return $obj;
    }

    $obj->{product_id}    = exists($productref->{productm_id}) ? $productref->{productm_id} : $productref;
    $obj->{IfDeleteDBSuccess} = 1;

    ## �L���b�V������Â��f�[�^���Ȃ������ߑS�č폜 2009/07/21
    $self->flushAllFromCache();

    return $obj;
}


#******************************************************
# @access    private
# @desc        �摜���i�[
# @desc        �����tProdcutImageM���g�p�����炵���o�[�W����
# @param
# @param
# @return    boolean
#******************************************************
sub _storeImageM {
    my ($self, $data) = @_;

    my $dbh = $self->getDBConnection();
    $dbh->do('set names utf8');
    my $Image = MyClass::JKZDB::ProductImage->new($dbh);
    if (!$Image->executeUpdate($data)) {

        return -1;
    }
    #my  $insert_id = $Image->mysqlInsertIDSQL();
    #return $insert_id;
    return 1;
}


#******************************************************
# @@�������牺�̓N���X���\�b�h�ł͂Ȃ��T�u���[�e�B��
#******************************************************


#******************************************************
# @access    private
# @desc        �J�e�S���P �G�����p�摜��ϊ�
# @desc        ���摜�Ɂusample�v�̕�����������40x30�̉摜�𐶐�
# @param    filehandle $fh(�摜�̃t�@�C���n���h��)
# @return    $image_data, $sample_image_data1, $sample_image_data2
#******************************************************
sub _convertImageForEmoji {
    my $fh = shift;

    #**********************************
    # ���p�X�̎擾���āusample�v�t�@�C�����擾
    # �T���v���摜�e���v���[�g�̓ǂ݂���
    #**********************************
    #require Cwd;
    #my $pwd = Cwd::getcwd();
    #my $READFILE = sprintf("%s/bg_smp.gif", $pwd);
    #my $READFILE = '/home/vhostsuser/KKFLA/JKZ/JKZ/JKZApp/bg_smp.gif';
    # �J���f�B���N�g��

    my ($err, $image_data, $sample_image_data);

    #**********************************
    # �摜�f�[�^�̓ǂݍ��� �{�摜�͊���
    #**********************************
    (read($fh, $image_data, -s $fh) == -s $fh)
        or die ("Can't read image file: $!");

    #**********************************
    # blob���C���[�W���A���擾
    #**********************************
    my $img = Image::Magick->new(magick=>'gif');
    $err = $img->BlobToImage($image_data);
    die "Can't Blob to  Image file: $err\n" if $err;

    my $height  = $img->Get('height');
    my $width   = $img->Get('width');

    #**********************************
    # �����usample�v�̉摜
    #**********************************
    #my $READFILE = '/home/vhosts/MYSDK/JKZ/JKZ/JKZApp/sample.gif';
    my $READFILE = '/home/vhosts/MYSDK/JKZ/JKZ/JKZApp/bg_smp.gif';
    my $sampletmplt = Image::Magick->new();
    $sampletmplt->Read($READFILE);

=pod
    my $clone_img = $img->Clone();
    if ( 30 > $width ) {
        $clone_img->Thumbnail(geometry=>'geometry', width=>'34');
    }
    $clone_img->Composite(image=>$sampletmplt, gravity => "South");
    $sample_image_data = $clone_img->ImageToBlob();
=cut
    $sampletmplt->Composite(image=>$img->[0], gravity=>"north");
    $sample_image_data = $sampletmplt->ImageToBlob();

    undef $img;

    return ($image_data, $sample_image_data, undef);
}


#******************************************************
# @access    private
# @desc        �J�e�S���Q�E�R �v�`�f�R�E�f�R���p�摜��ϊ�
# @desc        ���摜��gif�A�j��������60px�ŐÎ~�����T���v���摜�𐶐� ��30x40�̉摜��3�p�^�[��
# @param    filehandle $fh(�摜�̃t�@�C���n���h��)
# @return    $image_data, $sample_image_data1, $sample_image_data2
#******************************************************
sub _convertImageForPuchiDecoDecome {
    my $fh = shift;

    my ($err, $image_data, $sample_image_data);
    #**********************************
    # �摜�̓ǂ݂��݂ƃf�[�^��
    #**********************************
    my $img = Image::Magick->new();

    (read($fh, $image_data, -s $fh) == -s $fh)
        or die ("Can't read image file: $!");
    $err = $img->BlobToImage($image_data);
    die "Can't read image file: $err\n" if $err;
    #**********************************
    # gif�A�j���摜��1�t���[���ڂ��������T�C�Y���ăT���v���ɂ���
    #**********************************
    my ($width, $height) = $img->Get('width','height');
    #my $smp_width = ("199" <= $width) ? "100" : "60";
    my $smp_width = ("199" <= $width) ? "100" : $width;
    $img->[0]->Thumbnail(geometry=>"$smp_width",mode=>"Unframe");
    $sample_image_data = $img->[0]->ImageToBlob();

    return ($image_data, $sample_image_data, undef);
}


#******************************************************
# @access    private
# @desc        �J�e�S���S�E�T �f�R���e���v���[�g�E�t���b�V���p�摜�ϊ�
# @param    240x320 60x80 30x40��3�p�^�[���̉摜�𐶐�
# @param
# @param    filehandle $fh(�摜�̃t�@�C���n���h��)
# @return    $image_data, $sample_image_data1, $sample_image_data2
#******************************************************
sub _convertImageForDecoTmpltFlash {
    my $fh = shift;

    my ($err, $image_data, $sample_image_data1, $sample_image_data2);
    #**********************************
    # �摜�̓ǂ݂��݂ƃf�[�^��
    #**********************************
    my $img = Image::Magick->new();

    (read($fh, $image_data, -s $fh) == -s $fh)
        or die ("Can't read image file: $!");
    $err = $img->BlobToImage($image_data);
    die "Can't read image file: $err\n" if $err;

    my ($width, $height) = $img->Get('width','height');
    $img->Scale(geometry=>'240x240');
    $image_data = $img->ImageToBlob();
    $img->Scale(geometry=>'70x70');
    $sample_image_data1 = $img->ImageToBlob();
    $img->Scale(geometry=>'50x50');
    $sample_image_data2 = $img->ImageToBlob();

    return ($image_data, $sample_image_data1, $sample_image_data2);
}


#******************************************************
# @access    private
# @desc        �摜��ϊ�
# @param    240x320 60x80 30x40��3�p�^�[���̉摜�𐶐�
# @param
# @param    filehandle $fh(�摜�̃t�@�C���n���h��)
# @return    $image_data, $sample_image_data1, $sample_image_data2
#******************************************************
sub _convertImageFor {
    my $fh = shift;

    my ($err, $image_data, $sample_image_data1, $sample_image_data2);
    #**********************************
    # �摜�̓ǂ݂��݂ƃf�[�^��
    #**********************************
    my $img = Image::Magick->new();

    (read($fh, $image_data, -s $fh) == -s $fh)
        or die ("Can't read image file: $!");
    $err = $img->BlobToImage($image_data);
    die "Can't read image file: $err\n" if $err;

    my ($width, $height) = $img->Get('width','height');
    $img->Scale(geometry=>'240x240');
    $image_data = $img->ImageToBlob();
    $img->Scale(geometry=>'70x70');
    $sample_image_data1 = $img->ImageToBlob();
    $img->Scale(geometry=>'50x50');
    $sample_image_data2 = $img->ImageToBlob();

    return ($image_data, $sample_image_data1, $sample_image_data2);
}


#******************************************************
# @access    private
# @desc        �摜��ϊ�
# @param
# @param
# @param
# @return    
#******************************************************
=pod
sub _convertImageSize {
    my $fh = shift;

    my ($image_data, $thumbnail_data_240320,$thumbnail_data_6080,$thumbnail_data_3040);
    my $err;
    my $img = Image::Magick->new;

    (read($fh, $image_data, -s $fh) == -s $fh)
        or confess ("Can't read image file: $!");
    $err = $img->BlobToImage($image_data);
    confess("Can't convert image data: $err") if $err;

    $err = $img->Scale (geometry => "240x320");
    confess("Can't convert image data: $err") if $err;
    $thumbnail_data_240320 = $img->ImageToBlob();
    $err = $img->Scale (geometry => "60x80");
    confess("Can't convert image data: $err") if $err;
    $thumbnail_data_6080 = $img->ImageToBlob();
    $err = $img->Scale (geometry => "30x40");
    confess("Can't convert image data: $err") if $err;
    $thumbnail_data_3040 = $img->ImageToBlob();

    return ($image_data, $thumbnail_data_240320,$thumbnail_data_6080,$thumbnail_data_3040);

}
=cut

1;

__END__