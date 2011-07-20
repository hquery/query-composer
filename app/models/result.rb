class Result
  COMPLETE = "Complete"
  FAILED = "Failed"
  QUEUED =  "Queued"
  include Mongoid::Document
  embedded_in :execution, class_name: "Execution", inverse_of: :results

  belongs_to :endpoint
  
  field :status, type: String
  field :result_url, type: String
  field :next_poll, type: Integer
  field :value, type: Hash
  field :time, type: String
  
end