#******************************************************
# @desc      アンケート管理クラス
# @package   JKZ::JKZApp::AppQuestionnarie
# @access    public
# @author    Iwahase Ryo
# @create    2009/09/30
# @update         
# @version   1.00
#******************************************************
package JKZ::JKZApp::AppQuestionnarie;

use 5.008005;
our $VERSION = '1.00';

use strict;

use JKZ::JKZApp;
@JKZ::JKZApp::AppQuestionnarie::ISA = qw( JKZ::JKZApp );

use JKZ::JKZDB::QuestionnarieM;
use JKZ::JKZDB::Questionnarie;
use JKZ::JKZDB::QuestionnarieElement;
use JKZ::JKZDB::AnswerElement;
use JKZ::JKZDB::QuestionnarieAnswer;
use JKZ::JKZDB::QuestionnarieAnswerData;

#use WebUtil;


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
# @desc        親クラスのgetActionをオーバーライド。ここはサブクラスごとに設定
# @param    
#******************************************************
sub getAction {
    my $self = shift;

    return (!$self->action() ? 'viewQuestionnarieList' : $self->action());
}


#******************************************************
# @access    public
# @desc        親クラスのメソッド
# @param    
#******************************************************
sub dispatch {
    my $self = shift;

    my $publishdir      = $self->PUBLISH_DIR() . '/Questionnarie';
    my $adminpublishdir = $self->PUBLISH_DIR() . '/admin/Questionnarie';
    unless (-d $publishdir) {
        WebUtil::createDir($publishdir);
    }
    unless (-d $adminpublishdir) {
        WebUtil::createDir($adminpublishdir);
    }

    $self->{publishdir}      = $publishdir;
    $self->{adminpublishdir} = $adminpublishdir;

    $self->SUPER::dispatch();
}


#******************************************************
# @access    
# @desc        アンケート回答表示
# @param    
# @param    
# @return    
#******************************************************
sub viewQuestionnarieAnswerDataByID {

    my $self = shift;
    my $q    = $self->getCgiQuery();
    my $obj  = {};

    my $questionnariem_id = $q->param('questionnariem_id');
    $obj->{description}   = $q->param('description');

    my $dbh = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $QAD = JKZ::JKZDB::QuestionnarieAnswerData->new($dbh);

    $QAD->executeSelectList({
        whereSQL    => 'questionnariem_id=?',
        placeholder => [$questionnariem_id],
    });
    $obj->{LoopQuestionnariedDataList} = $QAD->countRecSQL();

    if (0 > $obj->{LoopQuestionnariedDataList}) {
        $obj->{ERRORMSG} = 'データがありません。';
        $obj->{IfNoData} = 1;
    }
    else {
        #*****************************
        # DBから取り出したオブジェクトをアンシリアライズ
        #*****************************
        require Storable;
        Storable->import(qw( thaw ));

        foreach my $i (0..$obj->{LoopQuestionnariedDataList}) {
            map { $obj->{$_}->[$i] = $QAD->{columnslist}->{$_}->[$i] } keys %{ $QAD->{columnslist} };

            $obj->{answer_date}->[$i]   = WebUtil::formatDateTimeSeparator($obj->{answer_date}->[$i], {sepfrom => '-', septo => '/', offset => 2, limit => 14});
            $obj->{answerdataref}->[$i] = thaw(unpack("u", $obj->{answer_object}->[$i]));

            map {
                    $obj->{ 'DumpQuestionNumber' . $_ }->[$i] = $obj->{answerdataref}->[$i]->{question_and_anwer}->[$_]->[0];
                    $obj->{ 'DumpQuestion' . $_ }->[$i]       = $obj->{answerdataref}->[$i]->{question_and_anwer}->[$_]->[1];
                    $obj->{ 'DumpAnswer' . $_ }->[$i]         = join('　', @{ $obj->{answerdataref}->[$i]->{question_and_anwer}->[$_]->[3] });
            } 1..$#{ $obj->{answerdataref}->[$i]->{question_and_anwer} };

        }
        $obj->{IfData} = 1;
    }

    return $obj;

}


