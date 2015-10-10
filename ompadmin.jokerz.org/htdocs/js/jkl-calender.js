//  ========================================================
//  jkl-calender.js ---- ポップアップカレンダー表示クラス
//  Copyright 2005 Kawasaki Yusuke <u-suke@kawa.net>
//  2005/04/06 - 最初のバージョン
//  2005/04/10 - 外部スタイルシートを使用しない、JKL.Opacity はオプション
//  ========================================================

/***********************************************************
//  （サンプル）ポップアップするカレンダー

  <html>
    <head>
      <script type="text/javascript" src="jkl-opacity.js" charset="Shift_JIS"></script>
      <script type="text/javascript" src="jkl-calender.js" charset="Shift_JIS"></script>
      <script>
        var cal1;
        cal1 = new JKL.Calender("calid","formname","colname");
        if ( ! cal1.getFormValue() ) cal1.setFormValue();
      </script>
    </head>
    <body>
      <form name="formname" action="">
        <input type="text" name="colname" onClick="cal1.write();" onChange="cal1.getFormValue(); cal1.hide();"><br>
        <div id="cal1"></div>
      </form>
    </body>
  </html>

 **********************************************************/

// 親クラス

if ( typeof(JKL) == 'undefined' ) JKL = function() {};

// JKL.Calender コンストラクタの定義

JKL.Calender = function ( eid, fid, valname ) {
    this.eid = eid;
    this.formid = fid;
    this.valname = valname;
    this.__dispelem = null;  // カレンダー表示欄エレメント
    this.__textelem = null;  // テキスト入力欄エレメント
    this.__opaciobj = null;  // JKL.Opacity オブジェクト
    this.date = new Date();
    this.style = new JKL.Calender.Style();
    return this;
}

// JKL.Calender.Style

JKL.Calender.Style = function() {

    this.frame_width    = "150px";
    this.frame_color    = "#009900";       // フレーム 色
    this.font_size      = "12px";
    this.day_bgcolor    = "#F0F0F0";       // カレンダーの背景色
    this.month_color        = "#000000";
    this.month_hover_color  = "#009900";
    this.month_hover_bgcolor = "#FFFFCC";
    this.weekday_color      = "#009900";       // 月曜～金曜の色
    this.saturday_color     = "#0040D0";       // 土曜の色
    this.sunday_color       = "#D00000";       // 日曜の色
    this.others_color       = "#999999";       // 他の月の色
    this.day_hover_bgcolor  = "#FFCCCC";

    return this;
}
JKL.Calender.Style.prototype.set = function(key,val) { this[key] = val; }
JKL.Calender.Style.prototype.get = function(key) { return this[key]; }
JKL.Calender.prototype.setStyle = function(key,val) { this.style.set(key,val); };
JKL.Calender.prototype.getStyle = function(key) { return this.style.get(key); };

// 透明度設定のオブジェクトを返す

JKL.Calender.prototype.getOpacityObject = function () {
    if ( this.__opaciobj ) return this.__opaciobj;
    var cal = this.getCalenderElement();
    if ( ! JKL.Opacity ) return;
    this.__opaciobj = new JKL.Opacity( cal );
    return this.__opaciobj;
}

// カレンダー表示欄のエレメントを返す

JKL.Calender.prototype.getCalenderElement = function () {
    if ( this.__dispelem ) return this.__dispelem;
    this.__dispelem = document.getElementById( this.eid )
    return this.__dispelem;
}

// テキスト入力欄のエレメントを返す

JKL.Calender.prototype.getFormElement = function () {
    if ( this.__textelem ) return this.__textelem;
    var frmelms = document.getElementById( this.formid );
    if ( ! frmelms ) return;
    for( var i=0; i < frmelms.elements.length; i++ ) {
        if ( frmelms.elements[i].name == this.valname ) {
            this.__textelem = frmelms.elements[i];
        }
    }
    return this.__textelem;
}

// オブジェクトに日付を記憶する（YYYY/MM/DD形式で指定する）

JKL.Calender.prototype.setDateYMD = function (ymd) {
    var splt = ymd.split( "/" );
    if ( splt[0] > 0 && 
         splt[1] >= 0 && splt[1] <= 11 && 
         splt[2] >= 1 && splt[2] <= 31 ) {
        this.date.setYear( splt[0] );
        this.date.setMonth( splt[1]-1 );
        this.date.setDate( splt[2] );
    } else {
        ymd = "";
    }
    return ymd;
}

// オブジェクトから日付を取り出す（YYYY/MM/DD形式で返る）
// 引数に Date オブジェクトの指定があれば、
// オブジェクトは無視して、引数の日付を使用する（単なるfprint機能）

