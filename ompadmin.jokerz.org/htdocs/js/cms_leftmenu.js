document.open();

document.write("<div id='side_d'>");
document.write("<ul>");
document.write("<li><a href='/app.mpl?action=logout'><img src='/images/logout.gif' width='68' height='19' border='0' /></a></li>");
document.write("</ul>");
document.write("</div>");
document.write("<div id='side_d'>");
document.write("<h3>サイト</h3>");
document.write("<ul>");
document.write("<li><a href='/app.mpl?app=AppTmplt;attr=0'>ページ管理</a></li>");
document.write("<li><a href='/app.mpl?app=AppImage'>画像管理</a></li>");
document.write("<li><a href='/app.mpl?app=AppMember'>会員管理</a></li>");
document.write("<li><a href='/app.mpl?app=AppMember;action=pointRanking'>会員ポイントランキング</a></li>");
document.write("<li><a href='/app.mpl?app=AppOrder'>受注管理</a></li>");
document.write("</ul>");
document.write("</div>");

document.write("<div id='side_d'>");
document.write("<h3>集計管理</h3>");
document.write("<ul>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByYear'>月次集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByMonth'>日次集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiPageViewByMonth'>PV期間集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiProductView'>商品期間集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiMediaClick'>代理店・広告集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiAffiliate'>アフィリ集計</a></li>");
/*
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiAccess'>アクセス集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiPageView'>PV集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=countMember'>会員数</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiDLContentsByMonth'>コンテンツDL集計</a></li>");
*/
document.write("</ul>");
document.write("</div>");

document.write("<div id='side_d'>");
document.write("<h3>メディア管理</h3>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=mediaTopMenu'>代理店・広告一覧</a></li>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=registAgent_Category'>代理店・カテゴリ登録</a></li>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=registMedia'>広告登録</a></li>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=identifyUserByMediaSessionID'>広告不正管理</a></li>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=viewAffiliateList'>アフィリ一覧</a></li>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=registAffiliate'>アフィリ登録</a></li>");
/*
document.write("<li><a href='/app.mpl?app=AppMedia;action=viewLinkBannerList'>バナー一覧</a></li>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=registLinkBanner'>バナー登録</a></li>");
*/

/*
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByACD'>メディア別集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=viewLinkBannerList'>外部リンク・バナー一覧</a></li>");
document.write("<li><a href='/app.mpl?app=AppMedia;action=registLinkBanner'>外部リンク・バナー登録</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiMedia;adv=1;'>外部リンクバナー集計</a></li>");
*/
document.write("</ul>");
document.write("</div>");




document.write("<div id='side_d'>");
document.write("<h3>広告管理</h3>");
document.write("<ul>");
document.write("<li><a href='/mod-perl/rptad.mpl?page=1'>メール広告一覧</a></li>");
document.write("<li><a href='/mod-perl/editad.mpl?page=1;id=0'>メール広告登録</a></li>");
document.write("<li><a href='/mod-perl/addadmail.mpl?clear=1'>メール配信</a></li>");
document.write("<li><a href='/mod-perl/rptadmail.mpl?page=1'>メール送信履歴</a></li>");
/*
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByAdID'>メール広告別集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByAdMailNo'>メールID別集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppBanner;action=defaultBannerMenu'>サイト内RTバナー一覧</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByBannerID'>サイト内RTバナー集計</a></li>");
*/
document.write("</ul>");
document.write("</div>");

document.write("<div id='side_d'>");
document.write("<h3>コンテンツ・商品管理</h3>");
document.write("<ul>");
document.write("<li><a href='/app.mpl?app=AppProduct'>商品登録状況</a></li>");
document.write("<li><a href='/app.mpl?app=AppProduct;action=searchProduct;'>商品検索</a></li>");
document.write("<li><a href='/app.mpl?app=AppProduct;action=registProduct'>商品登録</a></li>");
document.write("<li><a href='/app.mpl?app=AppProduct;action=viewCategoryList'>カテゴリ一覧</a></li>");
document.write("<li><a href='/app.mpl?app=AppProduct;action=registCategory'>カテゴリ登録</a></li>");
document.write("<li><a href='/app.mpl?app=AppProduct;action=viewSubCategoryList'>中カテゴリ一覧</a></li>");
document.write("<li><a href='/app.mpl?app=AppProduct;action=registSubCategory'>中カテゴリ登録</a></li>");
document.write("<li><a href='/app.mpl?app=AppProduct;action=viewSmallCategoryList'>小カテゴリ一覧</a></li>");
document.write("<li><a href='/app.mpl?app=AppProduct;action=registSmallCategory'>小カテゴリ登録</a></li>");
document.write("</ul>");
document.write("</div>");

document.write("<div id='side_d'>");
document.write("<h3>環境設定・情報</h3>");
document.write("<ul>");
document.write("<li><a href='/app.mpl?action=rebuildCache'>キャッシュ再構築</a></li>");
document.write("<li><a href='/app.mpl?app=AppGeneralENV;action=viewConfigration;of=mails'>メール設定情報</a></li>");
document.write("<li><a href='/app.mpl?app=AppGeneralENV;action=viewConfigration;of=server'>サーバー環境</a></li>");
document.write("</ul>");
document.write("</div>");

document.close();
