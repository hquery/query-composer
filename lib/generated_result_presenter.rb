class GeneratedResultPresenter < ResultPresenter
  attr_reader :target_population, :filtered_population, :total_population

  def initialize(title, result_hash)
    super(title, result_hash)

    if result_hash.present?
      # Reset the work done in super
      @keys = []
      @values = []
      # Ugly hack for now
      result_hash['Results'].values.first.values.first.each_pair do |key, value|
        @keys << key
        @values << value
      end

      @target_population = result_hash['Populations']['Target Population']
      @filtered_population = result_hash['Populations']['Filtered Population']
      @total_population = result_hash['Populations']['Total Population']
    end
  end


end