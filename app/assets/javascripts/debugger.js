//= require patient
String.prototype.toFunction = function(){
	return eval("(function(){ return "+ this + ";})()");
}

var hDebugger = {
	patients: [],
	
	initialize: function() {
	  // Initialize the ace editors
	  this.initializeEditor('map');
	  this.initializeEditor('reduce');
    this.debug();
    
    $("#debug_button").click(hDebugger.execute);
	},
	
	initializeEditor: function(elementId, initialValue) {
	  // Grab onto DOM elements we'll use frequently in this function
	  var elements = {
	    'container' : $('#' + elementId + '_container'),
      'editor' : $('#' + elementId + '_editor'),
      'functionText' : $('#' + elementId + '_text'),
      'errorPanel' : $('#' + elementId + '_error_panel'),
      'errorPanelText' : $('#' + elementId + '_error_panel_text')
	  };
	  
	  // Transform our editor div into an ace editor
		this[elementId + '_ace_editor'] = ace.edit(elementId + '_editor');
		var aceEditor = this[elementId + '_ace_editor'];
		var JavaScriptMode = require('ace/mode/javascript').Mode;
		aceEditor.getSession().setMode(new JavaScriptMode());
		
		// Customize our editor to look pretty and begin with the function value
		aceEditor.getSession().setValue(elements['functionText'].val());
		aceEditor.setShowPrintMargin(false);
		aceEditor.getSession().setUseSoftTabs(true);
		aceEditor.getSession().setTabSize(2);
		
		// Debug whenever editor text changes. Store the value in our textarea that submits with the form
		aceEditor.getSession().on('change', function() {
		  hDebugger.debug();
		  elements['functionText'].val(aceEditor.getSession().getValue());
		});
		
		// Define resizing action for the editor
		elements['container'].resizable();
		elements['container'].resize(function() {
		  // Don't allow the editor to resize so far that there isn't room for the error panel
		  var maximumWidth = $('#pageContent').outerWidth(true);
  		maximumWidth -= elements['editor'].offset().left;
  		maximumWidth -= elements['errorPanel'].outerWidth(true);
  		maximumWidth -= 40; // A bit of a hack - Accounting for random little padding amounts etc
  		elements['container'].resizable("option", "maxWidth", maximumWidth);
		  
		  // Resize the editor and the error panel along with the editor
		  elements['errorPanel'].resize();
		  aceEditor.resize();
		});
		
		// Define errorPanel resize to keep the height identical to the editor
		elements['errorPanel'].resize(function() {
  	  $(this).height(elements['editor'].height());
  	});
	},
	
	debug: function() {
	  // We'll debug both editors
		var elements = ['map', 'reduce'];
		var allCodeIsValid = true;
		
		for (var element in elements) {
		  // Clear any previous error messages
		  var elementId = elements[element];
		  $('#' + elementId + '_error_panel_text').empty();
		  try {
		    // Check to see that we have defined map and reduce functions.
		    // If we don't, throw an error that we catch below. Otherwise, hide the error panel.
  			eval(this[elementId + '_ace_editor'].getSession().getValue());
  			if (typeof eval(elementId) != "function")
  				throw 'Syntax Error';
  			else
  			  $('#' + elementId + '_error_panel').hide();
  		} catch (e) {
  		  // If there is not a map/reduce function, show error text and disable the debug button
  		  allCodeIsValid = false;
  		  var errorMessage = elementId + ' function is invalid: ' + e.message;
    	  $('#' + elementId + '_error_panel_text').text(errorMessage);
  		  $('#debug_button').attr('disabled', 'disabled');
  			$('#' + elementId + '_error_panel').show();
  		}
		}
		
		// Allow the user to run their code if it is all valid
		if (allCodeIsValid)
		  $('#debug_button').removeAttr('disabled');
	},
	
	execute: function() {
	  // Disable the debug button until we finish calculating
		$('#debug_button').attr('disabled', 'disabled');
		$('#debug_button').val('Processing. . .');
		
		// Define our own emit function so the user defined map and reduce functions can store their output
		var mapEmits = {};
		var reduceResults = {};
		var emit = function(key, value) {
  		if (mapEmits[key])
  		  mapEmits[key].push(value);
  		else
  	    mapEmits[key] = [value];
  	};
		
		// Define map and reduce from the editors and run each patient through the process
    eval(hDebugger['map_ace_editor'].getSession().getValue());
		for (var i in hDebugger.patients)
		  map(hDebugger.patients[i]);

		eval(hDebugger['reduce_ace_editor'].getSession().getValue());
		for (var i in mapEmits)
			reduceResults[i] = reduce(i, mapEmits[i]);
		
		// Format results from all the emits
		var output = '<tr><td>Key</td><td>Emitted Values</td></tr>';
		for (var i in mapEmits)
		  output += '<tr><td>' + i + '</td><td>' + mapEmits[i] + '</td>';
		$('#map_output').html(output);
		
		// Format the reduced results
		output = '<tr><td>Key</td><td>Reduced Value</td></tr>';
		for (var i in reduceResults)
		  output += '<tr><td>' + i + '</td><td>' + reduceResults[i] + '</td>';
		$('#reduce_output').html(output);
		
		// Close up shop - Reactivate the debug button, show the results
		$('#debug_button').removeAttr('disabled');
		$('#debug_button').val("Debug");
		$('.debug_output').show();
	}
};