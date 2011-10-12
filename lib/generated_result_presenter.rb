class GeneratedResultPresenter < ResultPresenter
  attr_reader :target_population, :filtered_population, :total_population

  def initialize(title, result_hash)
    super(title, result_hash)

    if result_hash.present?
      # Reset the work done in super
      @keys = []
      @values = []
      
      results = result_hash['Results'] || {}
      find_bottom_hash(results).each_pair do |key, value|
        @keys << key
        @values << value
      end

      @target_population = result_hash['Populations']['Target Population']
      @filtered_population = result_hash['Populations']['Filtered Population']
      @total_population = result_hash['Populations']['Total Population']
    end
  end

  private
  # Results from generated queries will come back as hashes that can be
  # nested to arbitrary depths. This method will attempt to find the 
  # deepest hash, which is where the results should be.
  def find_bottom_hash(result_hash)
    if result_hash.values.first.kind_of? Hash
      find_bottom_hash(result_hash.values.first)
    else
      result_hash
    end
  end
end