reducer = @reducer || {}

class reducer.Value
  constructor: (@values, @rereduced) ->
  
  sum: (title, element) ->
    if (!@rereduced)
      @values[title + '_sum'] = 0
    if (!element.rereduced)
      element.values[title + '_sum'] = 0
    @values[title + '_sum'] += element.values[title] + element.values[title + '_sum']
  
  mean: (title, element) ->
    if (!@rereduced)
      @values[title + '_mean'] = 0
      @values[title + '_mean_count'] = 0
    if (!element.rereduced)
      element.values[title + '_mean'] = element.values[title]
      element.values[title + '_mean_count'] = 1
    previousTotal = @values[title + '_mean'] * @values[title + '_mean_count']
    elementTotal = element.values[title + '_mean'] * element.values[title + '_mean_count']
    total = previousTotal + elementTotal
    count = @values[title + '_mean_count'] + element.values[title + '_mean_count']
    @values[title + '_mean_count'] = count
    @values[title + '_mean'] = total / count
    
  median: (title, element) ->
    if (!@rereduced)
      @values[title + '_median_list'] = []
    if (!element.rereduced)
      element.values[title + '_median_list'] = element.values[title]
    i = 0
    while (i < @values[title + '_median_list'].length && element.values[title + '_median_list'][0] > @values[title + '_median_list'][i])
      i++
    @values[title + '_median_list'].splice(i, 0, element.values[title + '_median_list'])
    if (@values[title + '_median_list'].length % 2 == 0)
      leftCenter = @values[title + '_median_list'][Math.floor(@values[title + '_median_list'].length / 2)]
      rightCenter = @values[title + '_median_list'][Math.floor(@values[title + '_median_list'].length / 2) - 1] 
      @values[title + '_median'] = (leftCenter + rightCenter) / 2
    else
      @values[title + '_median'] = @values[title + '_median_list'][@values[title + '_median_list'].length / 2]
  
  ###
  mode: (title, element) ->
    # counts of all, most frequent
    if (!@rereduced)
      @values[title + '_mode'] = 0
      @values[title + '_mode_counts'] = {}
    if (!element.rereduced)
      element.values[title + '_mode'] = element.values[title]
      element.values[title + '_median_list'] = { element.values[title] : 1 }
  ###
    
  frequency: (title, element) ->
    if (!@rereduced)
      @values[title + '_frequency'] = 
        {}
    if (!element.rereduced)
      element.values[title + "_frequency"] = 
        {}
      element.values[title + "_frequency"]["'#{ element.values[title] }'"] = 1
    for key,value of element.values[title + '_frequency']
      @values[title + '_frequency']["\"11\""] = key
      #if @values[title + '_frequency']["'#{ key }'"]?
        #@values[title + '_frequency']["'#{ key }'"] += value
      #else
      #@values[title + '_frequency']["#{ key }"] = value