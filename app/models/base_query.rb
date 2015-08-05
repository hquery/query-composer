class BaseQuery
  include Mongoid::Document
  store_in collection: 'queries'
  
  field :title, type: String
  field :description, type: String
  field :filter, type: String
  field :map, type: String
  field :reduce, type: String
  field :query_structure, type: Hash

  field :generated, type: Boolean
  
  validates_presence_of :title

  def self.find_by_description(desc)
    where(description: desc).first
  end

  
end
