class BaseQuery
  include Mongoid::Document
  store_in :queries
   
  field :title, type: String
  field :description, type: String
  field :filter, type: String
  field :map, type: String
  field :reduce, type: String
  
  validates_presence_of :title
  
end
