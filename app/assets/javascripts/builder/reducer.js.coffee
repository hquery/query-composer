reducer = @reducer || {}

class reducer.Value
  constructor: (@values, @rereduced) ->
  
  sum: (title, element) ->
    if (!@rereduced)
      @values[title + '_sum'] = 0
    if (!element.rereduced)
      element.values[title + '_sum'] = 0
    @values[title + '_sum'] += element.values[title] + element.values[title + '_sum']
  
  frequency: (title, element) ->
    if (!@rereduced)
      @values[title + '_frequency'] = {}
    if (!element.rereduced)
      element.values[title + '_frequency'] = {}
      key = ('' + element.values[title]).replace('.', '~') # Mongo doesn't seem to accept hash keys with decimals in our rereducable values.
      element.values[title + '_frequency'][key] = 1
    for k, v of element.values[title + '_frequency']
      if @values[title + '_frequency'][key]?
        @values[title + '_frequency'][key] += 1
      else
        @values[title + '_frequency'][key] = 1
  
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
      element.values[title + '_median_list'] = [element.values[title]]
    i = 0
    while i < @values[title + '_median_list'].length && element.values[title + '_median_list'].length > 0
      while element.values[title + '_median_list'].length > 0 && element.values[title + '_median_list'][0] < @values[title + '_median_list'][i]
        front_value = (element.values[title + '_median_list'].splice(0, 1))[0]
        @values[title + '_median_list'].splice(i, 0, front_value)
        i++
      i++
    for value in element.values[title + '_median_list']
      @values[title + '_median_list'].splice(@values[title + '_median_list'].length, 0, value)
    if (@values[title + '_median_list'].length % 2 == 0)
      leftCenter = @values[title + '_median_list'][Math.floor(@values[title + '_median_list'].length / 2)]
      rightCenter = @values[title + '_median_list'][Math.floor(@values[title + '_median_list'].length / 2) - 1]
      @values[title + '_median'] = (leftCenter + rightCenter) / 2
    else
      @values[title + '_median'] = @values[title + '_median_list'][Math.floor(@values[title + '_median_list'].length / 2)]

  mode: (title, element) ->
    if (!@rereduced)
      @values[title + '_mode_frequency'] = {}
    if (!element.rereduced)
      element.values[title + '_mode_frequency'] = {}
      key = ('' + element.values[title]).replace('.', '~') # Mongo doesn't seem to accept hash keys with decimals in our rereducable values
      element.values[title + '_mode_frequency'][key] = 1
    for key, value of element.values[title + '_mode_frequency']
      if @values[title + '_mode_frequency'][key]?
        @values[title + '_mode_frequency'][key] += 1
      else
        @values[title + '_mode_frequency'][key] = 1
    most_frequent_key = []
    most_frequent_value = 0
    for key, value of @values[title + '_mode_frequency']
      if value == most_frequent_value
        most_frequent_key.push(key)
      else if value > most_frequent_value
        most_frequent_key = [key]
        most_frequent_value = value
    @values[title + '_mode'] = most_frequent_key