#******************************************************
# @access   
# @desc     アンケート種別一覧 デフォルト表示
# @param    
# @param    
# @return   
#******************************************************
sub viewBaseQuestionnarieList {
    my $self = shift;

    my $obj = {};
    my $dbh = $self->getDBConnection();
    $self->setDBCharset("sjis");

    my $cms = JKZ::JKZDB::QuestionnarieM->new($dbh);
    $cms->executeSelectList();

    if (0 <= $cms->countRecSQL()) {
        $obj->{LoopQuestionnarieList} = $cms->countRecSQL();
        $obj->{IfExistsQuetionnarie}  = 1;

        my @IfStatus_flag = ('IfInvalid', 'IfValid');

        for (my $i = 0; $i <= $obj->{LoopQuestionnarieList}; $i++) {
            map { $obj->{$_}->[$i] = $cms->{columnslist}->{$_}->[$i] } keys %{ $cms->{columnslist} };

            $obj->{encodeddescription}->[$i] = $self->{q}->escape($obj->{description}->[$i]);
            $obj->{status_flagImages}->[$i]  = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$i]-1));
            $obj->{$IfStatus_flag[$obj->{status_flag}->[$i] - 1]}->[$i] = 1;
        }
    }
    else {
        $obj->{IfNotExistsQuetionnarie} = 1;
    }

    return $obj;
}


#******************************************************
# @access    アンケート種別詳細
# @desc        
# @param    
# @param    
# @return    
#******************************************************
sub detailBaseQuestionnarie {
    my $self = shift;

    my $q = $self->getCgiQuery();
    $q->autoEscape(0);

    my $obj = {};

    my $questionnariem_id = $q->param('questionnariem_id') || undef;
    
    my $dbh = $self->getDBConnection();
    $self->setDBCharset("sjis");
    my $cms = JKZ::JKZDB::Questionnarie->new($dbh);
    $cms->executeSelectList({
        whereSQL    => 'questionnariem_id=?',
        orderbySQL  => 'questionnarief_id DESC',
        placeholder => [$questionnariem_id],
    });

    if (0 <= $cms->countRecSQL()) {
        $obj->{LoopQuestionnarieList} = $cms->countRecSQL();
        $obj->{IfExistsQuetionnarie}  = 1;

        my @IfStatus_flag = ('IfInvalid', 'IfValid');

        for (my $i = 0; $i <= $obj->{LoopQuestionnarieList}; $i++) {
            map { $obj->{$_}->[$i] = $cms->{columnslist}->{$_}->[$i] } keys %{ $cms->{columnslist} };

            $obj->{status_flagImages}->[$i]                             = $self->fetchOneValueFromConf('STATUSIMAGES', ($obj->{status_flag}->[$i]-1));
            $obj->{$IfStatus_flag[$obj->{status_flag}->[$i] - 1]}->[$i] = 1;
            $obj->{encoded_description}->[$i]                           = $q->escape($q->param('description'));
            $obj->{encoded_name_of_questionnarie}->[$i]                 = $q->escape($obj->{name_of_questionnarie}->[$i]);

        }
    }
    else {
        $obj->{IfNotExistsQuetionnarie} = 1;
    }
    $obj->{QuestionnariemID}   = $questionnariem_id;
    $obj->{encodeddescription} = $q->param('description');
    $obj->{description}        = $q->unescape($q->param('description'));

    return $obj;
}


#******************************************************
# @access    
# @desc        アンケート種別の追加
# @param    
# @param    
# @return    
#******************************************************
sub addBaseQuestionnarie {



}


