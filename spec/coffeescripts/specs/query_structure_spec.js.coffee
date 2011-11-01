describe "Generated Query Structure", ->
  patient = { 'foo' : -> return 9000 }
  json = 
    'find' : 
      'and' : 
        [
          'or' :
            [
              'name' : 'demographics'
              'and' :
                [
                  'category' : 'demographics'
                  'title' : 'age'
                  'field' : 'age'
                  'value' : 18
                  'comparator' : '>'
                ]
            ]
        ]
    'filter' : 
      'and' : 
        [
          'or' :
            [
              'name' : 'demographics'
              'and' :
                [
                  'category' : 'demographics'
                  'title' : 'age'
                  'field' : 'age'
                  'value' : 65
                  'comparator' : '<'
                ]
            ]
        ]
    'extract' :
      'selections' : [ 
        'title' : 'age'
        'callstack' : 'age'
        'aggregation' : 'sum'
      ]
      'groups' : [ 
        'title' : 'gender'
        'callstack' : 'gender'
      ]
###  
  it "should create a blank query", ->
    query = new queryStructure.Query()
    
    expect(query.find).toBeDefined()
    expect(query.find.children.length).toEqual(1)
    expect(query.find.test()).toBeTruthy()
    
    expect(query.filter).toBeDefined()
    expect(query.filter.children.length).toEqual(1)
    expect(query.filter.test()).toBeTruthy()
    
    expect(query.extract).toBeDefined()
    
  it "should be able to JSONify the Query object", ->
    query = new queryStructure.Query()
    query.find.children[0].add(new queryStructure.And(null, null, 'demographics'))
    query.find.children[0].children[0].add(new queryStructure.Comparison('demographics', 'age', 'age', 18, '>'))
    query.filter.children[0].add(new queryStructure.And(null, null, 'demographics'))
    query.filter.children[0].children[0].add(new queryStructure.Comparison('demographics', 'age', 'age', 65, '<'))
    query.extract = new queryStructure.Extraction([new queryStructure.Selection('age', 'age', 'sum')], [new queryStructure.Group('gender', 'gender')])
    
    expect(query.toJson()).toEqual(json)
  
  it "should rebuild a query from JSON", ->
    query = new queryStructure.Query()
    query.rebuildFromJson(json)
    
    expect(query.toJson()).toEqual(json)
  
  it "should have functioning helper methods for rebuilding from JSON", ->
    query = new queryStructure.Query()
    andContainer = new queryStructure.And(null, null)
    orContainer = new queryStructure.Or(null, null)
    comparison = new queryStructure.Comparison('demographics', 'age', 'age', 65, '>')
    
    expect(query.getElementType(andContainer.toJson())).toEqual('container')
    expect(query.getElementType(orContainer.toJson())).toEqual('container')
    expect(query.getElementType(comparison.toJson())).toEqual('rule')
    
    expect(query.getContainerType(andContainer.toJson())).toEqual('And')
    expect(query.getContainerType(orContainer.toJson())).toEqual('Or')
    expect(query.getContainerType(comparison.toJson())).toBeNull()
    expect(query.getRuleType(comparison.toJson())).toEqual('Comparison')
###
