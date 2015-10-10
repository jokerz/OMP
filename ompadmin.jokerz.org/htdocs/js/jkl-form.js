// ================================================================
//  jkl-form.js ---- JavaScript Kawasaki Library for Forms
//  Copyright 2002-2005 Kawasaki Yusuke <u-suke@kawa.net>
//  2005/04/06 - �ŏ��̃o�[�W����
//  2005/04/09 - 
//  2005/04/22 - selectOptionByIndex �ǉ�
//  ========================================================

/***********************************************************

      <script type="text/javascript" src="jkl-form.js" charset="Shift_JIS"></script>
      <script>
        form1 = new JKL.Form("formname");
      </script>
      <form name="formname" action="#" method="GET">
      </form>

 **********************************************************/

// �e�N���X

if ( typeof(JKL) == 'undefined' ) JKL = function() {};

// JKL.Form �R���X�g���N�^�̒�`

JKL.Form = function ( formid ) {
    this.formid     = formid;
    this.__formelem = null;
	return this;
}

//	�t�H�[��ID�̓��o��

JKL.Form.prototype.getFormElement = function () {
	if ( ! this.__formelem ) {
		this.__formelem = document.getElementById( this.formid );
		// �p��������
		if ( this.__formelem ) {
			this.submit = this.__formelem.submit;
		}
	}
	return this.__formelem;
}

JKL.Form.prototype.setFormElement = function ( foemelem ) {
	this.__formelem = formelem;
	this.formid = formelem.id;
}

//	�t�H�[���G�������g�̓��o��

JKL.Form.prototype.setFormId = function ( formid ) {
	this.formid = formid;
	this.__formelem = null;
}

JKL.Form.prototype.getFormId = function ( formid ) {
	return this.formid;
}

//	�t�H�[���G�������g�̃v���p�e�B�̕ύX

JKL.Form.prototype.setFormAttribute = function ( key, val ) {
	var felem = this.getFormElement();
	if ( ! felem ) return;
	felem[key] = val;
}

JKL.Form.prototype.getFormAttribute = function ( key ) {
	var felem = this.getFormElement();
	if ( ! felem ) return;
	return felem[key];
}

// 	�t�H�[���ϐ����Ŏw�肵���v�f�̎��o���i�K���z��ŕԂ��j

JKL.Form.prototype.getElementsArray = function ( keyname ) {
	var felem = this.getFormElement();
    var olist = new Array();
	if ( ! felem ) return olist;
    if ( ! felem.elements.length ) return olist;
    for( var i=0; i < felem.elements.length; i++ ) {    // ���ׂĂ̕ϐ��ɂ���
        if ( felem.elements[i].name != keyname ) continue;
		olist[olist.length] = felem.elements[i];
	}
	return olist;
}

//	�t�H�[���ϐ��l�̎��o��

JKL.Form.prototype.getValue = function ( keyname ) {
	var elist = this.getElementsArray( keyname );
    var olist = new Array();
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "radio" ||            // ���W�I�{�^��
             e.type == "checkbox" ) {        // �`�F�b�N�{�b�N�X
            if ( ! e.checked ) continue;
			olist[olist.length] = e.value;
        } else if ( e.type == "select-one" ||       // �v���_�E��
                    e.type == "select-multiple" ) { // �����I��
            for( var j=0; j < e.length; j++ ) {
                if ( ! e.options[j].selected ) continue;
				olist[olist.length] = e.options[j].value;
            }
        } else {
			olist[olist.length] = e.value;
		}
    }
    if ( olist.length < 1 ) return;             // ������΋�ŕԂ�
    if ( olist.length == 1 ) return olist[0];   // �P�Ȃ當����ŕԂ�
    return olist;                               // �����Ȃ�z��ŕԂ�
}

//  �t�H�[���ϐ��ɒl����������

JKL.Form.prototype.setValue = function ( keyname, keyval, keyarg ) {
	var elist = this.getElementsArray( keyname );
	if ( ! keyarg ) keyarg = "value";
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
		if ( e.type == "radio" ) {           // ���W�I�{�^��
            e.checked = ( e[keyarg] == keyval );
        } else if ( e.type == "checkbox" ) {        // �`�F�b�N�{�b�N�X
            if ( __isArray(keyval) ) {                  // �z��œ��́i�����Ή��j
                var c = 0;
                for( k=0; k<keyval.length; k++ ) {
                    if ( e[keyarg] != keyval[k] ) continue;
					c ++;
					break;
                }
				e.checked = ( c > 0 );
            } else {
                e.checked = ( e[keyarg] == keyval );
            }
        } else if ( e.type == "select-one" ) {      // �v���_�E��
            for( var j=0; j < e.length; j++ ) {
                e.options[j].selected = ( e.options[j][keyarg] == keyval );
            }
        } else if ( e.type == "select-multiple" ) { // �����I��
            for( var j=0; j < e.length; j++ ) {
                if ( __isArray(keyval) ) {              // �z��œ��́i�����Ή��j
                    var c = 0;
                    for( k=0; k<keyval.length; k++ ) {
                        if ( e.options[j][keyarg] != keyval[k] ) continue;
						c ++;
						break;
                    }
                    e.options[j].selected = ( c > 0 );
                } else {
                    e.options[j].selected = ( e.options[j][keyarg] == keyval );
                }
            }
        } else {
            e.value = keyval;
        }
    }
	//  �ϐ����z�񂩂ǂ����𔻒肷��
	function __isArray( x ){
	    return ((typeof(x) == "object") && (x.constructor == Array));
	}
}

//  �t�H�[���v�f�𖳌��E�L���Ƃ���i�ϐ����ƒl�Ŏw�肷��j

JKL.Form.prototype.disableByName = function ( keyname ) {
	return this.disableOrEnableElement( true, keyname );
}
JKL.Form.prototype.enableByName = function ( keyname ) {
	return this.disableOrEnableElement( false, keyname );
}
JKL.Form.prototype.disableByValue = function ( keyname, keyval ) {
	return this.disableOrEnableElement( true, keyname, "value", keyval );
}
JKL.Form.prototype.enableByValue = function ( keyname, keyval ) {
	return this.disableOrEnableElement( false, keyname, "value", keyval );
}
JKL.Form.prototype.disableByText = function ( keyname, keytxt ) {
	return this.disableOrEnableElement( true, keyname, "text", keytxt );
}
JKL.Form.prototype.enableByText = function ( keyname, keytxt ) {
	return this.disableOrEnableElement( false, keyname, "text", keytxt );
}
JKL.Form.prototype.disableByIndex = function ( keyname, keyidx ) {
	return this.disableOrEnableElement( true, keyname, "index", keyidx );
}
JKL.Form.prototype.enableByIndex = function ( keyname, keyidx ) {
	return this.disableOrEnableElement( false, keyname, "index", keyidx );
}

JKL.Form.prototype.disableOrEnableElement = function ( torf, keyname, chktype, chkval ) {
	var elist = this.getElementsArray( keyname );
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( ! chktype ) {                          // �l�����w��̏ꍇ�A
            e.disabled = torf;                     // �ϐ����̂������Ă��܂��B
        } else if ( e.type == "radio" ||            // ���W�I�{�^���܂���
                    e.type == "checkbox" ) {        // �`�F�b�N�{�b�N�X�̏ꍇ�A
            if ( e[chktype] != chkval ) continue;
            if ( torf ) e.checked = false;
            e.disabled = torf;                     // �I��s�ɂ���
        } else if ( e.type == "select-one" ||       // �v���_�E���܂���
                    e.type == "select-multiple" ) { // �����I���̏ꍇ�A
            for( var j=0; j < e.length; j++ ) {
                if ( e.options[j][chktype] != chkval ) continue;
                if ( torf ) e.options[j].selected = false;
                // �I��s�ɂȂ�i�O���[�\���ɂȂ�j�iOpera�ȊO�j
                if ( ! window.opera ) e.options[j].disabled = torf;
                // �I���\�̂܂܃O���[�\���ɂ���iIE�p�j
                e.options[j].style.color = torf ? "#999999" : "";
                // ���ڂ�������i�󔒗��ɂȂ�j
                // e.options[j].style.visibility = torf ? "hidden" : "visible";
                // ���ڂ�������i�����Ȃ�j
                // e.options[j].style.display = torf ? "none" : "list-item";
                // ���ڂ�������i�����ł��Ȃ��j
                // if ( torf ) e.options[j] = null;
            }
        }
    }
}