#******************************************************
# @access    
# @desc        アンケートの追加
# @param    
# @param    
# @return    
#******************************************************
sub addQuestionnarie {
    my $self = shift;
    my $q    = $self->getCgiQuery();
	my $obj  = {};

    $q->autoEscape(0);

    my $questionnariem_id = $q->param('questionnariem_id');

    $obj->{md5key} = WebUtil::createHash($self->__session_id(), 20);
    my $publish    = sprintf("%s/%s_%s.obj", $self->publishdir("adminpublishdir"), $obj->{md5key}, $questionnariem_id);

    if (defined($q->param('md5key'))) {
        eval {
            my $publishobj = WebUtil::publishObj( { file=>$publish } );
            map { $obj->{$_} = $publishobj->{$_} } keys %{ $publishobj };
        };
        if($@) {

        }
    }

    $obj->{description}           = $q->unescape($q->param('description')) if $q->param('description');
    $obj->{questionnariem_id}     = $q->param('questionnariem_id') if $q->param('questionnariem_id');
    $obj->{question}              = $q->param('question') if $q->param('question');
    $obj->{type_of_answer}        = $q->param('type_of_answer') if $q->param('type_of_answer');
    $obj->{number_of_answer}      = $q->param('number_of_answer') if $q->param('number_of_answer');
    $obj->{number_of_question}    = $q->param('number_of_question') if $q->param('number_of_question');
    $obj->{name_of_questionnarie} = $q->param('name_of_questionnarie') if $q->param('name_of_questionnarie');

    #******************************
    # データのパブリッシュ
    #******************************
    WebUtil::publishObj({file=>$publish, obj=>$obj});

    ## アンケートのオブジェクトの初期化
    ## 変動する値は下で格納
=pod
    $obj = {
        questionnariem_id        => $questionnariem_id,
        questionnarief_id        => $questionnarief_id,
        description                => $description,
        name_of_questionnarie    => $name_of_questionnarie,
        number_of_question        => $number_of_question,
        questionnarieElement    => {},
        answerElement            => {},
    };
=cut


    if(!defined($q->param('step')) and $q->param('md5key') eq "") {
        $obj->{IfStepA}           = 1;
        $obj->{questionnariem_id} = $q->param('questionnariem_id');
        $obj->{description}       = $q->unescape($q->param('description'));
    }
    elsif(1 == $q->param('step')) {
        $obj->{IfStepB} = 1;

        $obj->{LoopQuestions}     = $obj->{number_of_question}-1;
        map { $obj->{CNT}->[$_-1] = $_ } 1..$obj->{number_of_question};

    }
    elsif(2 == $q->param('step')) {
        $obj->{IfStepC} = 1;
        my @questionarieelement_id = (1..$obj->{number_of_question});
        my @questions              = $q->param('question');
        my @type_of_answers        = $q->param('type_of_answer');
        my @number_of_answers      = $q->param('number_of_answer');
        my @answers1               = $q->param('answer_1');
        my @answers2               = $q->param('answer_2');
        my @answers3               = $q->param('answer_3');
        my @answers4               = $q->param('answer_4');

        foreach my $id (1..$obj->{number_of_question}) {
            $obj->{questionnarieElement}->{questionnarieelementf_id}->[$id-1] = $id;
            $obj->{questionnarieElement}->{question}->[$id-1] = $questions[$id-1];
            $obj->{questionnarieElement}->{type_of_answer}->[$id-1]    =$type_of_answers[$id-1];
            $obj->{answerElement}->{number_of_answer}->[$id]  = $number_of_answers[$id-1];
            $obj->{answerElement}->{answerelementf_id}->[$id] = [1..$number_of_answers[$id-1]];
            $obj->{answerElement}->{answer}->[$id]            = [$answers1[$id-1], $answers2[$id-1], $answers3[$id-1], $answers4[$id-1]];
        }

        my $QFData = {
            questionnarief_id     => -1,
            questionnariem_id     => $obj->{questionnariem_id},
            number_of_question    => $obj->{number_of_question},
            name_of_questionnarie => $obj->{name_of_questionnarie},
        };

        my $QEFData;
        my $AEFData;

        foreach my $Qcnt (1..$obj->{number_of_question}) {
            $QEFData->[$Qcnt]->{questionnariem_id}        = $obj->{questionnariem_id};
            $QEFData->[$Qcnt]->{questionnarief_id}        = "";#$questionnarief_id,
            $QEFData->[$Qcnt]->{questionnarieelementf_id} = $Qcnt;
            $QEFData->[$Qcnt]->{question}                 = $questions[$Qcnt-1];
            $QEFData->[$Qcnt]->{type_of_answer}           = $type_of_answers[$Qcnt-1];
            $QEFData->[$Qcnt]->{number_of_answer}         = $number_of_answers[$Qcnt-1];

            foreach my $Acnt (1..$QEFData->[$Qcnt]->{number_of_answer}) {
                $AEFData->[$Qcnt]->[$Acnt]->{questionnariem_id}        = $obj->{questionnariem_id};
                $AEFData->[$Qcnt]->[$Acnt]->{questionnarief_id}        = "";
                $AEFData->[$Qcnt]->[$Acnt]->{questionnarieelementf_id} = $Qcnt;
                $AEFData->[$Qcnt]->[$Acnt]->{answerelementf_id}        = $Acnt;
                $AEFData->[$Qcnt]->[$Acnt]->{answer}                   = $obj->{answerElement}->{answer}->[$Qcnt]->[$Acnt-1];
            }
        }

        my $dbh = $self->getDBConnection();
        $self->setDBCharset('SJIS');
        my $QF  = JKZ::JKZDB::Questionnarie->new($dbh);
        my $QEF = JKZ::JKZDB::QuestionnarieElement->new($dbh);
        my $AEF = JKZ::JKZDB::AnswerElement->new($dbh);

        my $attr_ref = JKZ::UsrWebDB::TransactInit($dbh);

        eval {
        #****************************
        # アンケートデータ挿入
        #****************************
            $QF->executeUpdate($QFData, -1);
            my $questionnarief_id = $QF->mysqlInsertIDSQL();
$obj->{OBJECT} .= '<hr>' . WebUtil::warnMSGtoBrowser($QFData, __LINE__);
            #****************************
            # 質問データ挿入
            #****************************
            foreach my $i (@{ $QEFData }) {
                next if !defined $i->{questionnariem_id};
                $i->{questionnarief_id} = $questionnarief_id;
                $QEF->executeUpdate($i, -1);
$obj->{OBJECT} .= '<hr>' . WebUtil::warnMSGtoBrowser($i, __LINE__);
                #****************************
                # 回答データ挿入
                #****************************
                foreach my $j (@{ $AEFData->[$i->{questionnarieelementf_id}] }) {
                    next if !defined $j->{questionnariem_id};
                    $j->{questionnarief_id} =  $questionnarief_id;
                    $AEF->executeUpdate($j, -1);
$obj->{OBJECT} .= '<hr>' . WebUtil::warnMSGtoBrowser($j, __LINE__);
                }
            }
            $dbh->commit();
        };
            ## 失敗のロールバック

        if ($@) {
            $obj->{OBJECT} = $@;

        }
        else {
            ## 要処理追加

        }

        JKZ::UsrWebDB::TransactFin($dbh,$attr_ref,$@);


=pod
questionnarieElement->{questionnarieelementf_id}->[##CNT##] = 
questionnarieElement->{question}->[##CNT##] = 
answerElement->{answerelementf_id}->[##CNT##] = 
answerElement->{answer}->[##CNT##] = [undef, $q->param('answer_1##CNT##'), $q->param('answer_2##CNT##'), $q->param('answer_3##CNT##'), $q->param('answer_4##CNT##')]

        questionnarieElement    => {
                questionnarieelementf_id    => [
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                ],
                question                    => [
                    '好きな性別は',
                    '好きなくだものは',
                     '好きなことはﾊﾞｲｸは',
                     '好きなことは車は',
                     '最後の晩餐に食べたいものは',
                ],
        },
        answerElement            => {
                answerelementf_id    => [
                    undef, ## questionnarieelementf_idが～番目のインデックスとなるから、０番目は無し
                    [1, 2,], # @{ {answerElement}->{answerelementf_id} }
                    [1, 2, 3,],
                    [1, 2, 3, 4,],
                    [1, 2, 3, 4,],
                    [1, 2, 3, 4,],
                    [1, 2, 3,],
                ],
                answer                => [
                    undef,
                    [undef, '女性', '男性',], # answer->[$questionnarieelementf_id]->[$answerelementf_id]
                    [undef, '群所色', '紫色', '無色',],
                    [undef, '柿', '枇杷', 'ﾄﾞﾘｱﾝ', 'しし唐', ],
                    [undef, 'ﾊﾞﾌﾞ', 'ﾎｰｸ', 'FX', 'ざり',],
                    [undef, 'ﾌｨｱｯﾄ', '現代', 'HINO', 'ﾄﾖﾀ',],
                    [undef, '奈良漬', 'ｶﾚｰうどん', 'にんじん',],
                ]
        },
=cut

    }
    elsif(3 == $q->param('step')) {
        $obj->{IfStepD} = 1;
    }


#$obj->{DUMP} = WebUtil::warnMSGtoBrowser($tmpobj);
#$obj->{DUMP} .= '<hr>' . $q->Dump();
#$obj->{DUMP} .= '<hr />' . WebUtil::warnMSGtoBrowser($obj);
    return $obj;

}




#******************************************************
# @access    
# @desc        アンケートHTMLデータの構築と有効化
# @param    
# @param    
# @return    
#******************************************************
sub buildQuestionnarie {
    my $self = shift;

    my $q = $self->getCgiQuery();
    $q->autoEscape(0);

    my $questionnariem_id     = $q->param('questionnariem_id');
    my $questionnarief_id     = $q->param('questionnarief_id');
    my $description           = $q->unescape($q->param('encoded_description'));
    my $name_of_questionnarie = $q->unescape($q->param('encoded_name_of_questionnarie'));
    my $number_of_question    = $q->param('number_of_question');

    ## アンケートのオブジェクトの初期化
    ## 変動する値は下で格納
    my $obj = {
        questionnariem_id     => $questionnariem_id,
        questionnarief_id     => $questionnarief_id,
        description           => $description,
        name_of_questionnarie => $name_of_questionnarie,
        number_of_question    => $number_of_question,
        questionnarieElement  => {},
        answerElement         => {},
        htmlobj               => undef,
    };

=pod
        questionnarieElement    => {
                questionnarieelementf_id    => [
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                ],
                question                    => [
                    '好きな性別は',
                    '好きなくだものは',
                     '好きなことはﾊﾞｲｸは',
                     '好きなことは車は',
                     '最後の晩餐に食べたいものは',
                ],
        },
        answerElement            => {
                answerelementf_id    => [
                    undef, ## questionnarieelementf_idが～番目のインデックスとなるから、０番目は無し
                    [1, 2,], # @{ {answerElement}->{answerelementf_id} }
                    [1, 2, 3,],
                    [1, 2, 3, 4,],
                    [1, 2, 3, 4,],
                    [1, 2, 3, 4,],
                    [1, 2, 3,],
                ],
                answer                => [
                    undef,
                    [undef, '女性', '男性',], # answer->[$questionnarieelementf_id]->[$answerelementf_id]
                    [undef, '群所色', '紫色', '無色',],
                    [undef, '柿', '枇杷', 'ﾄﾞﾘｱﾝ', 'しし唐', ],
                    [undef, 'ﾊﾞﾌﾞ', 'ﾎｰｸ', 'FX', 'ざり',],
                    [undef, 'ﾌｨｱｯﾄ', '現代', 'HINO', 'ﾄﾖﾀ',],
                    [undef, '奈良漬', 'ｶﾚｰうどん', 'にんじん',],
                ]
        },
=cut

    my $dbh = $self->getDBConnection();
    $self->setDBCharset("sjis");

    my $aryref = $dbh->selectall_arrayref(
        "SELECT * FROM tQuestionnarieElementF WHERE questionnariem_id=? AND questionnarief_id=? ORDER BY questionnarieelementf_id;",
        { Columns => {} },
        $questionnariem_id, $questionnarief_id
    );

    my @ques_array;

    foreach my $qel (@{ $aryref }) {

        #******************************
        # object質問部分生成(questionnarieElement)
        #******************************
        push(@{ $obj->{questionnarieElement}->{questionnarieelementf_id} }, $qel->{questionnarieelementf_id});
        $obj->{questionnarieElement}->{question}->[$qel->{questionnarieelementf_id}] = $qel->{question};

        #******************************
        # objectのhtmlobj部分生成
        #******************************
        my $htmltag;
        $htmltag = $qel->{question} . '<br />';
        $htmltag .=
            (1 == $qel->{type_of_answer}) ? sprintf("<select name=\"ques%d\">",$qel->{questionnarieelementf_id}) :
            (4 == $qel->{type_of_answer}) ? sprintf("<input type=\"text\" name=\"ques%d\" />", $qel->{questionnarieelementf_id}) : "";

        my $aryref2 = $dbh->selectall_arrayref(
            "SELECT answerelementf_id, answer FROM tAnswerElementF WHERE questionnariem_id=? AND questionnarief_id=? AND questionnarieelementf_id=? ORDER BY answerelementf_id;",
            { Columns => {} },
            $questionnariem_id, $questionnarief_id, $qel->{questionnarieelementf_id}
        );

        foreach my $ael (@{ $aryref2 }) {
            #******************************
            # object質問部分生成(answerElement)
            #******************************
            push(@{ $obj->{answerElement}->{answerelementf_id}->[$qel->{questionnarieelementf_id}] }, $ael->{answerelementf_id});
            $obj->{answerElement}->{answer}->[$qel->{questionnarieelementf_id}]->[$ael->{answerelementf_id}] = $ael->{answer};

            #******************************
            # objectのhtmlobj部分生成
            #******************************
            $htmltag .=
                (1 == $qel->{type_of_answer}) ? sprintf("<option value=%d;%s>%s</option>", $qel->{questionnarieelementf_id}, $ael->{answerelementf_id}, $ael->{answer}) :
                (2 == $qel->{type_of_answer}) ? sprintf("<input type=radio name=ques%d value=%d;%s />%s", $qel->{questionnarieelementf_id}, $qel->{questionnarieelementf_id}, $ael->{answerelementf_id}, $ael->{answer}) :
                (3 == $qel->{type_of_answer}) ? sprintf("<input type=checkbox name=ques%d value=%d;%s />%s", $qel->{questionnarieelementf_id}, $qel->{questionnarieelementf_id}, $ael->{answerelementf_id}, $ael->{answer}) : "";

        }

        $htmltag .= '</select>' if 1 == $qel->{type_of_answer};

        push(@ques_array, $htmltag);
    }

    $obj->{htmlobj} = join('<br />', @ques_array);

    #******************************
    # データのパブリッシュ
    #******************************
    my $publish = sprintf("%s/Questionnarie%s.obj", $self->publishdir(), $questionnariem_id);
    WebUtil::publishObj({file=>$publish, obj=>$obj});

    #******************************
    # データの有効化と無効化実行
    #******************************
    my $myQuestionnarie = JKZ::JKZDB::Questionnarie->new($dbh);
    if (!$myQuestionnarie->autoupdateStatusFlag($questionnariem_id, $questionnarief_id)) {
        $obj->{ERRORMSG} = 'データの更新に失敗しました。';
    }
    $obj->{encodeddescription} = $description;
    $obj->{htmlobj}            = $obj->{htmlobj};

    return $obj;

}


#autoupdateStatusFlag(questionnariem_id,questionnarief_id)

#******************************************************
# @desc        accessor
# @return    
#******************************************************
sub publishdir {
    my $self = shift;
    return $self->{$_[0]} if $_[0];
    return ($self->{publishdir});
}



1;
__END__
