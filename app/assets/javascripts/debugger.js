//= require patient
var hDebugger = {
	libraryFunctions: [],
	patients: [],
	
	// Convenience function to quickly initialize editors on the queries/edit page for mocking MapReduce jobs.
	// Individual ace_editors can be created by directly calling initializeEditor
	initialize: function() {
	  var editorList = ['map', 'reduce'];
	  
	  // Initialize the ace editors
	  this.initializeEditor('map', editorList);
	  this.initializeEditor('reduce', editorList);
    this.debug(editorList);
    
    $("#debug_button").click(hDebugger.execute);
	},
	
	// Converts a textarea to an ace_editor with an error panel to the right
	initializeEditor: function(elementId, editorList) {
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
		  hDebugger.debug(editorList);
		  elements['functionText'].val(aceEditor.getSession().getValue());
		});
		
		// Define resizing action for the editor
		elements['container'].resizable();
		elements['container'].resize(function() {
		  // Don't allow the editor to resize so far that there isn't room for the error panel
		  var maximumWidth = $('#mainPanel').outerWidth(true);
  		maximumWidth -= elements['editor'].offset().left;
  		maximumWidth -= elements['errorPanel'].outerWidth(true);
  		maximumWidth -= 30; // A bit of a hack - Accounting for random little padding amounts etc
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
	
	debug: function(editorList) {
		var allCodeIsValid = true;
		
		for (var i in editorList) {
		  // Clear any previous error messages
		  var elementId = editorList[i];
		  $('#' + elementId + '_error_panel_text').empty();
		  try {
		    // Check to see that we have defined map and reduce functions.
		    // If we don't, throw an error that we catch below. Otherwise, hide the error panel.
  			eval(this[elementId + '_ace_editor'].getSession().getValue());
  			// If we're debugging a map or reduce function, it must be named exactly that to be compliant
  			if ((elementId == 'map' || elementId == 'reduce') && typeof eval(elementId) != "function")
  				throw 'Syntax Error';
  			else
  			  $('#' + elementId + '_error_panel').hide();
  		} catch (e) {
  		  // If there is not a map/reduce function, show error text and disable the debug button
  		  allCodeIsValid = false;
  		  var errorMessage = elementId + ' is invalid: ' + e.message;
    	  $('#' + elementId + '_error_panel_text').text(errorMessage);
  			$('#' + elementId + '_error_panel').show();
  			this.showCodeIsInvalid();
  		}
		}
		
		// Allow the user to run their code if it is all valid
		if (allCodeIsValid)
		  this.showCodeIsValid();
	},
	
	// The above initialization and syntax checking is reuseable, but the UI outside of the ace editor varies by page.
	// By default, this function works for queries/edit for mocking MapReduce jobs. It should be overwritten on
	// other pages so context specific UI elements can be altered.
	showCodeIsValid: function() {
	  $('#debug_button').removeAttr('disabled');
	},
	
	showCodeIsInvalid: function() {
	  $('#debug_button').attr('disabled', 'disabled');
	},
	
	addLibraryFunctions: function(libraryFunctions) {
	  this.libraryFunctions.push(libraryFunctions);
	},
	
	// This execute function is specific to queries/edit for mocking MapReduce jobs
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
		
		// Define all of the user's library functions
		for (var i in hDebugger.libraryFunctions)
		  eval(hDebugger.libraryFunctions[i]);
		
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