// <option> �v�f�őI������Ă���I������ID�����o���i�l�łȂ��đI�����ԍ��j

JKL.Form.prototype.getSelectedIndex = function( keyname ) {
	var elist = this.getElementsArray( keyname );
    var olist = new Array();
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "select-one" ||          // �v���_�E��
             e.type == "select-multiple" ) {
            for( var j=0; j < e.length; j++ ) {
                if ( ! e.options[j].selected ) continue;
				olist[olist.length] = j;
            }
        }
    }
    if ( olist.length < 1 ) return;             // ������΋�ŕԂ�
    if ( olist.length == 1 ) return olist[0];   // �P�Ȃ當����ŕԂ�
    return olist;                               // �����Ȃ�z��ŕԂ�
}

// <option> �v�f�őI������Ă���I�����̃e�L�X�g�����o��

JKL.Form.prototype.getSelectedText = function( keyname ) {
	var elist = this.getElementsArray( keyname );
    var olist = new Array();
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "select-one" ||          // �v���_�E��
             e.type == "select-multiple" ) {
            for( var j=0; j < e.length; j++ ) {
                if ( ! e.options[j].selected ) continue;
				olist[olist.length] = e.options[j].text;
            }
        }
    }
    if ( olist.length < 1 ) return;             // ������΋�ŕԂ�
    if ( olist.length == 1 ) return olist[0];   // �P�Ȃ當����ŕԂ�
    return olist;                               // �����Ȃ�z��ŕԂ�
}

//  �I�������N���A����i�S�Ă̑I�������폜�j

JKL.Form.prototype.deleteAllOptions = function( keyname ) {
	var elist = this.getElementsArray( keyname );
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "select-one" ||              // �v���_�E��
             e.type == "select-multiple" ) {        // �����I��
            e.options.length = 0;					// �I��������0�ɂ���
        }
    }
}

//  �I�� or ���I���̑I�������폜����

JKL.Form.prototype.deleteSelectedOptions = function( keyname, torf ) {
	if ( typeof(torf) != "boolean" ) torf = true;
	this.deleteOptions( keyname, "selected", torf );
}
JKL.Form.prototype.deleteOptionsByValue = function( keyname, keyval ) {
	this.deleteOptions( keyname, "value", keyval );
}
JKL.Form.prototype.deleteOptionsByText = function( keyname, keytxt ) {
	this.deleteOptions( keyname, "text", keytxt );
}
JKL.Form.prototype.deleteOptionsByIndex = function( keyname, keyidx ) {
	this.deleteOptions( keyname, "index", keyidx );
}

JKL.Form.prototype.deleteOptions = function( keyname, chktype, chkval ) {
	var elist = this.getElementsArray( keyname );
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "select-one" ||              // �v���_�E��
             e.type == "select-multiple" ) {        // �����I��
			for( var j=e.length-1; j >= 0; j-- ) {	// �O�̂��ߌ�납��m�F
				if ( e.options[j][chktype] != chkval ) continue;
				e.options[j] = null;				// �I�������폜����
			}
        }
    }
}

//  �I������ǉ�����

JKL.Form.prototype.addOption = function( keyname, keyval, keytxt ) {
	var elist = this.getElementsArray( keyname );
	var oindex;
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "select-one" ||              // �v���_�E��
             e.type == "select-multiple" ) {        // �����I��
            oindex = e.options.length;
            var opt1 = document.createElement('option'); 
            opt1.value = keyval; 
            opt1.text = ( typeof keytxt != "undefined" ) ? keytxt : keyval; 
            e.options[oindex] = opt1;     // �ǉ�����
        }
    }
    return oindex;                        // �ǉ����� OptionIndex
}

//	selectAllOptions ---- �`�F�b�N�{�b�N�X�܂���select-multiple�̒l�𓝈�

