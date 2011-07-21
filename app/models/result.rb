class Result
  include Mongoid::Document
  
  QUEUED = 'Queued'
  FAILED = 'Failed'
  COMPLETE = 'Complete'
  
  embedded_in :execution, class_name: "Execution", inverse_of: :results

  belongs_to :endpoint
  
  field :status, type: String
  field :result_url, type: String
  field :next_poll, type: Integer
  field :value, type: Hash
  field :time, type: String
  field :error_msg, type: String
  
end