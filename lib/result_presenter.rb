class ResultPresenter
  attr_reader :title, :keys, :values
  
  def initialize(title, result_hash)
    @title = title
    if result_hash
      @exist = true
      @keys = []
      @values = []
      @result_hash = result_hash
      each_pair do |key, value|
        @keys << key
        @values << value
      end
    else
      @exist = false
      @result_hash = {}
    end
  end
  
  def key_javascript_array
    key_list = keys.map {|k| "\"#{k}\""}.join(', ')
    "[#{key_list}]"
  end
  
  def value_javascript_array
    "[#{values.join(', ')}]"
  end
  
  def each_pair
    @result_hash.each_pair do |key, value|
      next if ['_id', 'created_at', 'query_id'].include? key
      yield key, value
    end
  end
  
  def exist?
    @exist
  end
end