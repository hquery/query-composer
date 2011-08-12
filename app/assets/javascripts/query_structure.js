/**
 * When the user interacts with the Query Builder UI, we need to construct a data representation to match.
 * Here we defined a variable called queryStructure that is the JSON equivalent of the drag and drop interface.
 * The structure contains logical operators (e.g. "and"/"or") that define relationships to subelements, which can
 * be additional logical operators or atomic rules (e.g. language == 'english').
*/

var hQuery = hQuery || {};
var builder = hQuery.builder || {};

// Define a structure to remember all elements and their logical operators for each UI zone.
// We also will maintain an index into each structure so we don't have to search for the ID of deeply nested elements.
var queryStructure;
var queryIndex;

/**
 * Called on page load to define each UI zone's structure and index.
*/
function initializeStructures() {
  queryStructure = {};
  queryIndex = {};
  
  // Add a section for each UI zone
  queryStructure['find'] = { "id" : 0, "or" : [] };
  queryStructure['filter'] = { "id" : 2, "or" : [] };
  queryStructure['extract'] = { "id" : 4, "or" : [] };
  queryStructure['analyze'] = { "id" : 6, "or" : [] };

  // Include the initial indecies for the UI zones.
  queryIndex['0'] = queryStructure['find'];
  queryIndex['2'] = queryStructure['filter'];
  queryIndex['4'] = queryStructure['extract'];
  queryIndex['6'] = queryStructure['analyze'];
  
  // Also add one "and" operation to the head of each UI zone.
  add(0, 1, 'and', { });
  add(2, 3, 'and', { });
  add(4, 5, 'and', { });
  add(6, 7, 'and', { });
}

/**
 * Just for testing. Adding elements all willy nilly style.
*/
function fakeIt() {
  initializeStructures();
  
  add(1, 8, 'and', { "name" : "demographics" });
  add(8, 9, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "18", "end" : "45" });
  add(8, 10, 'rule', { "category" : "demographics", "title" : "ethnicity", "name" : "ethnicity", "value" : "martian" });
  add(8, 11, 'rule', { "category" : "demographics", "title" : "language", "name" : "language", "value" : "c++" });
  add(1, 12, 'and', { "name" : "condition" });
  add(12, 13, 'rule', { "category" : "condition", "title" : "condition", "name" : "condition", "value" : "buttflu" });
  add(1, 14, 'and', { "name" : "treatment" });
  add(14, 15, 'rule', { "category" : "treatment", "title" : "name", "name" : "name", "value" : "butttherapy" });
  
  add(0, 16, 'and', { });
  add(16, 17, 'and', { "name" : "demographics" });
  add(17, 18, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "41", "end" : "43" });
  add(16, 19, 'and', { "name" : "condition" });
  add(19, 20, 'rule', { "category" : "demographics", "title" : "name", "name" : "name", "value" : "perfecthealth" });
}

/**
 * This function is repeatedly called by the UI everytime an element is altered. We'll hit the server to retrieve the actual
 * syntax of the mapFunction and reduceFunction.
*/
function generateQuery() {
  $.ajax({
    url: '/queries/generate_query/',
    type: 'POST',
    data: 'query_structure=' + JSON.stringify(queryStructure)
  });
}


// category":"Patient characteristic","title":"Age >= 17 years
// category, title, value

