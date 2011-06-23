class Query
  include Mongoid::Document
  embeds_many :endpoints, class_name: 'Endpoint', inverse_of: :query
  
  belongs_to :user
  has_many :events
  
  field :title, type: String
  field :description, type: String
  field :filter, type: String
  field :map, type: String
  field :reduce, type: String
  field :status, type: String
  field :aggregate_result, type: Hash  
end