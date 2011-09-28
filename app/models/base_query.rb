class BaseQuery
  include Mongoid::Document
  store_in :queries
  
  field :title, type: String
  field :description, type: String
  field :filter, type: String
  field :map, type: String
  field :reduce, type: String
  field :query_structure, type: Hash

  field :generated, type: Boolean
  
  validates_presence_of :title
  
end
