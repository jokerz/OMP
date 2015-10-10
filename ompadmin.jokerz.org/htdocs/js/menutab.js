// -----------------------------------------------------------------------------------
//
//	Menu Tab
//	2008/04/02
//
var selectedtablink=""
var tcischecked=false

function handlelink(aobject){
  selectedtablink=aobject.href
  tcischecked=(document.tabcontrol && document.tabcontrol.tabcheck.checked)? true : false
  if (document.getElementById && !tcischecked){
    var tabobj=document.getElementById("tablist")
    var tabobjlinks=tabobj.getElementsByTagName("A")
    for (i=0; i<tabobjlinks.length; i++)
      tabobjlinks[i].className=""
    aobject.className="current"
    document.getElementById("tabiframe").src=selectedtablink
    return false
  }
  else
    return true
}

function handleview(){
  tcischecked=document.tabcontrol.tabcheck.checked
  if (document.getElementById && tcischecked){
    if (selectedtablink!="")
      window.location=selectedtablink
  }
}