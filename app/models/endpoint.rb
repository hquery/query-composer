require 'rss'

class Endpoint
  include Mongoid::Document

  SUBMIT_PATH = 'queues'
  FUNCTIONS_PATH = 'library_functions'

  has_many :endpoint_logs
  has_many :results

  validates_presence_of :name, :base_url

  field :name, type: String
  field :base_url, type: String
  field :last_check, type: DateTime

  def submit_url
    @parsed_base ||= URI.parse(base_url)
    @parsed_base.merge(SUBMIT_PATH)
  end

  def functions_url
    @parsed_base ||= URI.parse(base_url)
    @parsed_base.merge(FUNCTIONS_PATH)
  end
  
  def unfinished_results?
    active_results_for_this_endpoint.present?
  end
  
  def check
    begin
      url = submit_url
      response = Net::HTTP.start(url.host, url.port) do |http|
        http['If-Modified-Since'] = last_check.to_formatted_s(:rfc822)
        http['Accept'] = 'application/atom+xml'
        http.get(url.path)
      end
      
      case response
      when Net::HTTPSuccess
        endpoint_logs.create(status: :update, message: 'Feed changed, updating')
        update_queries(response.body)
        update_attribute(:last_check, Time.now)
      when Net::HTTPNotModified
        endpoint_logs.create(status: :not_modified, message: 'No changes')
        update_attribute(:last_check, Time.now)
      else
        endpoint_logs.create(status: :error, message: "Did not understand the response: #{response}")
      end
    rescue Exception => ex
      endpoint_logs.create(status: :error, message: "Error executing HTTP request: #{response}")
    end
  end
  
  def update_results(atom_feed)
    parsed_feed = RSS::Parser.parse(atom_feed)
    parsed_feed.entries.each do |atom_entry|
      query_url = atom_entry.id.try(:content)
      query_update_time = atom_entry.updated.try(:content)
      result = active_results_for_this_endpoint.where(:query_url =>  query_url, :updated_at.lt => query_update_time)
      if result
        result.check()
      end
    end
  end
  
  private
  
  def active_results_for_this_endpoint
    results.any_in(status: [Result::RUNNING, Result::QUEUED])
  end
end