JKL.Calender.prototype.getDateYMD = function ( dd ) {
    if ( ! dd ) dd = this.date;
    var mm = "" + (dd.getMonth()+1);
    var aa = "" + dd.getDate();
    if ( mm.length == 1 ) mm = "" + "0" + mm;
    if ( aa.length == 1 ) aa = "" + "0" + aa;
    return dd.getFullYear() + "/" + mm + "/" + aa;
}

// テキスト入力欄の値を返す（ついでにオブジェクトも更新する）

JKL.Calender.prototype.getFormValue = function () {
    var form1 = this.getFormElement();
    if ( ! form1 ) return "";
    var date1 = this.setDateYMD( form1.value );
    return date1;
}

// フォーム入力欄に指定した値を書き込む

JKL.Calender.prototype.setFormValue = function (ymd) {
    if ( ! ymd ) ymd = this.getDateYMD();   // 無指定時はオブジェクトから？
    var form1 = this.getFormElement();
    if ( form1 ) form1.value = ymd;
}

//  カレンダー表示欄を表示する

JKL.Calender.prototype.show = function () {
    this.getCalenderElement().style.display = "";
}

//  カレンダー表示欄を即座に隠す

JKL.Calender.prototype.hide = function () {
    this.getCalenderElement().style.display = "none";
}

//  カレンダー表示欄をフェードアウトする

JKL.Calender.prototype.fadeOut = function (s) {
    if ( JKL.Opacity ) {
        this.getOpacityObject().fadeOut(s);
    } else {
        this.hide();
    }
}

// 月単位で移動する

JKL.Calender.prototype.moveMonth = function ( mon ) {
    // 前へ移動
    for( ; mon<0; mon++ ) {
        this.date.setDate(1);   // 毎月1日の1日前は必ず前の月
        this.date.setTime( this.date.getTime() - (24*3600*1000) );
    }
    // 後へ移動
    for( ; mon>0; mon-- ) {
        this.date.setDate(1);   // 毎月1日の32日後は必ず次の月
        this.date.setTime( this.date.getTime() + (24*3600*1000)*32 );
    }
    this.date.setDate(1);       // 当月の1日に戻す
    this.write();               // 描画する
}

// カレンダーを描画する

