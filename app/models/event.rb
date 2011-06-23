class Event
  include Mongoid::Document
  store_in :poll_job_log_events
  
  belongs_to :query
  
  field :time, type: String
  field :message, type: String
end