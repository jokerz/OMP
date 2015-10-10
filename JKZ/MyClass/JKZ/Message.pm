#******************************************************
# @desc       会員メッセージ配信クラス
# @package    MyClass::JKZ::Message
# @access     public
# @author     Iwahase Ryo
# @create     2010/06/14
# @version    1.00
# @update     
# パラメータ：
#******************************************************
package MyClass::JKZ::Message;

use strict;
use warnings;
use 5.008005;
our $VERSION = '1.00';

use base qw(MyClass::JKZ::MemberContents);

use MyClass::JKZDB::MessageInBox;
use MyClass::JKZDB::MessageOutBox;
use MyClass::JKZDB::Member;

use JKZ::Mobile::Emoji;

use Data::Dumper;

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


sub run {
    my $self = shift;

    $self->SUPER::run();
}


sub default_messageBox {
    my $self = shift;


}


#******************************************************
# @access    public
# @desc     受信メッセージ一覧
# @param    
# @return    
#******************************************************
sub viewlist_messageInBox {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->getDBConnection();

    my $owid = $self->attrAccessUserData("owid");
    my $obj  = {};
    #*****************************
    # 1ページの表示件数の処理
    #*****************************
    my $record_limit = 5;
    my $offset = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;


    my $messageInBox = MyClass::JKZDB::MessageInBox->new($dbh);
    $self->setDBCharset("sjis");
    $messageInBox->executeSelectList( { whereSQL    => 'recipient_owid = ?',
                                        orderbySQL  => 'received_date DESC',
                                        limitSQL    => "$offset, $condition_limit",
                                        placeholder => ["$owid",],
                                      }
                                    );

    $obj->{LoopMessageInBoxList} = ($record_limit == $messageInBox->countRecSQL()) ? $record_limit -1 : $messageInBox->countRecSQL();
    if (0 <= $obj->{LoopMessageInBoxList}) {
        $obj->{IfExitstData} = 1;
        for (my $i = 0; $i <= $obj->{LoopMessageInBoxList}; $i++) {
            map { $obj->{$_}->[$i] = $messageInBox->{columnslist}->{$_}->[$i] } keys %{ $messageInBox->{columnslist} };

            $obj->{subject}->[$i]     = JKZ::Mobile::Emoji::hex2emoji($obj->{subject}->[$i]);
            $obj->{LMESSAGEURL}->[$i] = $self->MESSAGEURL();

            if ($record_limit == $messageInBox->countRecSQL()) {
                $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
                $obj->{IfNextData} = 1;
            }
            if ($record_limit <= $offset) {
                $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
                $obj->{IfPreviousData} = 1;
            }
        }
    }
    else {
        $obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s',$self->ERROR_MSG ('ERR_MSG11'));
    }

    return $obj;
}


#******************************************************
# @access    public
# @desc     送信メッセージ一覧
# @param    
# @return    
#******************************************************
sub viewlist_messageOutBox {
    my $self = shift;
    my $q    = $self->query();
    my $dbh  = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $owid = $self->attrAccessUserData("owid");
    my $obj  = {};
    #*****************************
    # 1ページの表示件数の処理
    #*****************************
    my $record_limit = 5;
    my $offset = $q->param('off') || 0;
    my $condition_limit = $record_limit+1;


    my $messageOutBox = MyClass::JKZDB::MessageOutBox->new($dbh);
    $messageOutBox->executeSelectList( {  whereSQL    => 'sender_owid = ?',
                                          orderbySQL  => 'send_date DESC',
                                          limitSQL    => "$offset, $condition_limit",
                                          placeholder => ["$owid",],
                                       }
                                     );

    $obj->{LoopMessageOutBoxList} = ($record_limit == $messageOutBox->countRecSQL()) ? $record_limit -1 : $messageOutBox->countRecSQL();

    if (0 <= $obj->{LoopMessageOutBoxList}) {
        $obj->{IfExitstData} = 1;
        for (my $i = 0; $i <= $obj->{LoopMessageOutBoxList}; $i++) {
            map { $obj->{$_}->[$i] = $messageOutBox->{columnslist}->{$_}->[$i] } keys %{ $messageOutBox->{columnslist} };
            # メッセージ件名絵文字変換処理
            $obj->{subject}->[$i] = JKZ::Mobile::Emoji::hex2emoji($obj->{subject}->[$i]);
            $obj->{LMESSAGEURL}->[$i] = $self->MESSAGEURL();

            if ($record_limit == $messageOutBox->countRecSQL()) {
                $obj->{offsetTOnext} = (0 < $offset) ? ($offset + $condition_limit - 1) : $record_limit;
                $obj->{IfNextData} = 1;
            }
            if ($record_limit <= $offset) {
                $obj->{offsetTOprevious} = ($offset - $condition_limit + 1);
                $obj->{IfPreviousData} = 1;
            }
        
        }
    }
    else {
        $obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s',$self->ERROR_MSG ('ERR_MSG11'));
    }

    return $obj;

}


