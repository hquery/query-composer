// Define a structure to remember all elements and their logical operators for each UI zone.
// We also will maintain an index into each structure so we don't have to search for the ID of deeply nested elements.
var queryStructure = {};
var queryIndex = [];

/**
 * Called on page load to define each UI zone's structure and index.
*/
function initializeStructures() {
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
  if (!(parentId in queryIndex))
    return false; // Can't add to a non-existant element
  if (newId in queryIndex)
    return false; // Can't add an element with an ID that already exists
  
  // In order to access the array to which we're adding this element, we need to search for what the operation is called
  parentOperation = getParentOperation(parentId);
  if (parentOperation == -1)
    return; // We can only add new elements to containers
  
  // Prepare the new element that we're going to add with the information passed in
  newElement = { "id" : newId };
  newElementPosition = queryIndex[parentId][parentOperation].length;
  for (key in params)
    newElement[key] = params[key];
  
  // If we're adding a logical operator, e.g. "and"/"or", we need to associate an array for its subelements
  logicalOperators = ['and', 'or', 'count_n'];
  if ($.inArray(operation, logicalOperators) != -1)
    newElement[operation] = [];

  // Insert the new element into the target's params
  queryIndex[parentId][parentOperation][newElementPosition] = newElement;
  queryIndex[newId] = queryIndex[parentId][parentOperation][newElementPosition];
  // Keep track of the element's parent. We're making a whole new element so that we don't append into the actual filterRules structure
  queryIndex[newId + '-parent'] = parentId;

  return true;
}

/**
 * When an element that already exists in a structure is updated from the UI, this function is called. It's a clean replacement of all parameters
 * listed for the element with ID id.
*/
function update(id, params) {
  if (!(id in queryIndex))
    return false; // Can't edit a non-existant element

  for (key in params)
    queryIndex[id][key] = params[key];
}

/**
 * If an element is removed entirely from a zone, we'll deleted it from the corresponding structure and index here.
*/
function remove(id) {
  // Can't delete top level elements, e.g. "filter" or the "or" operation immediately below
  if (id < 8)
    return;
  
  // Return if we've received invalid input
  if (!(id in queryIndex))
    return false;

  // Access the parent from whom we're removing the element with the given id
  parent = queryIndex[queryIndex[id + '-parent']];
  parentOperation = getParentOperation(queryIndex[id + '-parent']);
  if (parentOperation == -1)
    return; // We can only add new elements to containers

  // Scroll through the parent element until we find the item we're looking to delete
  for (var i = 0; i < parent[parentOperation].length; i++) {
    if (parent[parentOperation][i].id == id) {
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
function getParentOperation(parentId) {
  if (queryIndex[parentId]['and'] != undefined)
    return 'and';
  else if (queryIndex[parentId]['or'] != undefined)
    return 'or';
  else if (queryIndex[parentId]['count_n'] != undefined)
    return 'count_n';
  else
    return -1;
}