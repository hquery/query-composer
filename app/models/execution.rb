class Execution
  include Mongoid::Document
  embedded_in :query, class_name: "Query", inverse_of: :executions
  embeds_many :results, class_name: 'Result', inverse_of: :execution
  
  field :time, type: Integer
  field :aggregate_result, type: Hash
  field :notification, type: Boolean
  
  def status
    result_statuses = {}
    results.each{|result| result_statuses[result.status] ||= 0; result_statuses[result.status]+=1;}
    result_statuses
  end
  
end