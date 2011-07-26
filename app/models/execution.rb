class Execution
  include Mongoid::Document
  embedded_in :query, class_name: "Query", inverse_of: :executions
  embeds_many :results, class_name: 'Result', inverse_of: :execution
  
  field :time, type: Integer              # exection time
  field :aggregate_result, type: Hash     # final aggregated result
  field :notification, type: Boolean      # if the user wants to be notified by email when the result is ready
  
  def status
    result_statuses = {}
    results.each{|result| result_statuses[result.status] ||= 0; result_statuses[result.status]+=1;}
    result_statuses
  end
  
  def execute()
    
    query.endpoints.each do |endpoint|
      self.results << Result.new(endpoint: endpoint)
    end
    
    PollJob.submit_all(self)
    
  end
  
  def finished?
    unfinished_results.count == 0
  end
  
  def unfinished_results
    results.select {|result| result.status == Result::QUEUED}
  end
  
  def cancel
    results.each {|result| result.cancel}
  end

end