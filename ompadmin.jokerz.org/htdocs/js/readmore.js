var saveHeight = new Object();
var showing = new Object();

function toggleSlide(itemid) {
	if ( showing[itemid] )	{
		slideMenuUp(itemid);
		showing[itemid] = false;
	}
	else {
		slideMenuDown(itemid);
		showing[itemid] = true;
	}
	return false;
}

function slideMenuUp(itemid) {
	var menu = $(itemid);
	menu.style.overflow = "hidden";
	new Effect.Size( menu, null, 1, 120, 8, {complete:function() { $(menu).style.visibility = "hidden"; }});
}

function slideMenuDown(itemid) {
	var menu = $(itemid);
	menu.style.visibility = "visible";
	new Effect.Size( menu, null, saveHeight[itemid], 120, 8, {complete:function() { $(menu).style.overflow = "visible"; }} );
}

function initSlide(mapping) {
	for (className in mapping) {
		initSlide2(className, mapping[className]);
	}
}

function initSlide2(className, toggleTitle) {
	var entries = document.getElementsByClassName(className);
	for (var i = 0; i < entries.length; i++) {
		var e = entries[i];
		e.id = className + i;
		showing[e.id] = false;
		saveHeight[e.id] = e.offsetHeight;
		e.style.visibility = 'hidden';
		e.style.overflow = 'hidden';
		e.style.height = '1px';
		
		var a = document.createElement("a");
		a.innerHTML = toggleTitle;
		a.href = "javascript:void(0)";
		a.slidethis = e.id;
		a.onclick = function() { return toggleSlide(this.slidethis); };

		e.parentNode.insertBefore(a, e);
	}
}