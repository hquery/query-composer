class EndpointLog
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  belongs_to :endpoint
  
  field :message, :type => String
  field :status, :type => Symbol
end