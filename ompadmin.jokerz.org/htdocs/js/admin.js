


function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

function MM_goToURL() { //v3.0
  var i, args=MM_goToURL.arguments; document.MM_returnValue = false;
  for (i=0; i<(args.length-1); i+=2) eval(args[i]+".location='"+args[i+1]+"'");
}

function MM_changeProp(objName,x,theProp,theValue) { //v6.0
  var obj = MM_findObj(objName);
  if (obj && (theProp.indexOf("style.")==-1 || obj.style)){
    if (theValue == true || theValue == false)
      eval("obj."+theProp+"="+theValue);
    else eval("obj."+theProp+"='"+theValue+"'");
  }
}


function MM_openBrWindow(theURL,winName,features) { //v2.0
  window.open(theURL,winName,features);
}

function Browser() {

  var ua, s, i;

  this.isIE    = false;  // Internet Explorer
  this.isNS    = false;  // Netscape
  this.version = null;

  ua = navigator.userAgent;

  s = "MSIE";
  if ((i = ua.indexOf(s)) >= 0) {
    this.isIE = true;
    this.version = parseFloat(ua.substr(i + s.length));
    return;
  }

  s = "Netscape6/";
  if ((i = ua.indexOf(s)) >= 0) {
    this.isNS = true;
    this.version = parseFloat(ua.substr(i + s.length));
    return;
  }

  // Treat any other "Gecko" browser as NS 6.1.

  s = "Safari";
  if ((i = ua.indexOf(s)) >= 0) {
    this.isSA = true;
    this.version = 1.0;
    return;
  }

  s = "Gecko";
  if ((i = ua.indexOf(s)) >= 0) {
    this.isNS = true;
    this.version = 6.1;
    return;
  }

}
var browser = new Browser();

function addColor(obj,color){
	
	//var tag='span style="color:'+color+'"';
	var startTag = '<span style="color:#'+color+'">';
	var endTag   = '</span>';
	//IE
	if (document.selection) {
		obj.focus();
		var str = document.selection.createRange().text;
		if(!str) {
			return;
		}
		document.selection.createRange().text = startTag + str + endTag;
		return;
	}
	//Mozilla
	else if ((obj.selectionEnd - obj.selectionStart) >0) {
		var startPos = obj.selectionStart;
		var endPos   = obj.selectionEnd;
		
		
		obj.value = obj.value.substring(0, startPos)
				  + startTag
				  + obj.value.substring(startPos, endPos)
				  + endTag
				  + obj.value.substring(endPos, obj.value.length);
		return;
	}
	//Other
	else {
		obj.value += startTag + endTag;
	}
}
function addTag(obj, tag) {
	
	var startTag = '<' + tag + '>';
	var endTag   = '</' + tag + '>';
	//IE
	if (document.selection) {
		obj.focus();
		var str = document.selection.createRange().text;
		if(!str) {
			return;
		}
		document.selection.createRange().text = '<' + tag + '>' + str + '</' + tag + '>';
		return;
	}
	//Mozilla
	else if ((obj.selectionEnd - obj.selectionStart) >0) {
		var startPos = obj.selectionStart;
		var endPos   = obj.selectionEnd;
		
		
		obj.value = obj.value.substring(0, startPos)
				  + startTag
				  + obj.value.substring(startPos, endPos)
				  + endTag
				  + obj.value.substring(endPos, obj.value.length);
		return;
	}
	//Other
	else {
		obj.value += startTag + endTag;
	}
}


function changeFontsize(obj, tag) {
	
	var startTag = '<span style=\"font-size:' + tag + '\;\">';
	var endTag   = '</span>';
	//IE
	if (document.selection) {
		obj.focus();
		var str = document.selection.createRange().text;
		if(!str) {
			return;
		}
		document.selection.createRange().text = startTag + str + endTag;
		return;
	}
	//Mozilla
	else if ((obj.selectionEnd - obj.selectionStart) >0) {
		var startPos = obj.selectionStart;
		var endPos   = obj.selectionEnd;
		
		
		obj.value = obj.value.substring(0, startPos)
				  + startTag
				  + obj.value.substring(startPos, endPos)
				  + endTag
				  + obj.value.substring(endPos, obj.value.length);
		return;
	}
	//Other
	else {
		obj.value += startTag + endTag;
	}
}


function addLink(obj) {
	var url = prompt('リンクするサイトのURLを入力してください。', 'http://');
	if (url == null) {
		return;
	}
	
	var startTag = '<a href="../../js/%27%20+%20url%20+%20%27" target="_blank">';
	var endTag   = '</a>';
	
	//IE
	if (document.selection) {
		obj.focus();
		var str = document.selection.createRange().text;
		if(!str) {
			return;
		}
		document.selection.createRange().text = startTag + str + endTag;
		return;
	}
	//Mozilla
	else if ((obj.selectionEnd - obj.selectionStart) >0) {
		var startPos = obj.selectionStart;
		var endPos   = obj.selectionEnd;
		
		
		obj.value = obj.value.substring(0, startPos)
				  + startTag
				  + obj.value.substring(startPos, endPos)
				  + endTag
				  + obj.value.substring(endPos, obj.value.length);
		return;
	}
	//Other
	else {
		obj.value += startTag + endTag;
	}
	
}

//表示・非表示切り替え
function switchObj(id){
	var obj = document.getElementById(id);
	if(obj.style.display=='none'){
		obj.style.display='block';
	}else{
		obj.style.display='none';
	}

}

