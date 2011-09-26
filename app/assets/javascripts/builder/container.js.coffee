@queryStructure ||= {}


class queryStructure.Query
  constructor: ->
    @find = new queryStructure.And(null)
    @filter = new queryStructure.And(null)
    @extract = new queryStructure.Extraction([], [])

  toJson: -> 
    return { 'find' : @find.toJson(), 'filter' : @filter.toJson(), 'extract' : @extract.toJson() }
  
  rebuildFromJson: (json) ->
    @find = if json['find'] then @buildFromJson(null, json['find']) else new queryStructure.And(null)
    @filter = if json['filter'] then @buildFromJson(null, json['filter'] ) else new queryStructure.And(null)
    @extract = if json['extract'] then queryStructure.Extraction.rebuildFromJson(json['extract']) else new queryStructure.Extraction([], [])
    
  buildFromJson: (parent, element) ->
    if @getElementType(element) == 'rule'
      ruleType = element.type
      return new queryStructure[ruleType](element.data)
    else
      container = @getContainerType(element)
      newContainer = new queryStructure[container](parent, [], element.name, element.title, element.negate)
      for child in element[container.toLowerCase()]
        newContainer.add(@buildFromJson(newContainer, child))
      return newContainer
      
  getElementType: (element) ->
    if element['and']? || element['or']? || element['not']? || element['count_n']?
      return 'container'
    else
      return 'rule'
          
  getContainerType: (element) ->
    if element['and']?
      return 'And'
    else if element['or']?
      return 'Or'
    else if element['not']?
      return 'Not'
    else if element['count_n']?
      return 'CountN'
    else
      return null

  getRuleType: (element) ->
    if element['start']?
      return 'Range'
    else if element['comparator']?
      return 'Comparison'
    else
      return 'Rule'

##############
# Containers 
##############

class queryStructure.Container
  constructor: (@parent, @children = [], @name, @title, @negate = false) ->
    @children ||= []

  add: (element, after) ->
    # first see if the element is already part of the children array
    # if it is there is no need to do anything
    index = @children.length
    ci = @childIndex(after)
    if ci != -1
      index = ci + 1
    @children.splice(index,0,element)
    if element.parent && element.parent != this
      element.parent.removeChild(element)
    element.parent = this
    return element
 
  addAll: (items, after) ->
    for item in items
      after = @add(item,after)
      
  remove: ->
    if @parent
      @parent.removeChild(this)

  removeChild: (victim) ->
    index = @childIndex(victim)
    if index != -1
      @children.splice(index,1)
      victim.parent = null
        
  replaceChild: (child, newChild) ->
    index = @childIndex(child)
    if index != -1
      @children[index] = newChild
      child.parent = null
      newChild.parent = this
  
  moveBefore: (child, other) ->
    i1 = @childIndex(child)
    i2 = @childIndex(other)
    if i1 != -1 && i2 != -1
      child = @children.splice(i2, 1)
      @children.splice(i1-1,0,other)
      return true
    
    return false
      
  childIndex: (child) ->
    if child == null
      return -1
    for index, _child of @children
      if _child == child
        return index
    return -1
            
  clear: ->
    children = []
    
  childrenToJson: ->
     childJson = [];
     for child in @children
       js = if child["toJson"] then  child.toJson() else child
       childJson.push(js )
     return childJson
      

class queryStructure.Or extends queryStructure.Container
  toJson: ->
    childJson = @childrenToJson()
    return { "name" : @name, "or" : childJson, "negate" : @negate, "title" : @title }
  
  test: (patient) -> 
    if (@children.length == 0)
      return true;
    retval = false  
    for child in @children
      if (child.test(patient)) 
        retval = true
        break
    return if @negate then !retval else retval;


class queryStructure.And extends queryStructure.Container
  toJson: ->
    childJson = @childrenToJson()
    return { "name" : @name, "and" : childJson, "negate" : @negate, "title" : @title }


  test: (patient) ->
    if (@children.length == 0)
      return true;
    retval = true  
    for child in @children
      if (!child.test(patient)) 
        retval =  false
        break
        
    return if @negate then !retval else retval




class queryStructure.CountN extends queryStructure.Container
  constructor: (@parent, @n) ->
    super
  
  toJson: ->
    childJson = [];
    for child in @children
      childJson.push(child.toJson())
    return { "n" : @n, "count_n" : childJson }

    test: (patient) -> 
      for child in @children
        if (child.test(patient)) 
          return true;
      return false;
    

#########
# Rules 
#########
class queryStructure.Rule
  constructor: (@type, @data) ->
  toJson: ->
    return { "type" : @type, "data" : @data }
    


class queryStructure.Range
  constructor: (@category, @title, @field, @start, @end) ->
  toJson: ->


class queryStructure.Comparison
  constructor: (@category, @title, @field, @value, @comparator) ->
  toJson: ->
    return { "category" : @category, "title" : @title, "field" : @field, "value" : @value, "comparator" : @comparator }
  test: (patient) ->
    value = null; 
    if (@field == 'age') 
      value = patient[@field](new Date())
    else 
      value = patient[@field]()
    
    if (@comparator == '=')
      return value == @value
    else if (@comparator == '<')
      return value < @value
    else 
      return value > @value
    

#########
# Fileds 
#########
class queryStructure.Field
  constructor: (@title, @callstack) ->
  toJson: ->
    return { "title" : @title, "callstack" : @callstack }
  extract: (patient) -> 
    # TODO: this needs to be a little more intelligent - AQ
    return patient[callstack]();

class queryStructure.Group extends queryStructure.Field
  constructor: (@title, @callstack) ->
  rebuildFromJson: (json) ->
    return new queryStructure.Group(json['title'], json['callstack'])

class queryStructure.Selection extends queryStructure.Field
  constructor: (@title, @callstack, @aggregation) ->
  toJson: ->
    return { "title" : @title, "callstack" : @callstack, 'aggregation' : @aggregation }
  rebuildFromJson: (json) ->
    return new queryStructure.Selection(json['title'], json['callstack'], json['aggregation'])

class queryStructure.Extraction
  constructor: (@selections, @groups) ->
  toJson: ->
    selectJson = []
    groupJson = []
    for selection in @selections
      selectJson.push(selection.toJson())
    for group in @groups
      groupJson.push(group.toJson())
    return { "selections" : selectJson, "groups" : groupJson }
  rebuildFromJson: (json) ->
    selections = []
    groups = []
    for selection in json['selections']
      selections.push(queryStructure.Selection.rebuildFromJson(selection))
    for group in json['groups']
      groups.push(queryStructure.Group.rebuildFromJson(group))
    return new queryStructure.Extraction(selections, groups)
