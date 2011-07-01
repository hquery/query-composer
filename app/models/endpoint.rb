class Endpoint
  include Mongoid::Document

  has_and_belongs_to_many :queries
  
  validates_presence_of :name, :submit_url
  
  field :name, type: String
  field :submit_url, type: String
end