#******************************************************
# @access    public
# @desc     受信詳細
# @param    
# @return    
#******************************************************
sub view_message {
    my $self = shift;
    my $q    = $self->query();

    my $owid       = $self->attrAccessUserData("owid");
    my $message_id = $q->param('message_id');

    ## 受信か送信かで条件カラムが違う
    my $obj = {};
    my %condition = (
        wherestr    => 'message_id=?',
        placeholder => ["$message_id",],
    );

    my $dbh  = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $mymessage = MyClass::JKZDB::MessageInBox->new($dbh);

    if (!$mymessage->executeSelect( { whereSQL => 'message_id=?', placeholder => ["$message_id"] } )) {
        $obj->{ERROR_MSG} = $self->ERROR_MSG('ERR_MSG14');
    }
    else {
        map { $obj->{$_} = $mymessage->{columns}->{$_} } keys %{ $mymessage->{columns} };

        ## この時点でメッセージ内容を見るのでここで未読を既読に更新
        $self->_updateNULLStatusMessage($dbh, $obj->{message_id}) if exists ($obj->{status_flag}) && $obj->{status_flag} eq '';

        $obj->{subject} = JKZ::Mobile::Emoji::hex2emoji($obj->{subject});
        $obj->{message} = JKZ::Mobile::Emoji::hex2emoji($obj->{message});

        $obj->{subject} = MyClass::WebUtil::escapeTags ($obj->{subject});
        $obj->{message} = MyClass::WebUtil::escapeTags ($obj->{message});
        $obj->{message} =~ s!\r\n!<br />!g;

    ## Modified Enable to PrintOut DoCoMoEmoji For All Carrier 2009/03/31 BEGIN
#        require MyClass::JKZMobile;
#        my $mobile = MyClass::JKZMobile->new();
#        $obj->{message} = $mobile->convertEmojiCode($obj->{message});
    ## Modified 2009/03/31 END

        ## 日付を整える
        $obj->{received_date}    =~ s!-!/!g;
        $obj->{received_date}    = substr ($obj->{received_date}, 0, 16);
        $obj->{send_date}        =~ s!-!/!g;
        $obj->{send_date}        = substr ($obj->{send_date}, 0, 16);

        ## エスケープした件名
        $obj->{escape_subject} = $q->escape ($obj->{subject});

        ## エスケープしたﾆｯｸﾈｰﾑ
        $obj->{escape_sender_nickname}    = $q->escape( $obj->{sender_nickname} );
        $obj->{escape_recipient_nickname} = $q->escape( $obj->{recipient_nickname} );

        ## プロフィールページへの相手のID取得
=pod
        my $search_hp_user_owid = 'ib' eq $table ? $obj->{sender_owid} : $obj->{recipient_owid};
        my $myMember = MyClass::JKZDB::Member->new ($dbh);
        my $hp_user_id = $myMember->getIDbyOWID ($search_hp_user_owid);

        $obj->{HP_PROFILE_URL} = $self->{HP_URL}
                            . '/'
                            . $hp_user_id
                            . '/?prof'
                            . '&c='
                            . $cryptpassword_cur_date
                            ;

        ## Modified 画像付の場合 2008/10/01 BEGIN
        if (2 == $obj->{image_flag}) {
            my $messageImage = MyClass::JKZDB::TempImage->new ($dbh);
            $obj->{sendimage_id} = $messageImage->getOneValue ({
                column        => 'sendimage_id',
                wherestr    => 'message_id=? AND recipient_owid=?',
                placeholder => ["$message_id", "$owid"],
            });
            $obj->{IfMessageWithImage} =1;
        }
=cut
    }

    ## 未読のキャッシュ更新
    $self->checkNULLStatusMessage();

    return $obj;
}


