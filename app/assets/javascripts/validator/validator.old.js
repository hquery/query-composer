var hDebugger = {
	f: {},
	kd: false,
	md: false,
	eres: {},
	rres: {},
	patients: [],
	init: function(){
		$(window).keyup(hDebugger.tabup).mouseup(hDebugger.clickup);
		$(window).error(function(){debugger; return true;});
	},
	tab: function(e) {
		var el = e.target ? e.target : e.srcElement;
		key = e.keyCode ? e.keyCode : e.which ? e.which : e.charCode;
		if (key==9) {
			if (!hDebugger.kd){
				hDebugger.kd = true;
				if (document.selection) {
					el.focus();
					sel = document.selection.createRange();
					sel.text = "\t";
				} else if (el.selectionStart || el.selectionStart == '0') {
					var startPos = el.selectionStart;
					var endPos = el.selectionEnd;
					var restoreTop = el.scrollTop;
					$(el).val($(el).val().substring(0, startPos) + "\t" + $(el).val().substring(endPos, el.value.length));
					el.selectionStart = startPos + 1;
					el.selectionEnd = startPos + 1;
					el.scrollTop = restoreTop;
				} else {
					el.value += "\t";
				}
			}
			e.stopPropagation();
			e.preventDefault();
			return false;
		}
	},

	dfunction: function(g, src){
		if (!src){
			src = "query_" + g;
		}
		this.f[g] = [src, false];
		$("#" + src)
			.keyup(
				('function(e){hDebugger.debug("' + g + '");}').toFunction()
			)
			.keydown(
				this.tab
			);
		$("#" + src).parent().parent().append(
			$(document.createElement("td"))
				.addClass("err")
				.attr("id", "f_" + g + "_d")
				
				.css("display", "inline-block")
				.css("height", "380px")
				.css("width", "380px")
				.css("overflow", "auto")
				.css("vertical-align", "top")
				.css("font-family", "sans-serif")
		);
		this.debug(g);
	},
	clear: function(e){
		$(e).empty();
	},
	err: function(err, dest){
		$(dest).append($(document.createElement("p"))
			.text(err)
			
			.css("padding", "5px")
			.css("margin", "0px 10px 5px 10px")
			.css("background-color", "#FFAAAA")
			.css("word-wrap", "break-word")
		);
	},
	ok: function(){
		if (function(){
			for (var i in hDebugger.f){
				if (!hDebugger.f[i][1]) return false;
			}
			return true;
		}()){
			$("#debug").removeAttr("disabled").mousedown(
				function(){
					if (!hDebugger.md) hDebugger.execute($("#query_map"), $("#query_reduce"));
					hDebugger.md = true;
				}
			);
		} else {
			$("#debug").attr("disabled", "disabled");
		}
	},
	debug: function(g, src, dest){
		if (!src) src = $("#query_" + g);
		if (!dest) dest = $("#f_" + g + "_d");
		this.clear(dest);
		try{
			eval($(src).val());
			if (typeof eval(g) != "function"){
				throw "Syntax Error";
			}
			this.f[g][1] = true;
			this.ok();
		} catch (e){
			$("#debug").attr("disabled", "disabled");
			this.err(g + " function is invalid: " + e.message, dest);
		}
	},
	tabup: function(){
		hDebugger.kd = false;
	},
	clickup: function(){
		hDebugger.md = false;
	},
	emit: function(k, v){
		if (hDebugger.eres[k]) hDebugger.eres[k].push(v);
		else hDebugger.eres[k] = [v];
	},
	execute: function(m, r){
		$(this).val("Processing...");
		this.eres = {};
		this.rres = {};
		emit = this.emit;
		this.map = $(m).val().toFunction();
		for (var i = 0; i < this.patients.length; i++) {
		  this.map(this.patients[i]);
		}
		this.reduce = $(r).val().toFunction();
		for (var i in this.eres){
			//document.write(i + " -- " + this.rres[i] + " -- " + this.eres[i] + "<br />");
			this.rres[i] = this.reduce (i, this.eres[i]);
		}		
		var output = "";
		for (var i in this.rres) output += i + " => " + this.rres[i] + "<br />";

		var reswin = $(document.createElement("div"))
			.css("z-index", 500)
			.css("background-color", "#666666")
			.css("position", "absolute")
			.css("top", 0)
			.css("left", 0)
			.css("text-align", "center")
			.height($(document).height())
			.width($(document).width())
			.click(function(){$(this).remove();})
			.append(
				$(document.createElement("div"))
					.css("z-index", 600)
					.css("margin", "80px auto 0px auto")
					.css("background-color", "#FFFFFF")
					.css("text-align", "left")
					.css("display", "inline-block")
					.css("padding", "20px")
					.html(output)
			)
		$(document.body).append(reswin)
		$(reswin).height($(document).height())
		$(document).scrollTop(0);
		$("#debug").removeAttr("disabled");
		$("#debug").val("Debug");
	}
};
/*f.__proto__.length = function(){
	c: 0;
	for (var i in this) c++;
	return c;
}*/
String.prototype.toFunction = function(){
	return eval("(function(){ return "+ this + ";})()");
}

$(document).ready(function(){
	hDebugger.init();
	hDebugger.dfunction("map");
	hDebugger.dfunction("reduce");
	//debugger;
});