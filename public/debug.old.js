$(document).ready(function(){
	$("#debug").click(function(event){
		w = window.open("/validator.html", "validator", "channelmode=0, directories=0, fullscreen=0, location=0, menubar=0, resizable=1, scrollbars=1, status=1, toolbar=no, width=800, height=800");
		w.focus();
	});
});