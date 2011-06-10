class Endpoint
  include Mongoid::Document
  embedded_in :query, class_name: "Query", inverse_of: :endpoints
  
  field :name, type: String
  field :status, type: String
  field :submit_url, type: String
  field :result_url, type: String
  field :next_poll, type: Integer
  field :result, type: Hash
end