//  ========================================================
//  jkl-calender.js ---- �|�b�v�A�b�v�J�����_�[�\���N���X
//  Copyright 2005 Kawasaki Yusuke <u-suke@kawa.net>
//  2005/04/06 - �ŏ��̃o�[�W����
//  2005/04/10 - �O���X�^�C���V�[�g���g�p���Ȃ��AJKL.Opacity �̓I�v�V����
//  ========================================================

/***********************************************************
//  �i�T���v���j�|�b�v�A�b�v����J�����_�[

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

// �e�N���X

if ( typeof(JKL) == 'undefined' ) JKL = function() {};

// JKL.Calender �R���X�g���N�^�̒�`

JKL.Calender = function ( eid, fid, valname ) {
    this.eid = eid;
    this.formid = fid;
    this.valname = valname;
    this.__dispelem = null;  // �J�����_�[�\�����G�������g
    this.__textelem = null;  // �e�L�X�g���͗��G�������g
    this.__opaciobj = null;  // JKL.Opacity �I�u�W�F�N�g
    this.date = new Date();
    this.style = new JKL.Calender.Style();
    return this;
}

// JKL.Calender.Style

JKL.Calender.Style = function() {

    this.frame_width    = "150px";
    this.frame_color    = "#009900";       // �t���[�� �F
    this.font_size      = "12px";
    this.day_bgcolor    = "#F0F0F0";       // �J�����_�[�̔w�i�F
    this.month_color        = "#000000";
    this.month_hover_color  = "#009900";
    this.month_hover_bgcolor = "#FFFFCC";
    this.weekday_color      = "#009900";       // ���j�`���j�̐F
    this.saturday_color     = "#0040D0";       // �y�j�̐F
    this.sunday_color       = "#D00000";       // ���j�̐F
    this.others_color       = "#999999";       // ���̌��̐F
    this.day_hover_bgcolor  = "#FFCCCC";

    return this;
}
JKL.Calender.Style.prototype.set = function(key,val) { this[key] = val; }
JKL.Calender.Style.prototype.get = function(key) { return this[key]; }
JKL.Calender.prototype.setStyle = function(key,val) { this.style.set(key,val); };
JKL.Calender.prototype.getStyle = function(key) { return this.style.get(key); };

// �����x�ݒ�̃I�u�W�F�N�g��Ԃ�

JKL.Calender.prototype.getOpacityObject = function () {
    if ( this.__opaciobj ) return this.__opaciobj;
    var cal = this.getCalenderElement();
    if ( ! JKL.Opacity ) return;
    this.__opaciobj = new JKL.Opacity( cal );
    return this.__opaciobj;
}

// �J�����_�[�\�����̃G�������g��Ԃ�

JKL.Calender.prototype.getCalenderElement = function () {
    if ( this.__dispelem ) return this.__dispelem;
    this.__dispelem = document.getElementById( this.eid )
    return this.__dispelem;
}

// �e�L�X�g���͗��̃G�������g��Ԃ�

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

// �I�u�W�F�N�g�ɓ��t���L������iYYYY/MM/DD�`���Ŏw�肷��j

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

// �I�u�W�F�N�g������t�����o���iYYYY/MM/DD�`���ŕԂ�j
// ������ Date �I�u�W�F�N�g�̎w�肪����΁A
// �I�u�W�F�N�g�͖������āA�����̓��t���g�p����i�P�Ȃ�fprint�@�\�j

JKL.Calender.prototype.getDateYMD = function ( dd ) {
    if ( ! dd ) dd = this.date;
    var mm = "" + (dd.getMonth()+1);
    var aa = "" + dd.getDate();
    if ( mm.length == 1 ) mm = "" + "0" + mm;
    if ( aa.length == 1 ) aa = "" + "0" + aa;
    return dd.getFullYear() + "/" + mm + "/" + aa;
}

// �e�L�X�g���͗��̒l��Ԃ��i���łɃI�u�W�F�N�g���X�V����j

JKL.Calender.prototype.getFormValue = function () {
    var form1 = this.getFormElement();
    if ( ! form1 ) return "";
    var date1 = this.setDateYMD( form1.value );
    return date1;
}

// �t�H�[�����͗��Ɏw�肵���l����������

JKL.Calender.prototype.setFormValue = function (ymd) {
    if ( ! ymd ) ymd = this.getDateYMD();   // ���w�莞�̓I�u�W�F�N�g����H
    var form1 = this.getFormElement();
    if ( form1 ) form1.value = ymd;
}

//  �J�����_�[�\������\������

JKL.Calender.prototype.show = function () {
    this.getCalenderElement().style.display = "";
}

//  �J�����_�[�\�����𑦍��ɉB��

JKL.Calender.prototype.hide = function () {
    this.getCalenderElement().style.display = "none";
}

//  �J�����_�[�\�������t�F�[�h�A�E�g����

JKL.Calender.prototype.fadeOut = function (s) {
    if ( JKL.Opacity ) {
        this.getOpacityObject().fadeOut(s);
    } else {
        this.hide();
    }
}

// ���P�ʂňړ�����

JKL.Calender.prototype.moveMonth = function ( mon ) {
    // �O�ֈړ�
    for( ; mon<0; mon++ ) {
        this.date.setDate(1);   // ����1����1���O�͕K���O�̌�
        this.date.setTime( this.date.getTime() - (24*3600*1000) );
    }
    // ��ֈړ�
    for( ; mon>0; mon-- ) {
        this.date.setDate(1);   // ����1����32����͕K�����̌�
        this.date.setTime( this.date.getTime() + (24*3600*1000)*32 );
    }
    this.date.setDate(1);       // ������1���ɖ߂�
    this.write();               // �`�悷��
}

// �J�����_�[��`�悷��

JKL.Calender.prototype.write = function () {

    var date = new Date();
    date.setTime( this.date.getTime() );
    var year = date.getFullYear();          // �w��N
    var mon  = date.getMonth();             // �w�茎
    var today = date.getDate();             // �w���

    // ���O�̌��j���܂Ŗ߂�
    date.setDate(1);                        // 1���ɖ߂�
    var wday = date.getDay();               // �j�� ���j(0)�`�y�j(6)
    if ( wday != 1 ) {
        if ( wday == 0 ) wday = 7;
        date.setTime( date.getTime() - (24*3600*1000)*(wday-1) );
    }

    // �ő��7���~6�T�ԁ�42�����̃��[�v
    var list = new Array();
    for( var i=0; i<42; i++ ) {
        var tmp = new Date();
        tmp.setTime( date.getTime() + (24*3600*1000)*i );
        if ( i && i%7==0 && tmp.getMonth() != mon ) break;
        list[list.length] = tmp;
    }

    // �X�^�C���V�[�g�𐶐�����
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

    // HTML�\�[�X�𐶐�����
    var src1 = "";
    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+month_table_style+'"><tr>';
    src1 += '<td id="__'+this.eid+'_btn_prev" title="�O�̌���" style="'+month_td_style+'">��</td>';
    src1 += '<td style="'+month_td_style+'">'+(year)+'</span>�N '+(mon+1)+'</span>��</td>';
    src1 += '<td id="__'+this.eid+'_btn_next" title="���̌���" style="'+month_td_style+'">��</td>';
    src1 += "</tr></table>\n";
    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+week_table_style+'"><tr>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">��</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">��</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">��</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">��</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">��</td>';
    src1 += '<td style="color: '+this.style.saturday_color+'; '+week_td_style+'">�y</td>';
    src1 += '<td style="color: '+this.style.sunday_color+'; '+week_td_style+'">��</td>';
    src1 += "</tr></table>\n";

    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+days_table_style+'">';
    for ( var i=0; i<list.length; i++ ) {
        var dd = list[i];
        var ww = dd.getDay();
        if ( ww == 1 ) {
            src1 += "<tr>";                 // ���j���̑O
        }
        var cc;
        if ( mon != dd.getMonth() ) {
            cc = this.style.others_color;                  // �w�茎�ȊO
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
            src1 += "</tr>\n";                // �y�j���̌��
        }
    }
    src1 += "</table>\n";

    // �J�����_�[������������
    var cal1 = this.getCalenderElement();
    if ( ! cal1 ) return;
    cal1.style.width = this.style.frame_width;
    cal1.style.position = "absolute";
    cal1.innerHTML = src1;

    // �\�[�X��\������
    // var calsource = document.getElementById( "calsource" );
    // calsource.innerHTML = src1.replace(/\&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");

    // �C�x���g��o�^����
    var copy = this;

    // �O�̌���
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
    // ���̌���
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

    // �Z�����Ƃ̃C�x���g��o�^����
    for ( var i=0; i<list.length; i++ ) {
        var dd = list[i];
        if ( mon != dd.getMonth() ) continue;   // �����̂ݐݒ肷��
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
        // �{���� ss �Ƃ��̒l���g���������A�g���Ȃ��悤���B
        cc.onclick = function () {
            var thisday = this.id.substr(this.id.length-10);
            copy.setFormValue( thisday );
            copy.fadeOut( 1.0 );
        }
    }

    // �\������
    this.show();
}
