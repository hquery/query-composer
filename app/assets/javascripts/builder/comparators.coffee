@comparators ||= {}


@comparators.contains =  (a,b) ->
  a =  if a instanceof Array then a else [a]
  for val in a
    for x in b
      if val == x
        val
  results.length > 0
        
@comparators.inRange = (a,b) ->
  @comparators.gt_equal(a,b[0]) && @comparators.lt_equal(a,b[1])

@comparators.equal = (a,b) ->
  a == b
@comparators.not_equal = (a,b) ->
  a != b

@comparators.gt = (a,b) ->
  a > b
  
@comparators.gt_equal = (a,b) ->
  a >=b

@comparators.lt = (a,b) ->
  a < b
  
@comparators.lt_equal = (a,b) ->
  a <= b