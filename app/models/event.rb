class Event
  include Mongoid::Document
  store_in :poll_job_log_events

  field :query, type: BSON::ObjectId
  field :time, type: String
  field :message, type: String
end