/**
 * When a new element with ID newId is added to an existing element with ID parentId, this function is called. The appropriate zone's structure and index are updated.
 * Operation is either a logical operator, e.g. 'and_operation', or an actual rule, denoted by 'rule'. Rules are instructions e.g. 'age >= 65'
*/
function add(parentId, newId, operation, params) {
  // Return if we've received invalid input
  if (queryStructure == undefined || queryIndex == undefined)
    return false; // Can't add when our structure and index have not yet been initialized
  if (!(parentId in queryIndex))
    return false; // Can't add to a non-existent element
  if (newId in queryIndex)
    return false; // Can't add an element with an ID that already exists
  
  // In order to access the array to which we're adding this element, we need to search for what the operation is called
  var parentOperation = getElementOperation(parentId);
  if (parentOperation == 'rule')
    return; // We can only add new elements to containers
  
  // Prepare the new element that we're going to add with the information passed in
  var newElement = { "id" : newId };
  var newElementPosition = queryIndex[parentId][parentOperation].length;
  for (key in params)
    newElement[key] = params[key];
  
  // If we're adding a logical operator, e.g. "and"/"or", we need to associate an array for its subelements
  if (operation == 'and' || operation == 'or' || operation == 'count_n')
    newElement[operation] = [];

  // Insert the new element into the target's params
  queryIndex[parentId][parentOperation][newElementPosition] = newElement;
  queryIndex[newId] = queryIndex[parentId][parentOperation][newElementPosition];
  // Keep track of the element's parent. We're making a whole new element so that we don't append into the actual filterRules structure
  queryIndex[newId + '-parent'] = parentId;

  return true;
}

/**
 * When an element that already exists in a structure is updated from the UI, this function may be called.
 * This is used to update information in elements' hash. 
*/
function update(id, params) {
  if (queryStructure == undefined || queryIndex == undefined)
    return false; // Can't update when our structure and index have not yet been initialized
  if (!(id in queryIndex))
    return false; // Can't edit a non-existent element

  for (key in params) {
    // If this key is trying to alter an operation, ignore it
    if (key != 'and' && key != 'or' && key != 'count_n')
      queryIndex[id][key] = params[key];
  }
}

/**
 * When an element that already exists in a structure is updated from the UI, this function may be called.
 * If an operation is being transformed into another (e.g., and -> or), this function is used 
*/
function updateOperation(id, newOperation) {
  if (queryStructure == undefined || queryIndex == undefined)
    return false; // Can't update when our structure and index have not yet been initialized
  if (!(id in queryIndex))
    return false; // Can't edit a non-existent element
  var currentOperation = getElementOperation(id);
  if (currentOperation == 'rule')
    return false; // Rules are not operations and so we cannot update them
  
  // Insert the new operation and give it the same array as the current operation. Drop the old one.
  queryIndex[id][newOperation] = queryIndex[id][currentOperation];
  delete queryIndex[id][currentOperation];
}

/**
 * If an element is removed entirely from a zone, we'll deleted it from the corresponding structure and index here.
*/
function remove(id) {
  if (queryStructure == undefined || queryIndex == undefined)
    return false; // Can't remove when our structure and index have not yet been initialized
  if (id < 8)
    return false; // Can't delete top level elements, e.g. "filter" or the "or" operation immediately below
  if (!(id in queryIndex))
    return false; // Return if we've received invalid input

  // Access the parent from whom we're removing the element with the given id
  var parent = queryIndex[queryIndex[id + '-parent']];
  var parentOperation = getElementOperation(queryIndex[id + '-parent']);
  var parentElements = parent[parentOperation];

  // Scroll through the parent element until we find the item we're looking to delete
  for (var i = parentElements.length - 1; i >= 0; i--) {
    var element = parentElements[i];
    if (element.id == id) {
      var operation = getElementOperation(element.id);
      if (operation != 'rule') { // If we're removing a logical operation
        for (var n = element[operation].length - 1; n >= 0; n--) { // Recursively remote its children
          remove(element[operation][n].id);
        }
      }
      parent[parentOperation].splice(i, 1);
      delete queryIndex[id];
      delete queryIndex[id + '-parent'];
      return;
    }
  }
}

/**
* This is a utility function to know what kind of operation the parent of an element is
*/
function getElementOperation(elementId) {
  if (queryStructure == undefined || queryIndex == undefined)
    return false; // Can't look at elements when our structure and index have not yet been initialized
  if (!(elementId in queryIndex))
    return -1; // Can't find information about a non-existent element
  
  if (queryIndex[elementId]['and'] != undefined)
    return 'and';
  else if (queryIndex[elementId]['or'] != undefined)
    return 'or';
  else if (queryIndex[elementId]['count_n'] != undefined)
    return 'count_n';
  else
    return 'rule';
}