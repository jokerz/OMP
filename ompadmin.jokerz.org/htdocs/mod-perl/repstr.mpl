#******************************************************
# @desc		�u������������Ǘ�
# @package	repstr.mpl
# @access	public
# @author	Iwahase Ryo
# @create	2004/07/28
# @update 	
# @version	1.00
#******************************************************

use strict;
use CGI::Carp qw(fatalsToBrowser);
#use Data::Dumper;
my $q = CGI->new();


my $STRREF = {
    SCALARSTR    => {
        DESC    => '�ϐ�  �ԕ��������͑Ή�����ID�����L�q',
        VALUE    => {
            COMMON        => {
                DESC        => "�T�C�g�S�̂Ŏg�p����O���[�o���ϐ�(�������͐�΂ɂ��Ȃ�����)",
                ARRAYVALUE    => [
['&#37;&amp;BENCH_TIME&amp;&#37;', '�������Ԍv���@�f�o�b�O��œK���A�s������̂Ƃ��Ɏg�p', ''],
['&#37;&amp;DUMP&amp;&#37;', '�_���v�f�[�^', ''],
['&#37;&amp;ERROR_MSG&amp;&#37;', '�����G���[�Ȃǂ̃��[�U�[�֑΂��ẴG���[���b�Z�[�W', ''],
['&#37;&amp;SITE_NAME&amp;&#37;', '�T�C�g��', ''],
['&#37;&amp;MAINURL&amp;&#37;', '�����g�b�vURL(�L�����A���ɕK�v�ȃp�����[�^���t�^�����)', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;', '����g�b�vURL(�L�����A���ɕK�v�ȃp�����[�^���t�^�����)', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;', '������y�[�WURL', ''],
['&#37;&amp;CARTURL&amp;&#37;', '���i���X�g�E�w������URL', ''],
['&#37;&amp;IMAGE_SCRIPTDATABASE_NAME&amp;&#37;', '���i�摜�\���v���O����URL', ''],
['&#37;&amp;SITEIMAGE_SCRIPTDATABASE_URL&amp;&#37;', '�T�C�g���摜�\���v���O����URL', ''],
['&#37;&amp;FLASH_SCRIPT_URL&amp;&#37;', 'FLASH�f�[�^�����E�\���v���O����URL', ''],
['&#37;&amp;DECOTMPLT_SCRIPT_URL&amp;&#37;', '�f�R���e���v���[�g�f�[�^�����E�\���v���O����URL', ''],
['&#37;&amp;DECOICON_SCRIPT_URL&amp;&#37;', '�f�R���E�G�����f�[�^�����E�\���v���O����URL', ''],
                ],
            },
            NONMEMBER            => {
                DESC        => "�����y�[�W�p�ϐ�",
                ARRAYVALUE    => [
['/a/detail/o/product/pr/p=<font style="color:red;">[���iID]</font>/%&MAINURL&amp;&#37;', '���i�ڍ�', ''],
['/a/list/o/product_by_c/pr/c=<font style="color:red;">[�J�e�S��ID]</font>/%&MAINURL&amp;&#37;', '�J�e�S���ʏ��i���X�g', ''],
['/a/list/o/product_by_sbc/pr/sbc=<font style="color:red;">[���J�e�S��ID]</font>/%&MAINURL&amp;&#37;', '���J�e�S���ʏ��i���X�g', ''],
['/a/list/o/product_by_smc/pr/smc=<font style="color:red;">[���J�e�S��ID]</font>/%&MAINURL&amp;&#37;', '���J�e�S���ʏ��i���X�g', ''],
['/a/list/o/all_product/pr/off=0/%&MAINURL&amp;&#37;', '�S���i���X�g', ''],
['/a/list/o/new_product/pr/off=0/%&MAINURL&amp;&#37;', '�V�����i���X�g', ''],

                ],
            },
            MEMBER          => {
                DESC        => "����y�[�W�p�ϐ�",
                ARRAYVALUE    => [
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=detail&o=product&p=<font style="color:red;">[���iID]</font>', '���i�ڍ�', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=product_by_c&c=<font style="color:red;">[�J�e�S��ID]</font>', '�J�e�S���ʏ��i���X�g', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=product_by_sbc&sbc=<font style="color:red;">[���J�e�S��ID]</font>', '���J�e�S���ʏ��i���X�g', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=product_by_smc&smc=<font style="color:red;">[���J�e�S��ID]</font>', '���J�e�S���ʏ��i���X�g', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=all_product', '�S���i���X�g', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=new_product', '�V�����i���X�g', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=withdraw&o=member', '�މ�y�[�W�����NURL', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=view&o=profile', '������y�[�W�����NURL', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=edit&o=profile', '������ҏW�y�[�W�����NURL', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=list&o=purchase_history', '�w�������y�[�W�����NURL', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=list&o=point_history', '�|�C���g�擾�E������y�[�W�����NURL', ''],
['&#37;&amp;CARTURL&amp;&#37;a=list&o=confirm_product', '���i�������X�g�E�����y�[�W�����NURL', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=media_by_mc&mc=<font style="color:red;">[�L���J�e�S��ID]</font>', '�L���̊e�J�e�S������URL', ''],
['&#37;&amp;PTBKURL&amp;&#37;ad_id=<font style="color:red;">[�L��ID]</font>', '�L�������N', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=dl&o=flash&p=<font style="color:red;">[���iID]</font>', '�t���b�V���̃_�E�����[�h�����N', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=dl&o=decotmplt&p=<font style="color:red;">[���iID]</font>', '�f�R���e���v���[�g�̃_�E�����[�h�����N', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=dl&o=emoji&p=<font style="color:red;">[���iID]</font>', '�G�����̃_�E�����[�h�����N', ''],
['__If.HOOK.MYPAGEPOINTBACK__', '�}�C�y�[�W�\���ɓo�^�����|�C���g�L���̕\���u���b�N�B���̕ϐ��ŊJ�n���ďI���i�y�A�Ŏg�p�j',''],
['__LoopMyPagePointBackMediaList__', '�}�C�y�[�W�\���ɓo�^�����|�C���g�L���̃��[�v���������s�B���̕ϐ��ŊJ�n���ďI���i�y�A�Ŏg�p�j',''],
['&#37;&amp;ad_name&amp;&#37; &#37;&amp;point&amp;&#37; &#37;&amp;ad_16words_text&amp;&#37; &#37;&amp;PPTBKURL&amp;&#37;', 'LoopMyPagePointBackMediaList���Ŏg�p�ł���ϐ�', ''],
['__IfNickNameIsEmpty__', '����y�[�W�g�b�v�ɂăj�b�N�l�[�����o�^����ɑ΂��ĕ\������u���b�N�B���̕ϐ��ŊJ�n���ďI���i�y�A�Ŏg�p�j',''],
['__IfNickNameIsNotEmpty__', '����y�[�W�g�b�v�ɂăj�b�N�l�[���o�^�ς݉���ɑ΂��ĕ\������u���b�N�B���̕ϐ��ŊJ�n���ďI���i�y�A�Ŏg�p�j',''],
                ],
            },
            DEBUG_PAGE            => {
                DESC        => "�^�c�E�f�U�C���쐬�y�[�W�m�F",
                ARRAYVALUE    => [
['[�y�[�WURL]/pr/<font style="color:red;">debug=1&tf=[�e���v��ID]</font>/&#37;&amp;MAINURL&amp;&#37;', '�y�[�WURL��pr/�̌��debug=1&tf=[<font style="color:red;">�e���v��ID</font>]��ǉ����Ă��������B', 'http://1mp.1mp.jp/a/detail/o/product/pr/<font style="color:red;">debug=1&tf=55&</font>p=14/run.html?guid=ON'],
['&#37;&amp;MEMBERMAINURL&amp;&#37;[�y�[�WURL]<font style="color:red;">&debug=1&tf=[�e���v��ID]</font>', 'URL�̌��2�̃p�����[�^��ǉ����邱�Ƃŕ\�� <font style="color:red;">&debug=1&tf=[�e���v��ID]</font> ���[���F�؂����{���܂�', 'http://m.1mp.jp/?m_run.mpl?guid=ON&a=detail_product&p=37<font style="color:red;">&debug=1&tf=55</font>'],
['/a/view/o/help/pr/pg=<font style="color:red;">help_news</font>/&#37;&amp;MAINURL&amp;&#37;', '�����p�ǉ��y�[�W�̕\��<br />�e���v���[�g�쐬���̃y�[�W�R�[�h����<font style="color:red;">view_help_xxxyyy</font>�ƂȂ�悤�ɂ��Ă��������B', 'http://1mp.1mp.jp/a/view/o/help/pr/pg=help_news/run.html?guid=ON'],
['&#37;&amp;MAINURL&amp;&#37a=view&o=help&pg=<font style="color:red;">help_news</font>', '����p�ǉ��y�[�W�̕\��<br />�e���v���[�g�쐬���̃y�[�W�R�[�h����<font style="color:red;">view_help_xxxyyy</font>�ƂȂ�悤�ɂ��Ă��������B', 'http://m.1mp.jp/m_run.mpl?guid=ON&a=view&o=help&pg=help_news'],
                ],
            },
        },
    },
};
=pod
my $STRREF = {
	SCALARSTR	=> {
		DESC	=> '�ϐ�',
		VALUE	=> {
			REG			=> {
				DESC		=> "�����T�C�g����o�^�E���Ɋւ���ϐ�(�L�����A�T�[�o�[�Ƃ̔F�؁E�ʐM)�R�`���Ɋւ���l����΂ɒ������͂��Ȃ�����",
				ARRAYVALUE	=> [
					['&#37;&amp;Index&amp;&#37;', '', ''],
					['&#37;&amp;KKReq&amp;&#37;', '�����T�C�g�T�[�o�[�ɉ�����v�����s', ''],
					['&#37;&amp;KSReq&amp;&#37;', '�����T�C�g�T�[�o�[�ɉ���o�^�v�����s', ''],
					['&#37;&amp;cp_cd&amp;&#37;', '�R���e���c�v���o�C�_�[�R�[�h', ''],
					['&#37;&amp;cp_srv_cd&amp;&#37;', '�R���e���c�v���o�C�_�[�T�[�r�X�R�[�h', ''],
					['&#37;&amp;ok_url&amp;&#37;', '�����������̖߂�URL', ''],
					['&#37;&amp;ng_url&amp;&#37;', '�������s���̖߂�URL', ''],
					['&#37;&amp;item_cd&amp;&#37;', '�R���e���c�̃A�C�e���R�[�h', ''],
					['&#37;&amp;odr_sts&amp;&#37;', '', ''],
				],
			},
			CONTENTS	=> {
				DESC		=> "�T�C�g�R���e���c�Ɋւ���ϐ�",
				ARRAYVALUE	=> [
					['&#37;&amp;encryptid&amp;&#37;', '', ''],
					['&#37;&amp;category_name&amp;&#37;', '', ''],
					['&#37;&amp;subcategory_name&amp;&#37;', '', ''],
					['&#37;&amp;tranking_rank&amp;&#37;', '', ''],
					['&#37;&amp;title&amp;&#37;', '�R���e���c�^�C�g��', ''],
					['&#37;&amp;height&amp;&#37;', '�R���e���c����', ''],
					['&#37;&amp;width&amp;&#37;', '�R���e���c��', ''],
					['&#37;&amp;filename&amp;&#37;', '�t�@�C����', ''],
					['&#37;&amp;file_size&amp;&#37;', '�t�@�C���T�C�Y', ''],
					['&#37;&amp;file_size_au&amp;&#37;', 'AU�p�̃t�@�C���T�C�Y', ''],
				],
			},
			PAGE		=> {
				DESC		=> "�y�[�W�l�C�g�Ɋւ���ϐ�",
				ARRAYVALUE	=> [
					['&#37;&amp;pagenavi&amp;&#37;', '', ''],
					['&#37;&amp;NextPageUrl&amp;&#37;', '', ''],
					['&#37;&amp;PreviousPageUrl&amp;&#37;', '', ''],
				],
			},
			LISTING		=> {
				DESC		=> "���X�e�B���O�Ɋւ���ϐ�",
				ARRAYVALUE	=> [
					['&#37;&amp;LDL_URL&amp;&#37;', '', ''],
					['&#37;&amp;LIMAGE_SCRIPTDATABASE_URL&amp;&#37;', '', ''],
					['&#37;&amp;LMAINURL&amp;&#37;', '', ''],
					['&#37;&amp;tLDL_URL&amp;&#37;', '', ''],
					['&#37;&amp;tLIMAGE_SCRIPTDATABASE_URL&amp;&#37;', '', ''],
				],
			},
			STAGING		=> {
				DESC		=> "�X�e�[�W���O�E�e�X�g���Ɏg�p����ϐ�",
				ARRAYVALUE	=> [
					['&#37;&amp;KKReq_stg&amp;&#37;', '', ''],
					['&#37;&amp;KSReq_stg&amp;&#37;', '', ''],
					['&#37;&amp;cp_cd_stg&amp;&#37;', '', ''],
					['&#37;&amp;cp_srv_cd_stg&amp;&#37;', '', ''],
					['&#37;&amp;item_cd_stg&amp;&#37;', '', ''],
					['&#37;&amp;odr_sts_stg&amp;&#37;', '', ''],
				],
			},
			PROFILE		=> {
				DESC		=> "����̃v���t�B�[���ϐ�",
				ARRAYVALUE	=> [
		 			['&#37;&amp;MYPAGEURL&amp;&#37;', '', ''],
		 			['&#37;&amp;POINTNOW&amp;&#37;', '', ''],
		 			['&#37;&amp;MYPAGELISTURL&amp;&#37;', '', ''],
		 			['&#37;&amp;acd&amp;&#37;', '', ''],
		 			['&#37;&amp;family_name&amp;&#37;', '', ''],
		 			['&#37;&amp;first_name&amp;&#37;', '', ''],
		 			['&#37;&amp;family_name_kana&amp;&#37;', '', ''],
		 			['&#37;&amp;first_name_kana&amp;&#37;', '', ''],
		 			['&#37;&amp;mobilemailaddress&amp;&#37;', '', ''],
		 			['&#37;&amp;address&amp;&#37;', '', ''],
		 			['&#37;&amp;city&amp;&#37;', '', ''],
		 			['&#37;&amp;street&amp;&#37;', '', ''],
		 			['&#37;&amp;tel&amp;&#37;', '', ''],
		 			['&#37;&amp;year_of_birth&amp;&#37;', '', ''],
		 			['&#37;&amp;month_of_birth&amp;&#37;', '', ''],
		 			['&#37;&amp;date_of_birth&amp;&#37;', '', ''],
		 			['&#37;&amp;zip&amp;&#37;', '', ''],
				],
			},
		},
	},
	IFSTR	=> {
		DESC	=> '��������',
		VALUE	=> [
			['__IfDeco__', '�������f�R���̏ꍇ', ''],
			['__IfDecoTmplt__', '�������f�R���e���v���[�g�̏ꍇ', ''],
			['__IfERRORTOPPage__', '', ''],
			['__IfEmoji__', '', ''],
			['__IfExistsNewList__', '', ''],
			['__IfExistsNextPage__', '', ''],
			['__IfExistsPointHistory__', '', ''],
			['__IfExistsPreviousPage__', '', ''],
			['__IfExistsProduct__', '', ''],
			['__IfExistsPurchaseHistory__', '', ''],
			['__IfExistsTopRanking__', '', ''],
			['__IfFlash__', '', ''],
			['__IfINFOPage__', '', ''],
			['__IfKKREQPage__', '', ''],
			['__IfMODELLISTPage__', '', ''],
			['__IfMinusPoint__', '', ''],
			['__IfNotExistsNewList__', '', ''],
			['__IfNotExistsPointHistory__', '', ''],
			['__IfNotExistsProduct__', '', ''],
			['__IfNotExistsPurchaseHistory__', '', ''],
			['__IfNotExistsTopRanking__', '', ''],
			['__IfPDeco__', '', ''],
			['__IfRegistrationFailure__', '', ''],
			['__IfRegistrationSuccess__', '', ''],
			['__IfWithdrawFailure__', '', ''],
			['__IfWithdrawSuccess__', '', ''],
			['__IfdecoBR__', '', ''],
			['__IfdecotmpltBR__', '', ''],
			['__IfemojiBR__', '', ''],
		],
	},
	LOOPSTR	=> {
		DESC	=> '��������',
		VALUE	=> [
			['__LoopDecoCategoryList__', '', ''],
			['__LoopDecoTmpltCategoryList__', '', ''],
			['__LoopEmojiCategoryList__', '', ''],
			['__LoopFlashCategoryList__', '', ''],
			['__LoopNewList__', '�V���������s', ''],
			['__LoopPREFECTUREList__', '', ''],
			['__LoopPointHistoryList__', '', ''],
			['__LoopProductList__', '�R���e���c�̏������s', ''],
			['__LoopPurchaseHistoryList__', '', ''],
			['__LoopTopRankingList__', '�����L���O�̏������s', ''],
		],
	},

};
=cut

use Data::Dumper;
my $tabledata;
no strict ('refs');

=pod
while ( my($key, $value) = each(%{ $STRREF }) ) {
	$tabledata .= $q->Tr($q->td({-colspan=>"2"}, $key));
	map { $tabledata .= $q->Tr({-class=>"focus2"},$q->td({-style=>"font-size:13px; padding:10px 10px 0px 6px;"},[@{$_}])) } @$value;
}
=cut


print $q->header(-charset=>'shift_jis');
print $q->start_html(
			-title=>"�u������",
			-meta=>{
			      'Pragma'=>'no-cache'
			},
			-style=>{-src=>'/style.css',
					 -code=> "td.wide { padding: 8px 2px 2px 20px;}",
			},
			-script=>"",
);



#$STRREF->{SCALARSTR}

$tabledata .= $q->Tr($q->td({-colspan=>"4"},$STRREF->{SCALARSTR}->{DESC}))
			. $q->Tr($q->th(['�T�v', '�u������', '����', '�L�q��']));

#$STRREF->{SCALARSTR}->{VALUE}
#$STRREF->{SCALARSTR}->{VALUE}->{COMMON}

$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{SCALARSTR}->{VALUE}->{DEBUG_PAGE}->{ARRAYVALUE} }}, $STRREF->{SCALARSTR}->{VALUE}->{DEBUG_PAGE}->{DESC}));
foreach ( @{ $STRREF->{SCALARSTR}->{VALUE}->{DEBUG_PAGE}->{ARRAYVALUE} }) {
	$tabledata .= $q->Tr($q->td({-class=>"wide"},[@{$_}]));
}

$tabledata .= $q->Tr($q->td({-width=>"100", -rowspan=>2+$#{ $STRREF->{SCALARSTR}->{VALUE}->{COMMON}->{ARRAYVALUE} }}, $STRREF->{SCALARSTR}->{VALUE}->{COMMON}->{DESC}));
foreach (@{ $STRREF->{SCALARSTR}->{VALUE}->{COMMON}->{ARRAYVALUE} }) {
	$tabledata .= $q->Tr($q->td({-class=>"wide"},[@{$_}]));
}


$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{SCALARSTR}->{VALUE}->{NONMEMBER}->{ARRAYVALUE} }}, $STRREF->{SCALARSTR}->{VALUE}->{NONMEMBER}->{DESC}));
foreach ( @{ $STRREF->{SCALARSTR}->{VALUE}->{NONMEMBER}->{ARRAYVALUE} }) {
	$tabledata .= $q->Tr($q->td({-class=>"wide"},[@{$_}]));
}

$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{SCALARSTR}->{VALUE}->{MEMBER}->{ARRAYVALUE} }}, $STRREF->{SCALARSTR}->{VALUE}->{MEMBER}->{DESC}));
foreach ( @{ $STRREF->{SCALARSTR}->{VALUE}->{MEMBER}->{ARRAYVALUE} }) {
	$tabledata .= $q->Tr($q->td({-class=>"wide"},[@{$_}]));
}

