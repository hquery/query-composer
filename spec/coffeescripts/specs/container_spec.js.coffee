describe "QueryStructure Containers", ->
  it "should create And and Or containers", ->
    parent = new queryStructure.And(null, null, 'foo')
    expect(parent.children).toEqual([])
    expect(parent.parent).toBeNull()
    expect(parent.name).toEqual('foo')

    child = new queryStructure.Or(parent, null)
    # TODO
    #expect(parent.children[0]).toBe(child)
    expect(child.parent).toBe(parent)

    grandparent = new queryStructure.And(null, [parent], 'bar', true)
    # TODO
    #expect(parent.children[0]).toBe(parent)
    # TODO
    #expect(parent.parent).toBe(grandparent)
    expect(grandparent.negate).toBeTruthy()

  it "should evaluate And containers correctly", ->
    andContainer = new queryStructure.And(null, null)
    expect(andContainer.test(patient)).toBeTruthy()  
    andContainer.add(new queryStructure.Comparison('demographics', 'foo', 'foo', 9001, '<'))
    expect(andContainer.test(patient)).toBeTruthy()

    andContainer.add(new queryStructure.Comparison('demographics', 'foo', 'foo', 9002, '<'))
    andContainer.add(new queryStructure.Comparison('demographics', 'foo', 'foo', 8999, '<'))
    expect(andContainer.test(patient)).toBeFalsy()

  it "should evaluate Or containers correctly", ->
    orContainer = new queryStructure.Or(null, null)
    expect(orContainer.test(patient)).toBeTruthy()  
    orContainer.add(new queryStructure.Comparison('demographics', 'foo', 'foo', 9001, '>'))
    expect(orContainer.test(patient)).toBeFalsy()

    orContainer.add(new queryStructure.Comparison('demographics', 'foo', 'foo', 9002, '>'))
    orContainer.add(new queryStructure.Comparison('demographics', 'foo', 'foo', 8999, '>'))
    expect(orContainer.test(patient)).toBeTruthy()

  it "should create Comparison Rules", ->
    comparison = new queryStructure.Comparison('demographics', 'foo', 'foo', 9002, '>')

  it "should evaluate Comparison Rules correctly", ->
    comparison = new queryStructure.Comparison('demographics', 'foo', 'foo', 9002, '>')
    expect(comparison.test(patient)).toBeFalsy()
    comparison = new queryStructure.Comparison('demographics', 'foo', 'foo', 9000, '>')
    expect(comparison.test(patient)).toBeFalsy()
    comparison = new queryStructure.Comparison('demographics', 'foo', 'foo', 8999, '>')
    expect(comparison.test(patient)).toBeFalsy()

    comparison = new queryStructure.Comparison('demographics', 'foo', 'foo', 8999, '>')
    expect(comparison.test(patient)).toBeTruthy()

    comparison = new queryStructure.Comparison('demographics', 'foo', 'foo', 9000, '=')
    expect(comparison.test(patient)).toBeTruthy()

  it "should add containers to a container", ->

  it "should add many containers to a container", ->

  it "should remove a child container", ->

  it "should clear all children from a container", ->

  it "should find the index of a child from the children array", ->

  it "should replace a child container", ->