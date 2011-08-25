require 'gateway_utils'

class Execution
  include Mongoid::Document
  include GatewayUtils

  embedded_in :query
  has_many :results

  field :time, type: Integer              # execution time
  field :aggregate_result, type: Hash     # final aggregated result
  field :notification, type: Boolean      # if the user wants to be notified by email when the result is ready

  def status
    result_statuses = {}
    results.each{|result| result_statuses[result.status] ||= 0; result_statuses[result.status]+=1;}
    result_statuses
  end

  def execute(endpoints)
    endpoints.each do |endpoint|
      query.user.save_library_functions_locally unless query.user.library_functions.empty?
      post_library_function(endpoint)
      query_url = submit(endpoint)
      if query_url
        Result.create(endpoint: endpoint, query_url: query_url,
                      status: Result::QUEUED, execution: self)
      else
        Result.create(endpoint: endpoint,
                      status: Result::FAILED, execution: self)
      end
    end
  end

  def finished?
    unfinished_results.empty?
  end

  def unfinished_results
    results.where(status: Result::QUEUED)
  end

  def cancel
    results.each {|result| result.cancel}
  end
end