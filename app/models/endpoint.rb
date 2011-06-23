class Endpoint
  include Mongoid::Document

  has_and_belongs_to_many :queries
  
  field :name, type: String
  field :status, type: String
  field :submit_url, type: String
  field :result_url, type: String
  field :next_poll, type: Integer
  field :result, type: Hash
end