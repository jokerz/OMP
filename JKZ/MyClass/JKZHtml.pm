#******************************************************
# @desc		htmlテンプレートの独自タグの値変換
# @package	JKZ::JKZHtml
# @access	public
# @author	Iwahase Ryo
# @create	2007/05/15
# @version	1.01
# @version	1.02
# @update   2007/09/20
#			convertHtmlTagsのLoop処理の修正
#			2008/02/09
#			テンプレートをDatabaseから取得処理対応
# @update	2008/07/10 memcahceを使用してテンプレート処理
# @update	2009/01/27 キャリア互換絵文字処理追加
# @update	2009/02/17 Loop中のIf処理を追加
# @update	2009/02/17 不要な置換処理文を削除 [[]]でくくってあるもの
# @IMPORTANT 2009/03/18 条件置換タグ __IfXxxYyy__ のXxxYyyの部分に＿「アンダースコア」は使用不可
# @update	2010/01/07 load_source_codeメソッドを追加…プラグイン処理をするときに使用
# @update   2010/07/07 doPrintTagsForMobileメソッド追加とconvertHtmlTagsメソッドでのエンコード処理を排除
# @update    2011/10/31 convertHtmlTagsメソッド内の最終処理に特殊変数のURIエンコード処理を追加
# @update    2011/10/31 doPrintTags にて文字コード指定処理を追加
#******************************************************
package MyClass::JKZHtml;

use 5.008000;
use strict;

our $VERSION ='1.02';

#******************************************************
# @access	public
# @desc		コンストラクタ
#			
# @param	\%strings
#			$template
#			$integer 0/1
# @return	
#******************************************************
sub new {
    my $class = shift;
    my $self = {
        q            => undef,
        TMPLT        => undef,
        ## if flag is 1 template source is taken from database table
        DATABASEFLG  => undef,
        OUTPUTFLG    => undef,
        SRCFILE      => undef,
        FILENAME     => undef,
        FILESRC      => undef,
    };

    $self->{q}            = shift;
    $self->{TMPLT}        = shift;
    $self->{DATABASEFLG}  = shift;
    $self->{OUTPUTFLG}    = shift;
    $self->{SRCFILE}      = $ENV{'SCRIPT_FILENAME'};

    bless($self, $class);
}


#******************************************************
# @access	public
# @desc		テンプレートファイルをセットします
# @param	
# @return	
#******************************************************
sub setfile {
    my $self = shift;

    if ('default' eq $self->{TMPLT}) {
        ## Modified 2008/02/01
        ($self->{FILENAME} = $self->{SRCFILE}) =~ s!^(/[^\.].*?/)(.*?)\.(.*?)$!$1$2!;
        $self->{FILENAME} .= '.tmplt';
    }
    else {
        $self->{FILENAME} = $self->{TMPLT} . '.tmplt';
    }
    $self->{FILENAME} = $self->{SRCFILE} . 'maintenance.tmplt' if ! -e $self->{FILENAME};

    return $self->{FILENAME};
}


#******************************************************
# @access	public
# @desc		ファイルのソースコードを取得 テンプレートをファイルで保存していてpluginのフック処理をしたいときは事前にソースの内容を取得する必要があるため
# @return	source code
#******************************************************
sub load_source_code {
    my $self = shift;

    require MyClass::UsrWebDB;
    my $memcached = MyClass::UsrWebDB::MemcacheInit();
    my $obj = $memcached->get("tmplt:$self->{FILENAME}");
    if (!$obj) {
        local $/;
        local *F;
        open(F, "< $self->{FILENAME}\0") || die $self->{FILENAME};
        $obj = <F>;
        close(F);

        $memcached->add("tmplt:$self->{FILENAME}", $obj, 120);
    }

    return $obj;
}