=pod
$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{SCALARSTR}->{VALUE}->{PAGE}->{ARRAYVALUE} }}, $STRREF->{SCALARSTR}->{VALUE}->{PAGE}->{DESC}));
foreach ( @{ $STRREF->{SCALARSTR}->{VALUE}->{PAGE}->{ARRAYVALUE} }) {
	$tabledata .= $q->Tr($q->td([@{$_}]));

}

$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{SCALARSTR}->{VALUE}->{LISTING}->{ARRAYVALUE} }}, $STRREF->{SCALARSTR}->{VALUE}->{LISTING}->{DESC}));
foreach ( @{ $STRREF->{SCALARSTR}->{VALUE}->{LISTING}->{ARRAYVALUE} }) {
	$tabledata .= $q->Tr($q->td([@{$_}]));

}


$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{SCALARSTR}->{VALUE}->{STAGING}->{ARRAYVALUE} }}, $STRREF->{SCALARSTR}->{VALUE}->{STAGING}->{DESC}));
foreach ( @{ $STRREF->{SCALARSTR}->{VALUE}->{STAGING}->{ARRAYVALUE} }) {
	$tabledata .= $q->Tr($q->td([@{$_}]));

}


$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{SCALARSTR}->{VALUE}->{PROFILE}->{ARRAYVALUE} }}, $STRREF->{SCALARSTR}->{VALUE}->{PROFILE}->{DESC}));
foreach ( @{ $STRREF->{SCALARSTR}->{VALUE}->{PROFILE}->{ARRAYVALUE} }) {
	$tabledata .= $q->Tr($q->td([@{$_}]));

}



