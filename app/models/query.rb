class Query
  include Mongoid::Document
  embeds_many :endpoints, class_name: 'Endpoint', inverse_of: :query
  
  field :title, type: String
  field :description, type: String
  field :map, type: String
  field :reduce, type: String
  field :status, type: String
end