JKL.Calender.prototype.write = function () {

    var date = new Date();
    date.setTime( this.date.getTime() );
    var year = date.getFullYear();          // 指定年
    var mon  = date.getMonth();             // 指定月
    var today = date.getDate();             // 指定日

    // 直前の月曜日まで戻す
    date.setDate(1);                        // 1日に戻す
    var wday = date.getDay();               // 曜日 日曜(0)～土曜(6)
    if ( wday != 1 ) {
        if ( wday == 0 ) wday = 7;
        date.setTime( date.getTime() - (24*3600*1000)*(wday-1) );
    }

    // 最大で7日×6週間＝42日分のループ
    var list = new Array();
    for( var i=0; i<42; i++ ) {
        var tmp = new Date();
        tmp.setTime( date.getTime() + (24*3600*1000)*i );
        if ( i && i%7==0 && tmp.getMonth() != mon ) break;
        list[list.length] = tmp;
    }

    // スタイルシートを生成する
    var month_table_style = 'width: 100%; ';
    month_table_style += 'background: '+this.style.frame_color+'; ';
    month_table_style += 'border: 1px solid '+this.style.frame_color+';';

    var week_table_style = 'width: 100%; ';
    week_table_style += 'background: '+this.style.day_bgcolor+'; ';
    week_table_style += 'border-left: 1px solid '+this.style.frame_color+'; ';
    week_table_style += 'border-right: 1px solid '+this.style.frame_color+'; ';

    var days_table_style = 'width: 100%; ';
    days_table_style += 'background: '+this.style.day_bgcolor+'; ';
    days_table_style += 'border: 1px solid '+this.style.frame_color+'; ';

    var month_td_style = "";
    month_td_style += 'font-size: '+this.style.font_size+'; ';
    month_td_style += 'color: '+this.style.month_color+'; ';
    month_td_style += 'padding: 4px 0px 2px 0px; ';
    month_td_style += 'text-align: center; ';
    month_td_style += 'font-weight: bold;';

    var week_td_style = "";
    week_td_style += 'font-size: '+this.style.font_size+'; ';
    week_td_style += 'padding: 2px 0px 2px 0px; ';
    week_td_style += 'font-weight: bold;';
    week_td_style += 'text-align: center;';

    var days_td_style = "";
    days_td_style += 'font-size: '+this.style.font_size+'; ';
    days_td_style += 'padding: 1px; ';
    days_td_style += 'text-align: center; ';
    days_td_style += 'font-weight: bold;';

    // HTMLソースを生成する
    var src1 = "";
    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+month_table_style+'"><tr>';
    src1 += '<td id="__'+this.eid+'_btn_prev" title="前の月へ" style="'+month_td_style+'">≪</td>';
    src1 += '<td style="'+month_td_style+'">'+(year)+'</span>年 '+(mon+1)+'</span>月</td>';
    src1 += '<td id="__'+this.eid+'_btn_next" title="次の月へ" style="'+month_td_style+'">≫</td>';
    src1 += "</tr></table>\n";
    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+week_table_style+'"><tr>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">月</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">火</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">水</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">木</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">金</td>';
    src1 += '<td style="color: '+this.style.saturday_color+'; '+week_td_style+'">土</td>';
    src1 += '<td style="color: '+this.style.sunday_color+'; '+week_td_style+'">日</td>';
    src1 += "</tr></table>\n";

    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+days_table_style+'">';
    for ( var i=0; i<list.length; i++ ) {
        var dd = list[i];
        var ww = dd.getDay();
        if ( ww == 1 ) {
            src1 += "<tr>";                 // 月曜日の前
        }
        var cc;
        if ( mon != dd.getMonth() ) {
            cc = this.style.others_color;                  // 指定月以外
        } else {
            switch ( ww ) {
                case 0:
                    cc = this.style.sunday_color;
                    break;
                case 6:
                    cc = this.style.saturday_color;
                    break;
                default:
                    cc = this.style.weekday_color;
                    break;
            }
        }
        var ss = this.getDateYMD(dd);
        src1 += '<td style="color: '+cc+'; '+days_td_style+'" title='+ss+' id="__'+this.eid+'_td_'+ss+'">'+dd.getDate()+'</td>';
        if ( ww == 7 ) {
            src1 += "</tr>\n";                // 土曜日の後ろ
        }
    }
    src1 += "</table>\n";

    // カレンダーを書き換える
    var cal1 = this.getCalenderElement();
    if ( ! cal1 ) return;
    cal1.style.width = this.style.frame_width;
    cal1.style.position = "absolute";
    cal1.innerHTML = src1;

    // ソースを表示する
    // var calsource = document.getElementById( "calsource" );
    // calsource.innerHTML = src1.replace(/\&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");

    // イベントを登録する
    var copy = this;

    // 前の月へ
    var tdprev = document.getElementById( "__"+this.eid+"_btn_prev" );
    tdprev.onclick = function () {
        copy.moveMonth( -1 );
    }
    tdprev.onmouseover = function () {
        // this.style.textDecoration = "underline";
        this.style.color = copy.style.month_hover_color;
        this.style.background = copy.style.month_hover_bgcolor;
    }
    tdprev.onmouseout = function () {
        // this.style.textDecoration = "none";
        this.style.color = copy.style.month_color;
        this.style.background = copy.style.frame_color;
    }
    // 次の月へ
    var tdnext = document.getElementById( "__"+this.eid+"_btn_next" );
    tdnext.onclick = function () {
        copy.moveMonth( +1 );
    }
    tdnext.onmouseover = function () {
        // this.style.textDecoration = "underline";
        this.style.color = copy.style.month_hover_color;
        this.style.background = copy.style.month_hover_bgcolor;
    }
    tdnext.onmouseout = function () {
        // this.style.textDecoration = "none";
        this.style.color = copy.style.month_color;
        this.style.background = copy.style.frame_color;
    }

    // セルごとのイベントを登録する
    for ( var i=0; i<list.length; i++ ) {
        var dd = list[i];
        if ( mon != dd.getMonth() ) continue;   // 今月のみ設定する
        var ss = this.getDateYMD(dd);
        var cc = document.getElementById( "__"+this.eid+"_td_"+ss );
        if ( ! cc ) continue;
        cc.onmouseover = function () {
            // this.style.textDecoration = "underline";
            this.style.background = copy.style.day_hover_bgcolor;
        }
        cc.onmouseout = function () {
            // this.style.textDecoration = "none";
            this.style.background = copy.style.day_bgcolor;
        }
        // 本当は ss とかの値を使いたいが、使えないようだ。
        cc.onclick = function () {
            var thisday = this.id.substr(this.id.length-10);
            copy.setFormValue( thisday );
            copy.fadeOut( 1.0 );
        }
    }

    // 表示する
    this.show();
}