$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{IFSTR}->{VALUE} }},$STRREF->{IFSTR}->{DESC}));
foreach ( @{ $STRREF->{IFSTR}->{VALUE} }) {
	$tabledata .= $q->Tr($q->td([@{$_}]));

}


$tabledata .= $q->Tr($q->td({-rowspan=>2+$#{ $STRREF->{LOOPSTR}->{VALUE} }}, $STRREF->{LOOPSTR}->{DESC}));
foreach ( @{ $STRREF->{LOOPSTR}->{VALUE} } ) {
	$tabledata .= $q->Tr($q->td([@{$_}]));
}
=cut





print <<_HEADER_;
<div id="base">	
	<!-- �w�b�_�[ -->
	<div id="head">
		<h1>UPSTAIR �V�X�e���@�Ǘ��҉��</h1>
	</div>
		<!-- �^�C�g�� -->
		<div class="screen_title">
			<h2>�y�[�W���u��������</h2>
		</div>

_HEADER_


print $q->table({-rules=>"all", -align=>"center",-cellspacing=>"3", -cellpadding=>"3"},$tabledata);

=pod
print $q->table({-border=>"0", -width=>"100%", -class=>"", -rules=>"all", cellpadding=>"4", -cellspacing=>"1"},
		$q->Tr(
			$q->th({-colspan=>"2",-align=>"center"},"�u������������ꗗ")
		),
	  	$q->Tr(
	  		$q->th({-width=>"40%"},"�u����������"),
	  		$q->th("����")
	  	),
	  	$tabledata,
	  );
=cut

print <<_FOOTER_;
		</div>

	<!--</div> ---------------------------------------------------------------------------- -->

	<!-- �R�s�[���C�g -->
	<div id="copy">
		<div class="line"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
		(c)UP-STAIR 2009 All Rights Reserved
	</div>

</div><!-- ---------------------------------------------------------------------------- -->
_FOOTER_

print $q->end_html();


ModPerl::Util::exit();


__END__
