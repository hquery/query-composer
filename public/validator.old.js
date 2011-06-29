var f = {};
/*f.__proto__.length = function(){
	var c = 0;
	for (var i in this) c++;
	return c;
}*/
String.prototype.toFunction = function(){
	return eval("(function(){ return "+ this + ";})()");
}

function tab(e) {
	var el = e.target ? e.target : e.srcElement;
	key = e.keyCode ? e.keyCode : e.which ? e.which : e.charCode;
	if (key==9) {
		if (document.selection) {
			el.focus();
			sel = document.selection.createRange();
			sel.text = "\t";
		} else if (el.selectionStart || el.selectionStart == '0') {
			var startPos = el.selectionStart;
			var endPos = el.selectionEnd;
			restoreTop = el.scrollTop;
			el.value = el.value.substring(0, startPos) + "\t" + el.value.substring(endPos, el.value.length);
			el.selectionStart = startPos + "\t".length;
			el.selectionEnd = startPos + "\t".length;
			if (restoreTop>0) {
				el.scrollTop = restoreTop;
			}
		} else {
			el.value += "\t";
		}
		e.preventDefault();
		return false;
	}
}

function dfunction(g, src){
	if (!src){
		src = "query_" + g;
	}
	f[g] = [src, false];
	$(document.body).append(
		$(document.createElement("div"))
			.addClass("fbox")
			.append(
				$(document.createElement("p"))
					.text(g + " Function"),
				$(document.createElement("textarea"))
					.addClass("source")
					.attr("id", "f_" + g + "_s")
					.val(window.opener.$("#" + src).val())
					.keyup(
						('function(e){debug("' + g + '");}').toFunction()
					)
					.keydown(
						tab
					),
				$(document.createElement("span"))
					.addClass("err")
					.attr("id", "f_" + g + "_d")
			)
	);
	debug(g);
}
function setStatus(m, c){
	$("#status").text(m);
	$("#status").css("background-color", (c?c:"#AAFFAA"));
}
function clear(e){
	$(e).empty();
}
function err(err, dest){
	setStatus("There are one or more errors below", "FFAAAA");
	$(dest).append($(document.createElement("p")).text(err));
}
function ok(){
	if (function(){
		for (var i in f){
			if (!f[i][1]) return false;
		}
		return true;
	}()){
		setStatus ("No Errors");
		$("#status").append($(document.createElement("input")).attr("type", "button").val("Save").click(
			function(){
				for (var i in f){
					window.opener.$("#" + f[i][0]).val($("#f_" + i + "_s").val());
				}
				window.close();
			}
		));
	}
}
function debug(g, src, dest){
	if (!src) src = $("#f_" + g + "_s");
	if (!dest) dest = $("#f_" + g + "_d");
	clear(dest);
	try{
		eval($(src).val());
		if (typeof eval(g) != "function"){
			//err(g + " is not a function", dest);
			throw "Syntax Error";
		}
		f[g][1] = true;
		ok();
	} catch (e){
		err(g + " function is invalid: " + e.message, dest);
	}
}

if (!window.opener){
	alert("Must be run from hQuery Composer");
	window.close();
}

$(document).ready(function(){
	dfunction("map");
	dfunction("reduce");
	//debugger;
});