#******************************************************
# $Id: ,v 1.0 2011/12/16 RyoIwahase Exp $
# @desc      
# 
# @package   MyClass::JKZUtil
# @desc      このフレームワークでなにかしらの処理を実行するツール群
#             メール送信/モジュール実行 etc
# @author    Iwahase Ryo
# @create    2011/12/16
# @update    2011/12/27 モジュール実行メソッド追加
# @version   1.0
#******************************************************
package MyClass::JKZUtil;

use 5.008005;
our $VERSION = '1.00';
use strict;
use warnings;
no warnings 'redefine';

use MyClass::WebUtil;
use MyClass::TransferMail;

#******************************************************
# @access    public
# @desc        コンストラクタ
# @param    
# @return    
#******************************************************
sub new {
    my ($class, $cfg) = @_;

    my $self = {
        cfg => $cfg,
    };

    return (bless ($self, $class));
}


sub cfg {
    return shift->{cfg};
}


#******************************************************
# @desc     モジュールディレクトリにあるモジュールの実行
# @param    string 設定ファイル(envconf.cfg)にある識別名
# @param    
# @return   
#******************************************************
sub execute_module {
    my $self        = shift;
    my $key         = 1 > @_ ? undef : shift; return if !defined($key);
    my $mod_name    = $self->configuration_value($key);
    my $mod_dir     = $self->configuration_value("MODULE_DIR");

    my $msg;

    if (-e sprintf("%s/%s", $mod_dir, $mod_name)) {
        my $rc  = `cd $mod_dir && perl $mod_name`;
        $msg    = sprintf("\nEXECUTE MODULE : %s [ RESULT : %s ]\n", $mod_name, $rc);
    }
    else {
        $msg = sprintf("\nNO SUCH MODULE : %s [ RESULT : MODULE CANNOT BE EXECUTED ]\n", $mod_name);
    }

    warn $msg;
    return $msg;
}


#******************************************************
# @desc     メール送信処理 
#           第一引数はメール内の置き換え文字のハッシュ
#           第二引数はtMailConfMのid
# @param    hashobj { emailaddress, その他 }
# @param    tMailConfM.id
# @return   
#******************************************************
sub send_mail_by_sendmail {
    my ($self, $hashobj, $id) = @_;

    my $mailconfobj = $self->__get_from_objectfile({ CONFIGURATION_VALUE => 'MAILCONFLIST_OBJ', subject_id => $id } );

    $mailconfobj->{body} =~ s{ %%(.*?)%% }{ exists($hashobj->{$1}) ? $hashobj->{$1} : "" }gex;

    my $mailcontents = {
        sendmail        => $self->cfg->param('SENDMAIL_PATH'),
        subject         => $mailconfobj->{subject},
        from            => $mailconfobj->{from_address},
        contents_body   =>
"
$mailconfobj->{body}
$mailconfobj->{footer}
",
    };

    my $myMail = MyClass::TransferMail->new();
    $myMail->setMailContents($mailcontents);
    $myMail->setMailAddress($hashobj->{emailaddress});
    $myMail->SendMailSend();
}


#******************************************************
# @desc        シリアライズオブジェクトからデータを取得
# @param    事前にシリアライズされて保存されていること
# @param    configuration value { CONFIGURATION_VALUE=>'', subject_id=> 'これは取得したいデータのid'}
# @return    arrayobj [{}] 対象リストのID順のarrayobjectです
#******************************************************
sub __get_from_objectfile {
    my ($self, $param) = @_;

    return if !exists($param->{CONFIGURATION_VALUE});

    my $keyvalue = $param->{CONFIGURATION_VALUE};
    my $objfile  = $self->configuration_value($keyvalue);
    my $obj;

    eval {
        $obj = MyClass::WebUtil::publishObj( { file => $objfile } );
    };
    if ($@) {
        return undef;
    }

    ## 引数が無い場合は全てを返す
    return $obj unless $param->{subject_id};

    return $obj->[$param->{subject_id}];
}


#******************************************************
# @desc     envconf.cfgに値を取得して配列で返す
# @param    key
# @return    array
#******************************************************
sub __fetch_array_values_from_conf {
    my $self = shift;
    unless (@_) { return; }

    my $name = shift;
    my @values = split(/,/, $self->cfg->param($name));

    return (@values);
}


#******************************************************
# @desc     envconfからCommonUse.xxxMに対応するデータを取得
#           envconfの定数からデータを取得
#           配列で格納されている 引数の値に対応する値を返す
# @param    $string        envconf内の定数名
# @param    $integer
# @return   $value
#******************************************************
sub __fetch_one_value_from_conf {
    my $self = shift;
    unless (@_) { return; }

    my ($name, $value) = @_;
    my $values = $self->{cfg}->param($name);
    my @tmplist = split(/,/, $values);

    return ($tmplist[$value]);
}


#******************************************************
# @desc     
# @param    
# @param    
# @return   
#******************************************************
sub __fetch_values_from_conf {
    my $self = shift;
    unless (@_) { return; }

    my ($name, $defaultvalue) = @_;
    my @values = split(/,/, $self->{cfg}->param($name));

    my $obj;
    no strict ('subs');
    $obj->{Loop . $name . List} = $#values;

    for  (my $i = 0; $i <= $#values; $i++) {
    $obj->{$name . Index}->[$i] = $i;
    $obj->{$name . Value}->[$i] = MyClass::WebUtil::convertByNKF('-s', $values[$i]);
    $obj->{$name . 'defaultvalue'}->[$i] = $defaultvalue == $i ? ' selected' : "";
    }

    return $obj;
}


#******************************************************
# @desc      設定ファイルのキーを引数に対応した値を取得
#            キーが存在しない場合undefを返す
#            引数が複数の場合(リストコンテキスト)は配列で値を返す
#            引数が単一の場合(スカラコンテキスト)はスカラで値を返す
#
# @param     char    $configrationkey
# @return    char/undef    $configrationvalue
#******************************************************
sub configuration_value {
    my $self = shift;

    return undef if 1 > @_;

    my %CONFIGRATIONKEY = $self->cfg->vars();

    return (
        1 == @_
            ?
            ( $self->{CONFIGURATION_VALUE}->{$_[0]} = exists($CONFIGRATIONKEY{$_[0]}) ? $CONFIGRATIONKEY{$_[0]} : undef )
            :
            ( map { $self->{CONFIGURATION_VALUE}->{$_} = ( exists($CONFIGRATIONKEY{$_}) ) ? $CONFIGRATIONKEY{$_} : undef  } @_ )
    );
}


1;
__END__