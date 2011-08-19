@queryStructure = @queryStructure || {};

class queryStructure.Query
  constructor: ->
    this.find = new queryStructure.And(null, new queryStructure.Or())
    this.filter = new queryStructure.And(null, new queryStructure.Or())
    this.select = []
    this.group = []
    this.aggregate = []

  toJson: -> 
    return { 'find' : this.find.toJson(), 'filter' : this.filter.toJson(), 'select' : this.select, 'group' : this.group, 'aggregate' : this.aggregate }

##############
# Containers 
##############
class queryStructure.Container
  constructor: (@parent, @children) ->
    if @children?
      this.children = @children
    else
      this.children = []

  add: (element) ->
    this.children.push(element)
    return element;

  remove: ->
    this.parent.removeChild(this)

  removeChild: (victim) ->
    for i in children
      if children[i] == victim
        children.splice(i, 1)

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
    return  patient[this.field]() == this.value

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