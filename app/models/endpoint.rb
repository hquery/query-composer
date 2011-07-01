class Endpoint
  include Mongoid::Document

  has_and_belongs_to_many :queries
  
  field :name, type: String
  field :submit_url, type: String
end