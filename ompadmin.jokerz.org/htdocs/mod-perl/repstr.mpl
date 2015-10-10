#******************************************************
# @desc		置き換え文字列管理
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
        DESC    => '変数  赤文字部分は対応するID等を記述',
        VALUE    => {
            COMMON        => {
                DESC        => "サイト全体で使用するグローバル変数(直書きは絶対にしないこと)",
                ARRAYVALUE    => [
['&#37;&amp;BENCH_TIME&amp;&#37;', '処理時間計測　デバッグや最適化、不具合調査のときに使用', ''],
['&#37;&amp;DUMP&amp;&#37;', 'ダンプデータ', ''],
['&#37;&amp;ERROR_MSG&amp;&#37;', '処理エラーなどのユーザーへ対してのエラーメッセージ', ''],
['&#37;&amp;SITE_NAME&amp;&#37;', 'サイト名', ''],
['&#37;&amp;MAINURL&amp;&#37;', '非会員トップURL(キャリア毎に必要なパラメータが付与される)', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;', '会員トップURL(キャリア毎に必要なパラメータが付与される)', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;', '会員情報ページURL', ''],
['&#37;&amp;CARTURL&amp;&#37;', '商品リスト・購買処理URL', ''],
['&#37;&amp;IMAGE_SCRIPTDATABASE_NAME&amp;&#37;', '商品画像表示プログラムURL', ''],
['&#37;&amp;SITEIMAGE_SCRIPTDATABASE_URL&amp;&#37;', 'サイト内画像表示プログラムURL', ''],
['&#37;&amp;FLASH_SCRIPT_URL&amp;&#37;', 'FLASHデータ処理・表示プログラムURL', ''],
['&#37;&amp;DECOTMPLT_SCRIPT_URL&amp;&#37;', 'デコメテンプレートデータ処理・表示プログラムURL', ''],
['&#37;&amp;DECOICON_SCRIPT_URL&amp;&#37;', 'デコメ・絵文字データ処理・表示プログラムURL', ''],
                ],
            },
            NONMEMBER            => {
                DESC        => "非会員ページ用変数",
                ARRAYVALUE    => [
['/a/detail/o/product/pr/p=<font style="color:red;">[商品ID]</font>/%&MAINURL&amp;&#37;', '商品詳細', ''],
['/a/list/o/product_by_c/pr/c=<font style="color:red;">[カテゴリID]</font>/%&MAINURL&amp;&#37;', 'カテゴリ別商品リスト', ''],
['/a/list/o/product_by_sbc/pr/sbc=<font style="color:red;">[中カテゴリID]</font>/%&MAINURL&amp;&#37;', '中カテゴリ別商品リスト', ''],
['/a/list/o/product_by_smc/pr/smc=<font style="color:red;">[小カテゴリID]</font>/%&MAINURL&amp;&#37;', '小カテゴリ別商品リスト', ''],
['/a/list/o/all_product/pr/off=0/%&MAINURL&amp;&#37;', '全商品リスト', ''],
['/a/list/o/new_product/pr/off=0/%&MAINURL&amp;&#37;', '新着商品リスト', ''],

                ],
            },
            MEMBER          => {
                DESC        => "会員ページ用変数",
                ARRAYVALUE    => [
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=detail&o=product&p=<font style="color:red;">[商品ID]</font>', '商品詳細', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=product_by_c&c=<font style="color:red;">[カテゴリID]</font>', 'カテゴリ別商品リスト', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=product_by_sbc&sbc=<font style="color:red;">[中カテゴリID]</font>', '中カテゴリ別商品リスト', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=product_by_smc&smc=<font style="color:red;">[小カテゴリID]</font>', '小カテゴリ別商品リスト', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=all_product', '全商品リスト', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=new_product', '新着商品リスト', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=withdraw&o=member', '退会ページリンクURL', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=view&o=profile', '会員情報ページリンクURL', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=edit&o=profile', '会員情報編集ページリンクURL', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=list&o=purchase_history', '購買履歴ページリンクURL', ''],
['&#37;&amp;ACCOUNTURL&amp;&#37;a=list&o=point_history', 'ポイント取得・消費履歴ページリンクURL', ''],
['&#37;&amp;CARTURL&amp;&#37;a=list&o=confirm_product', '商品交換リスト・交換ページリンクURL', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=list&o=media_by_mc&mc=<font style="color:red;">[広告カテゴリID]</font>', '広告の各カテゴリごとURL', ''],
['&#37;&amp;PTBKURL&amp;&#37;ad_id=<font style="color:red;">[広告ID]</font>', '広告リンク', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=dl&o=flash&p=<font style="color:red;">[商品ID]</font>', 'フラッシュのダウンロードリンク', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=dl&o=decotmplt&p=<font style="color:red;">[商品ID]</font>', 'デコメテンプレートのダウンロードリンク', ''],
['&#37;&amp;MEMBERMAINURL&amp;&#37;a=dl&o=emoji&p=<font style="color:red;">[商品ID]</font>', '絵文字のダウンロードリンク', ''],
['__If.HOOK.MYPAGEPOINTBACK__', 'マイページ表示に登録したポイント広告の表示ブロック。この変数で開始して終了（ペアで使用）',''],
['__LoopMyPagePointBackMediaList__', 'マイページ表示に登録したポイント広告のループ処理を実行。この変数で開始して終了（ペアで使用）',''],
['&#37;&amp;ad_name&amp;&#37; &#37;&amp;point&amp;&#37; &#37;&amp;ad_16words_text&amp;&#37; &#37;&amp;PPTBKURL&amp;&#37;', 'LoopMyPagePointBackMediaList内で使用できる変数', ''],
['__IfNickNameIsEmpty__', '会員ページトップにてニックネーム未登録会員に対して表示するブロック。この変数で開始して終了（ペアで使用）',''],
['__IfNickNameIsNotEmpty__', '会員ページトップにてニックネーム登録済み会員に対して表示するブロック。この変数で開始して終了（ペアで使用）',''],
                ],
            },
            DEBUG_PAGE            => {
                DESC        => "運営・デザイン作成ページ確認",
                ARRAYVALUE    => [
['[ページURL]/pr/<font style="color:red;">debug=1&tf=[テンプレID]</font>/&#37;&amp;MAINURL&amp;&#37;', 'ページURLのpr/の後にdebug=1&tf=[<font style="color:red;">テンプレID</font>]を追加してください。', 'http://1mp.1mp.jp/a/detail/o/product/pr/<font style="color:red;">debug=1&tf=55&</font>p=14/run.html?guid=ON'],
['&#37;&amp;MEMBERMAINURL&amp;&#37;[ページURL]<font style="color:red;">&debug=1&tf=[テンプレID]</font>', 'URLの後に2つのパラメータを追加することで表示 <font style="color:red;">&debug=1&tf=[テンプレID]</font> ※端末認証を実施します', 'http://m.1mp.jp/?m_run.mpl?guid=ON&a=detail_product&p=37<font style="color:red;">&debug=1&tf=55</font>'],
['/a/view/o/help/pr/pg=<font style="color:red;">help_news</font>/&#37;&amp;MAINURL&amp;&#37;', '非会員用追加ページの表示<br />テンプレート作成時のページコード名が<font style="color:red;">view_help_xxxyyy</font>となるようにしてください。', 'http://1mp.1mp.jp/a/view/o/help/pr/pg=help_news/run.html?guid=ON'],
['&#37;&amp;MAINURL&amp;&#37a=view&o=help&pg=<font style="color:red;">help_news</font>', '会員用追加ページの表示<br />テンプレート作成時のページコード名が<font style="color:red;">view_help_xxxyyy</font>となるようにしてください。', 'http://m.1mp.jp/m_run.mpl?guid=ON&a=view&o=help&pg=help_news'],
                ],
            },
        },
    },
};
=pod
my $STRREF = {
	SCALARSTR	=> {
		DESC	=> '変数',
		VALUE	=> {
			REG			=> {
				DESC		=> "公式サイト会員登録・解約に関する変数(キャリアサーバーとの認証・通信)コチラに関する値も絶対に直書きはしないこと",
				ARRAYVALUE	=> [
					['&#37;&amp;Index&amp;&#37;', '', ''],
					['&#37;&amp;KKReq&amp;&#37;', '公式サイトサーバーに会員解約要求実行', ''],
					['&#37;&amp;KSReq&amp;&#37;', '公式サイトサーバーに会員登録要求実行', ''],
					['&#37;&amp;cp_cd&amp;&#37;', 'コンテンツプロバイダーコード', ''],
					['&#37;&amp;cp_srv_cd&amp;&#37;', 'コンテンツプロバイダーサービスコード', ''],
					['&#37;&amp;ok_url&amp;&#37;', '処理成功時の戻りURL', ''],
					['&#37;&amp;ng_url&amp;&#37;', '処理失敗時の戻りURL', ''],
					['&#37;&amp;item_cd&amp;&#37;', 'コンテンツのアイテムコード', ''],
					['&#37;&amp;odr_sts&amp;&#37;', '', ''],
				],
			},
			CONTENTS	=> {
				DESC		=> "サイトコンテンツに関する変数",
				ARRAYVALUE	=> [
					['&#37;&amp;encryptid&amp;&#37;', '', ''],
					['&#37;&amp;category_name&amp;&#37;', '', ''],
					['&#37;&amp;subcategory_name&amp;&#37;', '', ''],
					['&#37;&amp;tranking_rank&amp;&#37;', '', ''],
					['&#37;&amp;title&amp;&#37;', 'コンテンツタイトル', ''],
					['&#37;&amp;height&amp;&#37;', 'コンテンツ高さ', ''],
					['&#37;&amp;width&amp;&#37;', 'コンテンツ幅', ''],
					['&#37;&amp;filename&amp;&#37;', 'ファイル名', ''],
					['&#37;&amp;file_size&amp;&#37;', 'ファイルサイズ', ''],
					['&#37;&amp;file_size_au&amp;&#37;', 'AU用のファイルサイズ', ''],
				],
			},
			PAGE		=> {
				DESC		=> "ページネイトに関する変数",
				ARRAYVALUE	=> [
					['&#37;&amp;pagenavi&amp;&#37;', '', ''],
					['&#37;&amp;NextPageUrl&amp;&#37;', '', ''],
					['&#37;&amp;PreviousPageUrl&amp;&#37;', '', ''],
				],
			},
			LISTING		=> {
				DESC		=> "リスティングに関する変数",
				ARRAYVALUE	=> [
					['&#37;&amp;LDL_URL&amp;&#37;', '', ''],
					['&#37;&amp;LIMAGE_SCRIPTDATABASE_URL&amp;&#37;', '', ''],
					['&#37;&amp;LMAINURL&amp;&#37;', '', ''],
					['&#37;&amp;tLDL_URL&amp;&#37;', '', ''],
					['&#37;&amp;tLIMAGE_SCRIPTDATABASE_URL&amp;&#37;', '', ''],
				],
			},
			STAGING		=> {
				DESC		=> "ステージング・テスト時に使用する変数",
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
				DESC		=> "会員のプロフィール変数",
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
		DESC	=> '条件分岐',
		VALUE	=> [
			['__IfDeco__', '条件がデコメの場合', ''],
			['__IfDecoTmplt__', '条件がデコメテンプレートの場合', ''],
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
		DESC	=> '条件分岐',
		VALUE	=> [
			['__LoopDecoCategoryList__', '', ''],
			['__LoopDecoTmpltCategoryList__', '', ''],
			['__LoopEmojiCategoryList__', '', ''],
			['__LoopFlashCategoryList__', '', ''],
			['__LoopNewList__', '新着処理実行', ''],
			['__LoopPREFECTUREList__', '', ''],
			['__LoopPointHistoryList__', '', ''],
			['__LoopProductList__', 'コンテンツの処理実行', ''],
			['__LoopPurchaseHistoryList__', '', ''],
			['__LoopTopRankingList__', 'ランキングの処理実行', ''],
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
			-title=>"置換文字",
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
			. $q->Tr($q->th(['概要', '置換文字', '説明', '記述例']));

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
	<!-- ヘッダー -->
	<div id="head">
		<h1>UPSTAIR システム　管理者画面</h1>
	</div>
		<!-- タイトル -->
		<div class="screen_title">
			<h2>ページ内置換文字列</h2>
		</div>

_HEADER_


print $q->table({-rules=>"all", -align=>"center",-cellspacing=>"3", -cellpadding=>"3"},$tabledata);

=pod
print $q->table({-border=>"0", -width=>"100%", -class=>"", -rules=>"all", cellpadding=>"4", -cellspacing=>"1"},
		$q->Tr(
			$q->th({-colspan=>"2",-align=>"center"},"置き換え文字列一覧")
		),
	  	$q->Tr(
	  		$q->th({-width=>"40%"},"置き換え文字"),
	  		$q->th("説明")
	  	),
	  	$tabledata,
	  );
=cut

print <<_FOOTER_;
		</div>

	<!--</div> ---------------------------------------------------------------------------- -->

	<!-- コピーライト -->
	<div id="copy">
		<div class="line"><img src="/images/spacer.gif" alt="" width="1" height="1" /></div>
		(c)UP-STAIR 2009 All Rights Reserved
	</div>

</div><!-- ---------------------------------------------------------------------------- -->
_FOOTER_

print $q->end_html();


ModPerl::Util::exit();


__END__
