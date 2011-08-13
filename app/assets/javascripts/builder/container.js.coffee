queryBuilder = {}

class queryBuilder.Container
  constructor: (@parent) ->
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

class queryBuilder.Or extends queryBuilder.Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "or" : childJson }
  
  test: (patient) -> 
    for child in this.children
      if (child.test(patient)) 
        return true;
    return false;


class queryBuilder.And extends queryBuilder.Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "and" : childJson }

  test: ->
    for child in this.children
      if (!child.test(patient)) 
        return false;
    return true;



class queryBuilder.Not extends queryBuilder.Container
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "not" : childJson }

  test: ->
  

class queryBuilder.CountN extends queryBuilder.Container
  constructor: (@parent, @n) ->
    super
  
  toJson: ->
    childJson = [];
    for child in this.children
      childJson.push(child.toJson())
    return { "n" : this.n, "count_n" : childJson }

  test: ->
    

class queryBuilder.Rule
  constructor: (@category, @title, @field, @value) ->

  toJson: ->
    return { "category" : this.category, "title" : this.title, "name" : this.name, "value" : this.value }
  


class queryBuilder.Range
  constructor: (@category, @title, @field, @start, @end) ->
  toJson: ->


class queryBuilder.Comparison
  constructor: (@category, @title, @field, @value, @comparator) ->
  toJson: ->
  test: (patient) -> 
    return  patient[this.field]() == this.value

