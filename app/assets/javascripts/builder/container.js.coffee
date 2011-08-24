@queryStructure = @queryStructure || {};


queryStructure.createContainer= (parent, json) ->
  _ret = null
  _children = []
  if(json["and"])
    _ret =  new queryStructure.And(parent,[])
    _children = json["and"]
  else if(json["or"])
    _ret =   new queryStructure.Or(parent,[])
    _children = json["or"]
  else if(json["not"])
    _ret =   new queryStructure.Not(parent,[])
    _children = json["not"]

  for item in _children
     _ret.add(queryStructure.createContainer(_ret,item))
  
  _ret


class queryStructure.Query
  constructor: ->
    this.find = new queryStructure.And(null, new queryStructure.Or())
    this.filter = new queryStructure.And(null, new queryStructure.Or())
    this.select = []
    this.group = []
    this.aggregate = []

  toJson: -> 
    return { 'find' : this.find.toJson(), 'filter' : this.filter.toJson(), 'select' : this.select, 'group' : this.group, 'aggregate' : this.aggregate }
  
  rebuildFromJson: (@json) ->
    this.find = this.buildFromJson(null, @json['find'])
    this.filter = this.buildFromJson(null, @json['filter'])
    this.select = @json['select']
    this.group = @json['group']
    this.aggregate = @json['aggregate']
    
  buildFromJson: (@parent, @element) ->
    if this.getElementType(@element) == 'rule'
      ruleType = this.getRuleType(@element)
      if (ruleType == 'Range')
        return new queryStructure[ruleType](@element['category'], @element['title'], @element['field'], @element['start'], @element['end'])
      else if (ruleType == 'Comparison')
        return new queryStructure[ruleType](@element['category'], @element['title'], @element['field'], @element['value'], @element['comparator'])
      else
        return new queryStructure[ruleType](@element['category'], @element['title'], @element['field'], @element['value'])
    else
      container = this.getContainerType(@element)
      newContainer = new queryStructure[container](@parent, null, @element.name || null)
      for child in @element[container.toLowerCase()]
        newContainer.add(this.buildFromJson(newContainer, child))
      return newContainer
      
  getElementType: (@element) ->
    if @element['and']? || @element['or']? || @element['not']? || @element['count_n']?
      return 'container'
    else
      return 'rule'
          
  getContainerType: (@element) ->
    if @element['and']?
      return 'And'
    else if @element['or']?
      return 'Or'
    else if @element['not']?
      return 'Not'
    else if @element['count_n']?
      return 'CountN'
    else
      return null

  getRuleType: (@element) ->
    if @element['start']?
      return 'Range'
    else if @element['comparator']?
      return 'Comparison'
    else
      return 'Rule'

##############
# Containers 
##############

class queryStructure.Container
  constructor: (@parent, @children, @name) ->
    if @children?
      this.children = @children
    else
      @children = []
    this.name = @name if @name?

  add: (element, after) ->
    index = this.childIndex(after) + 1
    this.children.splice(index,0,element)
    element.parent = this
    return element

  remove: ->
    this.parent.removeChild(this)

  removeChild: (victim) ->
    for index,_child of @children
      if _child == victim
        @children.splice(i, 1)
        
  replaceChild: (child, newChild) ->
    for index,_child of @children
      if _child == child
        @children[index] = newChild
        newChild.parent = this
  
  childIndex: (child) ->
    if child == null
      return -1
    for index, _child of @children
      if _child == child
        return index
    return -1
            
  clear: ->
    children = []

class queryStructure.Or extends queryStructure.Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "or" : childJson }
  
  test: (patient) -> 
    if (this.children.length == 0)
      return true;
    for child in this.children
      if (child.test(patient)) 
        return true;
    return false;


class queryStructure.And extends queryStructure.Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    if this.name?
      return { "name" : this.name, "and" : childJson }
    else
      return { "and" : childJson }

  test: (patient) ->
    for child in this.children
      if (!child.test(patient)) 
        return false;
    return true;



class queryStructure.Not extends queryStructure.Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "not" : childJson }

    test: (patient) -> 
      for child in this.children
        if (child.test(patient)) 
          return true;
      return false;
  

class queryStructure.CountN extends queryStructure.Container
  constructor: (@parent, @n) ->
    super
  
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "n" : this.n, "count_n" : childJson }

    test: (patient) -> 
      for child in this.children
        if (child.test(patient)) 
          return true;
      return false;
    

#########
# Rules 
#########
class queryStructure.Rule
  constructor: (@category, @title, @field, @value) ->
  toJson: ->
    return { "category" : this.category, "title" : this.title, "field" : this.field, "value" : this.value }
  


class queryStructure.Range
  constructor: (@category, @title, @field, @start, @end) ->
  toJson: ->


class queryStructure.Comparison
  constructor: (@category, @title, @field, @value, @comparator) ->
  toJson: ->
    return { "category" : this.category, "title" : this.title, "field" : this.field, "value" : this.value, "comparator" : this.comparator }
  test: (patient) ->
    value = null; 
    if (this.field == 'age') 
      value = patient[this.field](new Date())
    else 
      value = patient[this.field]()
    
    if (this.comparator == '=')
      return value == this.value
    else if (this.comparator == '<')
      return value < this.value
    else 
      return value > this.value
    

#########
# Fileds 
#########
class queryStructure.Field
  constructor: (@title, @callstack) ->
  toJson: ->
    return { "title" : this.title, "callstack" : this.callstack }
  extract: (patient) -> 
    # TODO: this needs to be a little more intelligent - AQ
    return patient[callstack]();