#******************************************************
# @access	public
# @desc		置換文字列処理を行います
#			Loop処理から順に
#			If処理
#			多重ハッシュ処理
#			単品処理
#
# @param	\$tags
# @return	
#******************************************************
sub convertHtmlTags {
    my $self = shift;
    my $tags = shift;

    ## DataBaseからではなく、ファイル処理の場合
    unless (1 == $self->{DATABASEFLG}) {
    ## Modified 2010/01/07
        my $obj = $self->load_source_code();

# Modified 2010/07/07 BEGIN 処理なし

     #   require MyClass::JKZMobile;
        ## JKZMobileクラス追加で絵文字端末相互交換処理試験中 2009/01/28
     #   $obj = MyClass::JKZMobile::decode_to('x-sjis-imode', $obj);
     #   my $mobile = MyClass::JKZMobile->new();
     #   $self->{FILESRC} = $mobile->encodeText($obj, 1);

         $self->{FILESRC} = $obj;

# Modified 2010/07/07 END

    } else {
        $self->{FILESRC} = $self->{TMPLT};
    }

    #******************************************************
    # Loop処理
    #******************************************************
    1 while ($self->{FILESRC} =~ s/__(Loop[^_]+)__
        ((?:(?!__Loop).)+?)
        __\1__/ my $tmpmsg;
        for (my $i = 0; $i <= $tags->{$1}; $i++) {
            $tmpmsg .= $2;
            no strict ('refs');
            $tmpmsg =~ s{__(If.[^_]+)__((?:(?!__If).)+?)__\1__}{exists($tags->{$1}) && 1 == $tags->{$1}->[$i] ? $2 : ""}geos;
            $tmpmsg =~ s{ %&(.*?)&% }{ exists($tags->{$1}) ? $tags->{$1}->[$i] : $1}gex;
        }
        $tmpmsg /gexs
    );

    #******************************************************
    # If処理
    #******************************************************
    1 while ($self->{FILESRC} =~ s/__(If.[^_]+)__((?:(?!__If).)+?)__\1__/
                                exists ($tags->{$1}) && 1 == $tags->{$1} ? $2 : ""
                                /gexs
    );

    #******************************************************
    # 単一処理
    #******************************************************
    my $strrep = qr/(.*?)/;
    $self->{FILESRC} =~ s{ %& $strrep &% }{ exists ($tags->{$1}) ? $tags->{$1} : ""}geox;

    #******************************************************
    # @MODIFIED 2011/10/31
    # @DESC     ENCODE SPECIFIC STRINGS, CHARACTER
    #           encode strings & = ? / :
    #******************************************************
=pod とりあえずOMPでは不要
    my $and_regex   = qr/\[\[AND\]\]/;
    my $eq_regex    = qr/\[\[EQ\]\]/;
    my $ques_regex  = qr/\[\[QUESTION\]\]/;
    my $slash_regex = qr/\[\[SLASH\]\]/;
    my $colon_regex = qr/\[\[COLON\]\]/;
    my $enc_eq      = '%3D';
    my $enc_and     = '%26';
    my $enc_ques    = '%3F';
    my $enc_slash   = '%2F';
    my $enc_colon   = '%3A';

    $self->{FILESRC} =~ s/$and_regex/$enc_and/geo;
    $self->{FILESRC} =~ s/$eq_regex/$enc_eq/geo;
    $self->{FILESRC} =~ s/$ques_regex/$enc_ques/geo;
    $self->{FILESRC} =~ s/$slash_regex/$enc_slash/geo;
    $self->{FILESRC} =~ s/$colon_regex/$enc_colon/geo;
=cut

    $self->{OUTPUTFLG} ? $self->doPrintTags() : $self->{FILESRC};
}


#******************************************************
# @access	public
# @desc		ファイル内容を出力します
# @param	
# @return	
#******************************************************
sub doPrintTags {
    # modified 2011/11/01 BEGIN
    my $self = shift;
    my $opt  = shift;

    # 文字コード・指定がない場合はデフォルトでshift_jis
    my $charset = exists( $opt->{charset} ) ? $opt->{charset} : 'shift_jis';
    my $cookie  = exists( $opt->{cookie} )  ? $opt->{cookie} : undef;
    defined $cookie ? print $self->{q}->header(-cookie=>$cookie,-charset=>$charset) : print $self->{q}->header(-charset=>$charset);
    # modified 2011/11/01 END

   # my $self = shift;
   # my $cookie = shift if @_;
   ## Modified 2008/04/28
   # defined $cookie ? print $self->{q}->header(-cookie=>$cookie,-charset=>"shift_jis") : print $self->{q}->header(-charset=>"shift_jis");


    print $self->{FILESRC};
}


#******************************************************
# @access	public
# @desc		携帯用にファイル内容を出力します
# @param	
# @return	
#******************************************************
=pod
sub doPrintTagsForMobile {
    my $self = shift;
    my $cookie = shift if @_;

    defined $cookie ? print $self->{q}->header(-cookie=>$cookie,-charset=>"shift_jis") : print $self->{q}->header(-charset=>"shift_jis");

    require MyClass::JKZMobile;
    my $mobile    = MyClass::JKZMobile->new();
    print $mobile->encodeText($self->{FILESRC}, 1);
}


#******************************************************
# @access	private
# @desc		外部モジュールのメソッドが無いばあいの処理
# @param	
# @return	
#******************************************************
sub _methodError {
    my $self = shift;
    $self->{methodError} = 'unable to find  method \n ';
    return $self->{methodError};
}
=cut

1;
__END__
