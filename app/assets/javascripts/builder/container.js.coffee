this.hQuery ||= {}

console.log(this)
hQuery.createContainer= (parent, json) ->
  _ret = null
  _children = []
  if(json["and"])
    _ret =  new hQuery.AndContainer(parent,json["and"])
    _children = json["and"]
  else if(json["or"])
    _ret =   new hQuery.OrContainer(parent,json["or"])
    _children = json["or"]
  else if(json["not"])
    _ret =   new hQuery.NotContainer(parent,json["not"])
    _children = json["not"]

  for item in _children
     _ret.add(hQuery.createContainer(_ret,item))
  
  _ret



class hQuery.Container
  constructor: (@parent, json) ->
    this.children = []
    
    
  add: (element) ->
    element.parent = this
    this.children.push(element)
  
    
  remove: ->
    this.parent.removeChild(this)
  
    
  removeChild: (victim) ->
    for i in children
      if children[i] == victim
        children.splice(i, 1)
  
    
  clear: ->
    children = []
 
 
  childrenAsJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    
 
  


class hQuery.OrContainer extends hQuery.Container
  contructor: (@parent,json) ->
    super
    this.conjunction = "or"
        
  toJson: -> 
    return {"or" : this.childrenAsJson() }    
  
  test: ->
   

class hQuery.NotContainer extends hQuery.Container
  contructor: (@parent,json) ->
    super
    
  toJson: ->
    return { "not": this.childrenAsJson() }  
 
  test: ->
  


class hQuery.CountNContainer extends hQuery.Container
  constructor: (@parent, @n) ->
    super
  
  toJson: ->
    return { "n" : this.n, "count_n" : this.childrenAsJson() }

  test: ->
    
  

  
class hQuery.AndContainer extends hQuery.Container
  contructor: (@parent,json) ->
    super
    
  toJson: ->
    return { "and" : this.childrenAsJson() }
  
  test: ->



class hQuery.Rule
  constructor: -> (@category @title @name @value)

  toJson: ->
    return { "category" : this.category, "title" : this.title, "name" : this.name, "value" : this.value }
  


class hQuery.RangeRule
  constructor: -> (@category @title @name @start @end)

  toJson: ->


class hQuery.ComparisonRule
  constructor: -> (@category @title @name @value @comparator)

  toJson: ->


