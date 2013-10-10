require 'rss'
require 'net/http'

class Endpoint
  include Mongoid::Document

  SUBMIT_PATH = 'queries'
  FUNCTIONS_PATH = 'library_functions'
  STATUS_PATH = 'queries'

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
  
  def status_url
    @parsed_base ||= URI.parse(base_url)
    @parsed_base.merge(STATUS_PATH)
  end
  
  def unfinished_results?
    active_results_for_this_endpoint.present?
  end
  
  def check
    url = submit_url
    begin
      check_time = Time.now

      #use ssl
      response = Net::HTTP.start(url.host, url.port, :use_ssl => USE_SSL_CLIENT, :key => CLIENT_KEY, :cert => CLIENT_CERT) do |http|
        headers = {}
        #if last_check
        #  headers['If-Modified-Since'] = last_check.to_formatted_s(:rfc822)
        #end
        headers['Accept'] = 'application/atom+xml'
        http.get(url.path, headers)
      end

      case response
      when Net::HTTPSuccess
        endpoint_logs.create(status: :update, message: 'Feed changed, updating')
        update_results(response.body)
        update_attribute(:last_check, check_time)
      when Net::HTTPNotModified
        endpoint_logs.create(status: :not_modified, message: 'No changes')
        update_attribute(:last_check, check_time)
      else
        endpoint_logs.create(status: :error, message: "Did not understand the response: #{response}")
      end
    rescue Exception => ex
      endpoint_logs.create(status: :error, message: "endpoint check failed: #{ex}")
    end
  end
  
  def update_results(atom_feed)
    parsed_feed = RSS::Parser.parse(atom_feed)
    parsed_feed.entries.each do |atom_entry|
      query_url = atom_entry.id.try(:content)
      query_update_time = atom_entry.updated.try(:content)
      #result = active_results_for_this_endpoint.where(:query_url => query_url, :updated_at.lt => query_update_time).first
      result = active_results_for_this_endpoint.where(:query_url => query_url).first
      if result
        result.check()
        if (result.status == Result::COMPLETE)
          get_execution(result).try(:aggregate)
          result.aggregated = true;
        end
      end
    end
  end
  
  private
  
  def get_execution result
    Query.where("executions._id" => result.execution_id).first.executions.find(result.execution_id) if result.execution_id
  end

  def active_results_for_this_endpoint
    results.any_in(status: [Result::RUNNING, Result::QUEUED])
  end
end