JKL.Form.prototype.selectAllOptions = function( keyname, torf ) {
	var elist = this.getElementsArray( keyname );
    if ( typeof(torf) != 'boolean' ) {
		// �V�l�����w��̏ꍇ�́A�f�t�H���g�͑S��OFF�ɂ���
        torf = false;                       
		// �S�Ă̒l���`�F�b�N���āA1�ł����I��������ΑS��ON�ɂ���
		for( var i=0; i<elist.length; i++ ) {
			var e = elist[i];
            if ( e.type == "checkbox" ) {
                if ( ! e.checked ) {                    // 1�ł����I��
                    torf = true;                        // �S��ON�ɂ���
                    break;
                }
            } else if ( e.type == "select-multiple" ) {
                for( var j=0; j < e.length; j++ ) {
                    if ( ! e.options[j].selected ) {    // 1�ł����I��
                        torf = true;                    // �S��ON�ɂ���
                        break;
                    }
                }
            }
        }
    }
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "checkbox" ) {
            e.checked = torf;
        } else if ( e.type == "select-multiple" ) {
            for( var j=0; j < e.length; j++ ) {
                e.options[j].selected = torf;       // ���ꂷ��
            }
        }
    }
    return torf;        // ������e
}

//	selectOptions ---- �`�F�b�N�{�b�N�X�܂���select-multiple��I��

JKL.Form.prototype.selectOptionsByValue = function( keyname, keyval, torf ) {
	this.selectOptions( keyname, "value", keyval );
}
JKL.Form.prototype.selectOptionsByText = function( keyname, keytxt, torf ) {
	this.selectOptions( keyname, "text", keytxt );
}
JKL.Form.prototype.selectOptionsByIndex = function( keyname, keyidx, torf ) {
	this.selectOptions( keyname, "index", keyidx );
}

JKL.Form.prototype.selectOptions = function( keyname, chktype, chkval, torf ) {
    if ( typeof(torf) == 'undefined' ) {
        torf = true;                 // ���w��̏ꍇ�́AON�ɂ���
    } else if ( typeof(torf) != 'boolean' ) {
        torf = !! torf;
	}
	var elist = this.getElementsArray( keyname );
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "select-one" ||              // �v���_�E��
             e.type == "select-multiple" ) {        // �����I��
			for( var j=e.length-1; j >= 0; j-- ) {	// �O�̂��ߌ�납��m�F
				if ( e.options[j][chktype] != chkval ) continue;
				e.options[j].selected = torf;		// �I������
			}
        }
    }
}

// <option> ���̑I�����Ă���l���㉺�ړ�����

JKL.Form.prototype.upDownSelectedOptions = function( keyname, updown ) {
	var elist = this.getElementsArray( keyname );
	var oindex;
	for( var i=0; i<elist.length; i++ ) {
		var e = elist[i];
        if ( e.type == "select-one" ||          // �v���_�E��
             e.type == "select-multiple" ) {
            if ( e.length < 1 ) continue;       // �I������1�ȉ�
            if ( updown < 0 ) {                 // ������ɏグ��
                for( var j=1; j < e.length; j++ ) {
                    if ( ! e.options[j].selected ) continue;
                    if ( e.options[j-1].selected ) continue;
                    __swap(e,j,j-1);
                }
            } else {                            // �������ɉ�����
                for( var j=e.length-2; j >= 0; j-- ) {
                    if ( ! e.options[j].selected ) continue;
                    if ( e.options[j+1].selected ) continue;
                    __swap(e,j,j+1);
                }
            }
        }
    }

    // �������ł́A�X�^�C���Ƃ����R�s�[����Ȃ��̂ŁA�ǂ��ɂ��������c
    function __swap(sel1,a,b) {
        var t = e.options[a].text;
        var v = e.options[a].value;
        var s = e.options[a].selected;
        e.options[a].text     = e.options[b].text;
        e.options[a].value    = e.options[b].value;
        e.options[a].selected = e.options[b].selected;
        e.options[b].text     = t;
        e.options[b].value    = v;
        e.options[b].selected = s;
    }
}

// ================================================================
