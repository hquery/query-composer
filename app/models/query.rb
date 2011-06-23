class Query
  include Mongoid::Document
  
  belongs_to :user
  has_many :events
  has_and_belongs_to_many :endpoints
  
  field :title, type: String
  field :description, type: String
  field :filter, type: String
  field :map, type: String
  field :reduce, type: String
  field :status, type: String
  field :aggregate_result, type: Hash  
end