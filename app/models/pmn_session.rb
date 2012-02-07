class PmnSession
  include Mongoid::Document

  embedded_in :execution

  field :return_url, type: String
  field :service_url, type: String
  field :session_token, type: String
  field :request_id, type: String
end