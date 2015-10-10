document.open();
document.write("<div id='menu_yoko'>");
document.write("<ul>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByYear'>年次集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByMonth'>月次集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiAccess'>アクセス集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiPageView'>PV集計</a></li>");
/*document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiRegMember'></a></li>");*/
document.write("<li><a href='/app.mpl?app=AppShukei;action=countMember'>会員数</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByACD'>広告コード別集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiDLContentsByMonth'>コンテンツDL集計</a></li>");
/*document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiAccessLog'>売り上げ集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiBannerByID'>バナー集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByAdMailNo'>配信メールID別集計</a></li>");
document.write("<li><a href='/app.mpl?app=AppShukei;action=shukeiByAdID'>広告コード別集計</a></li>");*/
document.write("</ul>");
document.write("</div>");
document.close();