/**
* These specs test that we properly maintain the structure of a query that is built based on UI calls
* within the query builder. We also want to verify that the index into the structure functions properly.
*/
describe("Query Structure", function () {  
  
  function numKeysIn(hash) {
    count = 0;
    for (key in hash) {
      count++;
    }
    
    return count;
  }
  
  it("initializes the query structure and index", function() {  
    expect(queryStructure).toBeUndefined({});
    expect(queryIndex).toBeUndefined({});
    
    initializeStructures();
    
    expect(queryStructure['find']).toBeDefined([]);
    expect(queryStructure['filter']).toBeDefined([]);
    expect(queryStructure['extract']).toBeDefined([]);
    expect(queryStructure['analyze']).toBeDefined([]);
    expect(numKeysIn(queryIndex)).toEqual(12);
  });
  
  it("adds operations to the query structure and index", function() {  
    initializeStructures();
    var originalIndexLength = numKeysIn(queryIndex);
    add(1, 8, 'and', { "name" : "demographics" });
    add(1, 12, 'or', {});
    add(4, 20, 'count_n', { "n" : 2});
    
    expect(numKeysIn(queryIndex)).toEqual(originalIndexLength + 6);
    expect(queryIndex[8]).toEqual({ "id" : 8, "name" : "demographics", "and" : [] });
    expect(queryIndex[12]).toEqual({ "id" : 12, "or" : [] });
    expect(queryIndex[20]).toEqual({ "id" : 20, "n" : 2, "count_n" : [] });
    
    expect(queryIndex[queryIndex['8-parent']]).toEqual(queryIndex[1]);
    expect(queryIndex[queryIndex['12-parent']]).toEqual(queryIndex[1]);
    expect(queryIndex[queryIndex['20-parent']]).toEqual(queryIndex[4]);
  });
  
  it("adds single rules to the query structure and index", function() {
    initializeStructures();
    var originalIndexLength = numKeysIn(queryIndex);
    add(1, 8, 'and', { "name" : "demographics" });
    add(8, 9, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "18", "end" : "45" });
    add(8, 11, 'rule', { "category" : "demographics", "title" : "language", "name" : "language", "value" : "c++" });
    add(1, 12, 'or', { "name" : "condition" });
    add(12, 13, 'rule', { "category" : "condition", "title" : "condition", "name" : "condition", "value" : "flu" });
    add(12, 15, 'rule', { "category" : "treatment", "title" : "name", "name" : "name", "value" : "chicken noodle soup" });
    
    expect(numKeysIn(queryIndex)).toEqual(originalIndexLength + 12);
    expect(queryIndex[8]['and'].length).toEqual(2);
    expect(queryIndex[12]['or'].length).toEqual(2);
    
    expect(queryIndex[15]['value']).toEqual('chicken noodle soup');
    expect(queryIndex[9]['special_rule']).toEqual('range');
  });
  
  it("gracefully fails to add to a target that doesn't exist", function() {
    initializeStructures();
    var originalIndexLength = numKeysIn(queryIndex);
    add(9001, 8, 'and', {});
    expect(numKeysIn(queryIndex)).toEqual(originalIndexLength);
  });
  
  it("gracefully fails to add an element with a duplicate ID", function() {
    initializeStructures();
    var originalIndexLength = numKeysIn(queryIndex);
    add(1, 1, 'and', { });
    expect(numKeysIn(queryIndex)).toEqual(originalIndexLength);
  });
  
  it("updates operations to the query structure and index", function() {
    initializeStructures();
    add(1, 8, 'count_n', { });
    var originalOperation = getElementOperation(0);
    var originalIndexLength = numKeysIn(queryIndex);
    updateOperation(0, 'and');
    updateOperation(1, 'count_n');
    updateOperation(8, 'or');
    
    expect(originalIndexLength).toEqual(numKeysIn(queryIndex));
    expect(originalOperation).toEqual('or');
    expect(getElementOperation(0)).toEqual('and');
    expect(getElementOperation(1)).toEqual('count_n');
    expect(getElementOperation(8)).toEqual('or');
  });
  
  it("updates parameters to the query structure and index", function() {  
    initializeStructures();
    add(1, 8, 'or', { "name" : "demographics" });
    add(8, 9, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "18", "end" : "45" });
    var originalIndexLength = numKeysIn(queryIndex);
    update(9, { "category" : "condition", "title" : "age", "special-condition" : "shhh, it's a secret" });
    
    expect(originalIndexLength).toEqual(numKeysIn(queryIndex));
    expect(queryIndex[9]['special-condition']).toEqual("shhh, it's a secret");
    expect(queryIndex[9]['category']).toEqual('condition');
    expect(queryIndex[9]['name']).toEqual('age');
    
    add(8, 10, 'rule', { "category" : "demographics", "title" : "language", "name" : "language", "value" : "c++" });
    add(8, 11, 'rule', { "category" : "condition", "title" : "condition", "name" : "condition", "value" : "flu" });
    update(1, { "name" : "demographics" })
    update(10, { "value" : "french" });
    update(11, { "title" : "cond" });
    
    expect(queryIndex[1]['name']).toEqual('demographics');
    expect(queryIndex[10]['value']).toEqual('french');
    expect(queryIndex[11]['title']).toEqual('cond');
  });
  
  it("ignores parameter updates that attempt to alter operations", function() {
    initializeStructures();
    update(0, { "or" : [ 'blah', 'blah' ] });
    update(1, { "and" : [ 'blah', 'blah' ] });
    update(2, { "count_n" : [ 'blah', 'blah' ] });
    
    expect(queryIndex[0]['or'].length).toEqual(1); // The operation's array of subelements should not have been replaced
    expect(queryIndex[1]['and'].length).toEqual(0);
    expect(queryIndex[2]['or'].length).toEqual(1);
    expect(queryIndex[2]['count']).toBeUndefined(); // Double check that we aren't adding a new element
    
    add(1, 8, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "18", "end" : "45" });
    update(8, { "and" : [ 'blah', 'blah' ] });
    
    expect(queryIndex[8]['and']).toBeUndefined(); // There shouldn't be any "and" added to the rule
  });
  
  it("gracefully fails to update a non-existent operation", function() {  
    initializeStructures();
    updateResult = updateOperation(9001, 'and');
    
    expect(updateResult).toBeFalsy();
  });
  
  it("gracefully fails to update a non-existent rule", function() {  
    initializeStructures();
    updateResult = update(9001, { "category" : "treatment" });
    
    expect(updateResult).toBeFalsy();
  });
  
  it("removes operations and their subelements from the query structure and index", function() {  
    initializeStructures();
    add(1, 8, 'and', { });
    add(8, 9, 'and', { });
    add(9, 10, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "18", "end" : "45" });
    add(9, 11, 'count_n', { "n" : 2 });
    add(11, 12, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "18", "end" : "45" });
    var originalIndexLength = numKeysIn(queryIndex);
    remove(8);
    
    expect(originalIndexLength).toEqual(numKeysIn(queryIndex) + 10);
    expect(queryIndex[8]).toBeUndefined();
    expect(queryIndex[9]).toBeUndefined();
    expect(queryIndex[10]).toBeUndefined();
    expect(queryIndex[11]).toBeUndefined();
    expect(queryIndex[12]).toBeUndefined();
  });
  
  it("removes rules from the query structure and index", function() {  
    initializeStructures();
    add(1, 8, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "18", "end" : "45" });
    add(1, 9, 'rule', { "category" : "demographics", "title" : "language", "name" : "language", "value" : "c++" });
    add(1, 10, 'rule', { "category" : "treatment", "title" : "name", "name" : "name", "value" : "chicken noodle soup" });
    var originalIndexLength = numKeysIn(queryIndex);
    remove(9);
    
    expect(originalIndexLength).toEqual(numKeysIn(queryIndex) + 2);
    expect(queryIndex[9]).toBeUndefined();
    expect(queryIndex['9-parent']).toBeUndefined();
    
    remove(10);
    remove(8);
    expect(originalIndexLength).toEqual(numKeysIn(queryIndex) + 6);
  });
  
  it("gracefully fails to remove a non-existent element", function() {  
    initializeStructures();
    var result = remove(9001);
    
    expect(result).toBeFalsy();
  });
  
  it("gracefully fails to remove essential elements", function() {  
    initializeStructures();
    var originalIndexLength = numKeysIn(queryIndex);
    for (i = 0; i < 8; i++) {
      remove(i);
      expect(numKeysIn(queryIndex)).toEqual(originalIndexLength);
    }
  });
  
  it("knows the operation type of all elements", function() {
    initializeStructures();
    add(1, 8, 'count_n', { });
    add(8, 9, 'rule', { "category" : "demographics", "title" : "age", "name" : "age", "special_rule" : "range", "start" : "18", "end" : "45" });
    
    expect(getElementOperation(0)).toEqual('or');
    expect(getElementOperation(1)).toEqual('and');
    expect(getElementOperation(8)).toEqual('count_n');
    expect(getElementOperation(9)).toEqual('rule');
    expect(getElementOperation(9001)).toEqual(-1);
  });
  
  it("doesn't execute functions unless structure and index have been initialized", function() {  
    queryStructure = undefined;
    queryIndex = undefined;
    
    var result = add(1, 8, 'rule', { "category" : "demographics", "title" : "language", "name" : "language", "value" : "c++" });
    expect(result).toBeFalsy();
    
    result = update(1, { "name" : "blah" });
    expect(result).toBeFalsy();
    
    result = updateOperation(1, 'or');
    expect(result).toBeFalsy();
    
    result = remove(9);
    expect(result).toBeFalsy(); // remove 
    
    result = getElementOperation(1);
    expect(result).toBeFalsy();
  });
    
});