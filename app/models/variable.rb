class Variable
  def self.all
    return HQUERY_VARIABLES
  end
  
  def self.find variable_name
    return HQUERY_VARIABLES[variable_name]
  end
end