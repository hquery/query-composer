class GeneratedResultPresenter < ResultPresenter
  attr_reader :group_order

  def initialize(title, result_hash)
    super(title, result_hash)
    @group_order = []
    @grouped_values = {}
    groupify
  end

  def key_javascript_array
    @grouped_values.keys.to_json
  end

  def value_javascript_array
    @grouped_values.values.to_json
  end

  private
  def population_free_each_pair
    each_pair do |key, value|
      next if key.eql? 'Populations'
      yield key, value
    end
  end

  # Populates the group_order and grouped_values instance variables
  # grouped_values is a hash. The key will be an attribute of a patient 
  # and its grouping, such as "age_mean".
  # The value will be an array of values for that group. Following from the example
  # above, age_mean would contain a list of mean ages 
  def groupify
    population_free_each_pair do |population_group, value|
      @group_order << population_group
      value.each_pair do |population_attribute, inner_value|
        inner_value.each_pair do |math_function, resulting_value|
          @grouped_values[population_attribute + '_' + math_function] ||= []
          @grouped_values[population_attribute + '_' + math_function] << resulting_value
        end
      end
    end
  end
end