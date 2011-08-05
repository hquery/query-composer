module QueriesHelper
  def jsonify(value)
    if value.class==Hash || value.class==Array
      JSON.pretty_generate(value)
    else
      value
    end
  end
  
  # This method is used by the query builder to determine the kind of operation for each element in the query structure.
  def get_builder_operation(element)
    if element.include? 'and'
      return 'and'
    elsif element.include? 'or'
      return 'or'
    elsif element.include? 'count_n'
      return 'count_n'
    else
      return 'rule'
    end
  end
end
