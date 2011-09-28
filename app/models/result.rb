class Result
  include Mongoid::Document
  include Mongoid::Timestamps

  QUEUED = 'queued'
  FAILED = 'failed'
  COMPLETE = 'complete'
  CANCELED = 'canceled'
  RUNNING = 'running'
  RESCHEDULED = 'rescheduled'
  FETCHING_RESULT = 'fetching_result'

  belongs_to :execution
  belongs_to :endpoint

  field :status, type: String
  field :result_url, type: String
  field :query_url, type: String
  field :value, type: Hash
  field :error_msg, type: String
  field :aggregated, type: Boolean

  def cancel
    if self.status.nil? || self.status == Result::QUEUED
      update_attribute(:status, CANCELED)
    end
  end
  
  def check
    url = URI.parse(query_url)
    response = Net::HTTP.start(url.host, url.port) do |http|
      http.get(url.path, 'If-Modified-Since' => updated_at.to_formatted_s(:rfc822))
    end
    
    case response
    when Net::HTTPSuccess
      response_json = JSON.parse(response.body)
      query_status = response_json['status']
      if query_status == COMPLETE
        self.status = FETCHING_RESULT
        self.result_url = response_json['result_url']
        save!
        fetch_result
      else
        if self.status != query_status
          self.status = query_status
          save!
        else
          self.update_attribute(:created_at, Time.now)          
        end
      end
    when Net::HTTPNotModified
      self.update_attribute(:created_at, Time.now)
    else
      self.error_msg = "Unknown response: #{response}"
      save!
    end
  end
  
  def fetch_result
    response = Net::HTTP.get(URI.parse(self.result_url))
    self.value = JSON.parse(response)
    self.status = COMPLETE
    save!
  end
end