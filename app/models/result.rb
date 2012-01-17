class Result
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :execution

  field :value, type: Hash
  field :aggregated, type: Boolean

end