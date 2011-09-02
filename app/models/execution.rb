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
      if query.user.library_functions.present?
        query.user.save_library_functions_locally
        post_library_function(endpoint, query.user)
      end
      
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
  
  # ===============
  # = Aggregation =
  # ===============
  def aggregate
    response = Result.collection.map_reduce(self.map_fn(), query.reduce, :raw => true, :out => {:inline => true}, :query => {:execution_id => id})
    results = response['results']
    if results
      self.aggregate_result = {}
      results.each do |result|
        self.aggregate_result[result['_id']] = result['value']
      end
      save!
    end
  end

  def map_fn
    <<END_OF_FN
    function() {
      #{js_to_localize_user_functions(query.user)}
        if (this.status == "#{Result::COMPLETE}") {
          for(var key in this.value) {
            if (key != "_id") {
              emit(key, this.value[key]);
            }
          }
        }
      }
END_OF_FN
    end
end