class GeneratedResultPresenter < ResultPresenter
  attr_reader :group_order

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
    end
  end
end