#******************************************************
# @access    public
# @desc     メッセージ送信フォーム
# @param    
# @return   
#******************************************************
sub show_message_form {
    my $self = shift;
    my $q    = $self->query();
    my $obj;
    my ($owid, $ciphered) = split(/::/, $self->query->param('s'));
    ## 暗号コードと会員ID不一致もしくはエラー
    unless ($self->owid == $owid && MyClass::WebUtil::decipher($owid, $ciphered)) {
       $obj->{ERROR_MSG} = MyClass::WebUtil::convertByNKF('-s', $self->ERROR_MSG("ERR_MSG99"));
       return $obj;
    }

    $obj->{s} = $self->owid_ciphered();
    my $toid = $q->param('toid');
    my $escape_neighbor_nickname = $q->param('escape_neighbor_nickname');
    my $neighbor_nickname        = $q->unescape($escape_neighbor_nickname);

    ## 返信メッセージの判定
    $obj->{IfReplyMessage}   = (defined ($q->param('reply_message_id'))) ? 1 : 0;
    $obj->{reply_message_id} = $q->param('reply_message_id') if 1 == $obj->{IfReplyMessage};

    if ( 0 > $q->param('f') || !defined ($q->param('message_id')) ) {
        $obj->{subject} = MyClass::WebUtil::escapeTags($q->unescape($q->param('subject')));
        $obj->{message} = MyClass::WebUtil::escapeTags($q->unescape($q->param('message')));

        if (1 == $obj->{IfReplyMessage}) {
            $obj->{resubject} = 'Re:' . $q->escapeHTML($q->param('resubject'));
        }
        $obj->{IfConfirm} = 1;
    } else {
        $obj->{IfSendMessage} = 1;
        $obj->{subject} = $q->escape($q->param('subject'));
        $obj->{message} = $q->escape($q->param('message'));
        $obj->{preview_subject} = MyClass::WebUtil::escapeTags($q->param('subject'));
        $obj->{preview_message} = MyClass::WebUtil::escapeTags($q->param('message'));
        $obj->{preview_message} = MyClass::WebUtil::yenRyenN2br($q->param('message'));
    }

    ## message_idがまだなければ生成。あればそのまま使用
    $obj->{message_id} = (!defined ($q->param('message_id'))) ? MyClass::WebUtil::createHash(rand (), 20) : $q->param('message_id');
    $obj->{escape_neighbor_nickname} = $escape_neighbor_nickname;
    $obj->{neighbor_nickname}        = $neighbor_nickname;
    $obj->{toid}                     = $toid;

    return $obj;
}


