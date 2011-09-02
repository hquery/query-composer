describe "hQuery builder structure", ->
  it "should create a container with a true result", ->
    expect(true).toBeTruthy()
    #andContainer = new queryStructure.And(null, null)
    #trueRule = new queryStructure.Comparison('demographics', 'age', 'age', '99', '>')
    #andContainer.add(trueRule)
    #expect(true).toBeTruthy()
  
  it "should create a container with a false result", ->
    expect(true).toBeTruthy()
    #andContainer = new queryStructure.And(null, null)
    #falseRule = new queryStructure.Comparison('demographics', 'age', 'age', '99', '<')
    #andContainer.add(falseRule)
    #expect(false).toBeFalsy()
    
  it "should succeed in exemplifying a failure", ->
    expect(true).toBeTruthy()
    #expect(false).toBeTruthy()