//= require patient
String.prototype.toFunction = function(){
	return eval("(function(){ return "+ this + ";})()");
}
var hDebugger = {
	f: {},
	kd: false,
	md: false,
	eres: {},
	rres: {},
	//records: [],
	patients: [],
	//jsonsql: null,
	rset: [],
	init: function(){
		/*for (var i in this.records) this.patients[i] = new hQuery.Patient(this.records[i]);
		var res = this.jsonsql.query("SELECT * FROM json", this.records);
		var op = "";
		for (var i in res){
			op += "{";
			for (var j in res[i]){
				op += j + " => " + res[i][j] + " ";
			}
			op += "}";
		}
		console.log(op);*/
		hDebugger.rset = hDebugger.patients;
		$(window).keyup(hDebugger.tabup).mouseup(hDebugger.clickup);
		//$(window).error(function(){debugger; return true;});
		this.dfunction("map");
		this.dfunction("reduce");
		
		$("#records").click(
			function(){
				$(document.body).append(
					$(document.createElement("div"))
						.css("left", $(document).width() / 2 - 400)
						.addClass("querywindow")
						.append(
							$(document.createElement("div"))
								.addClass("querywindow-header")
								.append(
									$(document.createElement("span"))
										.text("Records"),
									$(document.createElement("span"))
										.addClass("querywindow-header-exit")
										.text("X")
										.click(
											function(){
												$(this).parent().parent().remove();
											}
										)
								),
							$(document.createElement("div"))
								.append(
									$(document.createTextNode("Query: ")),
									$(document.createElement("input"))
										.addClass("querywindow-query")
										.attr("id", "recordquery"),
									$(document.createElement("input"))
										.attr("type", "button")
										.attr("id", "querybutton")
										.val("Query")
										.click(
											function(){
												hDebugger.rset = [];
												for (var i in hDebugger.patients){
													for (var j in hDebugger.patients[i].json){
														
														eval ("var " + j + "=hDebugger.patients[" + i + "].json['" + j + "'];");
														//console.log("var " + j + "=hDebugger.patients[" + i + "].json['" + j + "'];" + " => " + eval("function r(v){return v;}; r(" + j + ");"));
														
													}
													//console.log($("#recordquery").val() + " => " + eval($("#recordquery").val()));													
													//debugger;
													if ($("#recordquery").val() == "" || eval($("#recordquery").val())) hDebugger.rset[hDebugger.rset.length] = hDebugger.patients[i];
												}
												$("#recordlist").empty();
												$("#recordlist").append(
													$(document.createElement("tr"))
														.append(
															$(document.createElement("td"))
																.attr("colspan", 0)
																.addClass("querywindow-recordstatus")
																.text("Matched " + hDebugger.rset.length + " records")
														)
												);
												for (var i in hDebugger.rset){
													var e = $(document.createElement("tr")).addClass("querywindow-record");
													$("#recordlist").append(e);
													for (var j in hDebugger.rset[i].json){
														$(e).append(
															$(document.createElement("td")).text(hDebugger.rset[i].json[j])
														);
													}
												}
											}
										),
									$(document.createElement("input"))
										.attr("type", "button")
										.val("Debug")
										.click(
											function(){
												$(this).parent().parent().remove();
												hDebugger.execute($("#query_map"), $("#query_reduce"), true);
											}
										)
								),
							$(document.createElement("div"))
								.addClass("querywindow-recordlist")
								.append(
									$(document.createElement("table"))
										.attr("id", "recordlist")
										.attr("cellspacing", "10")
								)
						)
				);
				/*for(var i in hDebugger.rset){
					var e = $(document.createElement("tr"));
					$("#recordlist").append(e);
					for (var j in hDebugger.rset[i].json){
						$(e).append(
							$(document.createElement("td")).text(hDebugger.rset[i].json[j])
						);
					}
				}*/
				$("#querybutton").click();
			}
		);
		
		$("#query_map").parent().css("white-space", "nowrap");
		$("#query_map").parent().append(
			$(document.createElement("span"))
				.addClass("debug")
				.attr("id", "map_out")
		)
		$("#query_reduce").parent().css("white-space", "nowrap");
		$("#query_reduce").parent().append(
			$(document.createElement("span"))
				.addClass("debug")
				.attr("id", "reduce_out")
		)

		hDebugger.ace("query_map");
		hDebugger.ace("query_reduce");
	},
	ace: function (eid){
		var JavaScriptMode = require("ace/mode/javascript").Mode;
		$(document.body).append(
			$(document.createElement("div"))
				.css("top", $("#" + eid).offset().top)
				.css("left", $("#" + eid).offset().left)
				.css("width", $("#" + eid).width())
				.css("height", $("#" + eid).height())
				.addClass("rta")
				.attr("id", "e_" + eid)
				.keyup(
					('function(){'+
						'$("#' + eid + '").val(hDebugger.ace_' + eid + '.getSession().getValue());'+
						'$("#' + eid + '").keydown();'+
						'$("#' + eid + '").keyup();'+
					'}').toFunction()
				)
		)
		eval('hDebugger.ace_' + eid + ' = ace.edit("e_" + eid);');
		eval('hDebugger.ace_' + eid + '.getSession().setMode(new JavaScriptMode());');
		$("#" + eid).css("visibility", "hidden");
		eval('hDebugger.ace_' + eid + '.getSession().setValue($("#' + eid + '").val());');
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
		$("#" + src).parent().append(
			$(document.createElement("span"))
				.addClass("err")
				.attr("id", "f_" + g + "_d")
		);
		this.debug(g);
	},
	clear: function(e){
		$(e).empty();
	},
	err: function(err, dest){
		$(dest).append($(document.createElement("p"))
			.text(err)
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
					if (!hDebugger.md) hDebugger.execute($("#query_map"), $("#query_reduce"), false);
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
	execute: function(m, r, c){
		$(this).val("Processing...");
		this.eres = {};
		this.rres = {};
		emit = this.emit;
		this.map = $(m).val().toFunction();
		for (var i = 0; i < (c ? this.rset : this.patients).length; i++) {
		  this.map((c ? this.rset : this.patients)[i]);
		}
		this.reduce = $(r).val().toFunction();
		for (var i in this.eres){
			//document.write(i + " -- " + this.rres[i] + " -- " + this.eres[i] + "<br />");
			this.rres[i] = this.reduce (i, this.eres[i]);
		}		
		var output = '<div style="font-size:30px;">Map Output</div><br /><br /><table>';
		for (var i in this.eres) output += "<tr><td>" + i + "</td><td>=></td><td>" + this.eres[i] + "</td></tr>";
		$("#map_out").html(output);
		var output = '<div style="font-size:30px;">ReduceOutput</div><br /><br /><table>';
		for (var i in this.rres) output += "<tr><td>" + i + "</td><td>=></td><td>" + this.rres[i] + "</td></tr>";
		$("#reduce_out").html(output);
		/*$(".query ~ tbody > tr:first-child").append(
				$(document.createElement("td"))
					.attr("rowspan", 6)
					.css("vertical-align", "top")
					.html(output)
			)*/
		/*var reswin = $(document.createElement("div"))
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
		$(reswin).height($(document).height())*/
		//$(document).scrollTop(0);
		$("#debug").removeAttr("disabled");
		$("#debug").val("Debug");
	}
};
/*f.__proto__.length = function(){
	c: 0;
	for (var i in this) c++;
	return c;
}*/

$(document).ready(function(){
	hDebugger.init();
	//debugger;
});