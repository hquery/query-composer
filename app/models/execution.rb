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
    response = Result.collection.map_reduce(self.map_fn, query.reduce, :raw => true, :out => {:inline => true}, :query => {:execution_id => id})
    results = response['results']
    if results
      self.aggregate_result = {}
      results.each do |result|
        result = prettify_generated_result(result) if self.query.generated? && result['value']['rereduced']
        self.aggregate_result[result['_id']] = result['value']
      end
      save!
    end
  end
  
  # The generated queries create some ugly values to accomplish aggregation. Here that mess is cleaned up into a readable result.
  def prettify_generated_result(result)
    pretty_result = {}
    pretty_key = ""
    pretty_values = {}
    if (result['_id'] =~ /type_population/)
      pretty_key = "Populations"
      pretty_values = {
        'Target Population' => result['value']['values']['target_pop_sum'],
        'Filtered Population' => result['value']['values']['filtered_pop_sum'],
        'Unfound Population' => result['value']['values']['unfound_pop_sum'],
        'Total Population' => result['value']['values']['total_pop_sum']
      }
    elsif (result['_id'] =~ /type_group/)
      self.query.query_structure['extract']['groups'].each do |group|
        pretty_key << group['title'].capitalize
        result['_id'].match(/#{group['title']}_(.*)/) # Grab the value of the group (e.g., if group is gender, we find either "M" or "F")
        pretty_key << ": #{$1}"
        pretty_key << ", " unless (group == self.query.query_structure['extract']['groups'].last)
      end
      self.query.query_structure['extract']['selections'].each do |selection|
        pretty_values[selection['title']] = {}
        selection['aggregation'].each do |aggregation|
          case aggregation
          when "sum"
            pretty_values[selection['title']]['sum'] = result['value']['values'][selection['title'] + '_sum']
          when "frequency"
            pretty_values[selection['title']]['frequency'] = result['value']['values'][selection['title'] + '_frequency']
          when "mean"
            pretty_values[selection['title']]['mean'] = result['value']['values'][selection['title'] + '_mean']
          when "median"
            pretty_values[selection['title']]['median'] = result['value']['values'][selection['title'] + '_median']
          when "mode"
            pretty_values[selection['title']]['mode'] = result['value']['values'][selection['title'] + '_mode']
          end
        end
      end
    end
    
    pretty_key = "Results" if pretty_key.empty?
    pretty_result['_id'] = pretty_key
    pretty_result['value'] = pretty_values
    
    return pretty_result
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