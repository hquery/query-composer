class Container
  constructor: (@parent) ->
    this.children = []
  
    
  add: (element) ->
    this.children.push(element)
  
    
  remove: ->
    this.parent.removeChild(this)
  
    
  removeChild: (victim) ->
    for i in children
      if children[i] == victim
        children.splice(i, 1)
  
    
  clear: ->
    children = []
  


class OrContainer extends Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "or" : childJson }
  
  test: ->
   

class NotContainer extends Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "not" : childJson }

  test: ->
  


class CountNContainer extends Container
  constructor: (@parent, @n) ->
    super
  
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "n" : this.n, "count_n" : childJson }

  test: ->
    
  

  
class AndContainer extends Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "and" : childJson }
  
  test: ->



class Rule
  constructor: -> (@category @title @name @value)

  toJson: ->
    return { "category" : this.category, "title" : this.title, "name" : this.name, "value" : this.value }
  


class RangeRule
  constructor: -> (@category @title @name @start @end)

  toJson: ->


class ComparisonRule
  constructor: -> (@category @title @name @value @comparator)

  toJson: ->


container = new OrContainer(null)
container.add(new AndContainer(null))
container.add(new OrContainer(null))