#******************************************************
# @access    public
# @desc        メッセージ送信
# @param    
# @return    
#******************************************************
sub send_message {
    my $self = shift;
    my $q    = $self->query();
    my ($owid, $s_ciphered) = split(/::/, $self->query->param('s'));
    my $obj;

    ## 不正防止
    unless ( $q->MethPost() || $owid || defined( $q->param('message_id') ) ) {
        ## 正常処理続行不可
        $obj->{ERROR_MSG} = $self->ERROR_MSG ('ERR_MSG98');
    } else {
        my ($message_id, $reply_message_id, $toid, $neighbor_nickname, $subject, $message);
        my ($status_flag, $nickname);

        $message_id        = $q->param('message_id');
        $reply_message_id  = defined ($q->param('message_id')) ? $q->param('message_id') : '';
        $nickname          = $self->attrAccessUserData('nickname');
        $neighbor_nickname = $q->unescape($q->param('escape_neighbor_nickname'));
        $toid              = $q->param('toid');
        #$subject           = defined ($q->param('image_flag')) ? $q->unescape($q->param('subject')) : $q->param('subject');
        #$message           = defined ($q->param('image_flag')) ? $q->unescape($q->param('message')) : $q->param('message');
        $subject           = $q->unescape($q->param('subject'));
        $message           = $q->unescape($q->param('message'));

        $subject           = JKZ::Mobile::Emoji::emoji2hex($subject);
        $message           = JKZ::Mobile::Emoji::emoji2hex($message);

        ## 送信ボックス挿入データ
        my $OutBoxinsertData = {
            message_id         => $message_id,
            reply_message_id   => $reply_message_id,
            sender_owid        => $owid,
            recipient_owid     => $toid,
            recipient_nickname => $neighbor_nickname,
            subject            => $subject,
            message            => $message,
        };
        ## 受信ボックス挿入データ
        my $InBoxinsertData = {
            message_id      => $message_id,
            status_flag     => '',
            sender_owid     => $owid,
            recipient_owid  => $toid,
            sender_nickname => $nickname,
            subject         => $subject,
            message         => $message,
        };

        #$InBoxinsertData->{image_flag} = 2 if 0 < int($q->param('image_flag'));
        my $dbh = $self->getDBConnection();
        $self->setDBCharset("sjis");
        my $myMessageOutBox = MyClass::JKZDB::MessageOutBox->new($dbh);
        my $myMessageInBox  = MyClass::JKZDB::MessageInBox->new($dbh);

        ## この2つのテーブルクラスは新規挿入の場合はマイナスフラグを立てる
        $obj->{IfSendOK} = 1;
        if (!$myMessageOutBox->executeUpdate($OutBoxinsertData, -1)) {
            ## tMessageOutBoxにインサート失敗したら終了
            $obj->{ERROR_MSG}  = $self->ERROR_MSG('ERR_MSG8');
            $obj->{IfSendOK}   = 0;
            $obj->{IfSendFAIL} = 1;
        } else {
            if (!$myMessageInBox->executeUpdate($InBoxinsertData, -1)) {
                $obj->{ERROR_MSG}  = $self->ERROR_MSG('ERR_MSG8');
                ## tMessageInBoxにインサート失敗したら上で挿入したデータを削除しないとだめ。
                ## 処理を追加しないと…
                $obj->{IfSendOK}   = 0;
                $obj->{IfSendFAIL} = 1;
            }
        #***********************************
        # Modified 画像付メッセにつき処理
        #***********************************
=pod
            if ($obj->{IfSendOK}) {
                if (0 < $q->param('image_flag') && 0 < $q->param('sendimage_id')) {
                    my $sendimage_id = $q->param('sendimage_id');
                    my $TempImageInsertData = {
                        message_id     => $message_id,
                        sender_owid    => $owid,
                        recipient_owid => $toid,
                        sendimage_id   => $sendimage_id,
                    };
                    my $myTempImage = MyClass::JKZDB::TempImage->new($dbh);
                    if (!$myTempImage->executeUpdate($TempImageInsertData, -1)) {
                        $obj->{ERROR_MSG}  = $self->ERROR_MSG ('ERR_MSG8');
                        $obj->{IfSendOK}   = 0;
                        $obj->{IfSendFAIL} = 1;
                    }
                    $obj->{IfSendImageOK} = 1;
                }
            }
=cut
        }
        $obj->{neighbor_nickname} = $neighbor_nickname;
    }

    return $obj;
}



#******************************************************
# @access    _private
# @desc        未読ﾒｯｾｰｼﾞを既読にすると読んだ日
# @param    
# @return    
#******************************************************
sub _updateNULLStatusMessage {
    my ($self, $dbh, $message_id) = @_;
    $self->setDBCharset("sjis");
    my $myMessageInBox = MyClass::JKZDB::MessageInBox->new($dbh);
    $myMessageInBox->updateNULLStatusMessage([$message_id]);
}


1;
__END__