//textarea伸縮
function increaseNotesHeight(thisTextarea, add) {
	if (thisTextarea) {
		newHeight = parseInt(thisTextarea.style.height) + add;
		thisTextarea.style.height = newHeight + "px";
	}
	if (document.getElementById('notes_height')) {
		document.getElementById('notes_height').value = newHeight;
	}
}

function decreaseNotesHeight(thisTextarea, subtract) {
	if (thisTextarea) {
		if ((parseInt(thisTextarea.style.height) - subtract) > 30) {
			newHeight = parseInt(thisTextarea.style.height) - subtract;
			thisTextarea.style.height = newHeight + "px";
		}
		else {
			newHeight = 30;
			thisTextarea.style.height = "30px";
		}			
	}
	if (document.getElementById('notes_height')) {
		document.getElementById('notes_height').value = newHeight;
	}
}

//div伸縮
function increaseNotesHeight1(id, add) {
	if (id) {
		newHeight = parseInt(document.getElementById(id).style.height) + add;
		document.getElementById(id).style.height = newHeight + "px";
	}
}

function decreaseNotesHeight1(id, subtract) {
	if (id) {
		if ((parseInt(document.getElementById(id).style.height) - subtract) > 40) {
			newHeight = parseInt(document.getElementById(id).style.height) - subtract;
			document.getElementById(id).style.height = newHeight + "px";
		}
		else {
			newHeight = 40;
			document.getElementById(id).style.height = "40px";
		}			
	}
}

//表示・非表示 イメージ切り替え
function formShowHide(id, image) {
    var disp = document.getElementById(id).style.display;
    if(disp == "block") {
        document.getElementById(id).style.display = "none";
        document.getElementById(image).src = "common/js/images/open.gif";
    }
    else {
        document.getElementById(id).style.display = "block";
        document.getElementById(image).src = "common/js/images/close.gif";
    }
    return false;
}

//表示・非表示 イメージ切り替えタグ用
function formShowHideTag(id, image) {
    var disp = document.getElementById(id).style.display;
    if(disp == "none") {
		document.getElementById(id).style.display = "block";
        document.getElementById(image).src = "common/js/images/close_tag.gif";
    }
    else {
        document.getElementById(id).style.display = "none";
        document.getElementById(image).src = "common/js/images/open_tag.gif";
    }
    return false;
}

//SELECT要素を隠す
function hideselect(){

	var myTRLen = document.getElementsByTagName('select').length;
	var i;
	for(i=0;i<myTRLen;i++){
		
		var mySelect = document.getElementsByTagName('select')[i] ;
		mySelect.style.visibility = 'hidden';
	}
}

//絞り込みテキスト用
function changetext() { 
 var search_tab = document.getElementById("search_tab"); 
 var flag = (search_tab.className != "before"); 
 search_tab.firstChild.nodeValue = 
   (flag ? "絞り込み" : "閉じる"); 
 search_tab.className = (flag ? "before" : "after"); 
}


//オーバーレイ全画面
function changeHeight(id){
var obj=document.all && document.all(id) || document.getElementById && document.getElementById(id);
var winHeight=document.documentElement.clientHeight || document.body.clientHeight;
var bodyHeight=document.documentElement.scrollHeight || document.body.scrollHeight;
if(winHeight < bodyHeight){
obj.style.height = document.documentElement.scrollHeight + "px" || document.body.scrollHeight+"px";
}
else{
obj.style.height = (document.documentElement.clientHeight || document.body.clientHeight) + "px";
}
}


//画面サイズ取得
function getWindowClientSize(){
var result={"width":0,"height":0};

if(window.self&&self.innerWidth){
result.width=document.body.clientWidth || document.documentElement.clientHeight;
result.height=document.body.clientHeight || document.documentElement.clientHeight;
}else if(document.documentElement && document.documentElement.clientHeight){
result.width=document.body.clientWidth ||document.documentElement.clientHeight;
result.height=document.body.clientHeight || document.documentElement.clientHeight;
}else{
result.width=document.body.clientWidth || document.documentElement.clientHeight;
result.height=document.body.clientHeight || document.documentElement.clientHeight;
}
return result;
}


/*function changeHeight(){
var sd=document.body.clientHeight;
layer.style.height=sd+"px";

}*/

//画面中央に寄せる
function setCenter(id)
{
var myId = document.getElementById(id);
var iH = myId.offsetHeight;    //画像の縦幅
var wH = document.documentElement.clientHeight || document.body.clientHeight;	//　ウィンドウの縦幅
var cy = (wH - iH) / 2;
var oDiv = document.getElementById('oDiv');
var scrollTop  = document.body.scrollTop  || document.documentElement.scrollTop;
myId.style.top = (scrollTop+cy+"px");
}


/**
 * resize.js 0.3 970811
 * by gary smith
 * js component for "reloading page onResize"
 */

if(!window.saveInnerWidth) {
  window.onresize = resizeIt;
  window.saveInnerWidth = window.innerWidth;
  window.saveInnerHeight = window.innerHeight;
}

function resizeIt() {
    if (saveInnerWidth < window.innerWidth || 
        saveInnerWidth > window.innerWidth || 
        saveInnerHeight > window.innerHeight || 
        saveInnerHeight < window.innerHeight ) 
    {
        window.history.go(0);
    }
}
