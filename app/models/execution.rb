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
    results.where( "this.status != '" + Result::COMPLETE + "' && this.status != '" + Result::FAILED + "'")
  end

  def cancel
    results.each {|result| result.cancel}
  end
  
  # ===============
  # = Aggregation =
  # ===============
  def aggregate
    #response = Result.collection.map_reduce(self.map_fn(), _reduce(), :raw => true, :out => {:inline => true}, :query => {:execution_id => id})
    response = Result.where(execution_id: id).map_reduce(self.map_fn(), _reduce()).out(inline: true).raw()
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
    if (result['_id']['type'] == 'population')
      pretty_key = "Populations"
      pretty_values = {
        'Target Population' => result['value']['values']['target_pop_sum'],
        'Filtered Population' => result['value']['values']['filtered_pop_sum'],
        'Unfound Population' => result['value']['values']['unfound_pop_sum'],
        'Total Population' => result['value']['values']['total_pop_sum']
      }
    elsif (result['_id']['type'] == 'group')
      self.query.query_structure['extract']['groups'].each do |group|
        pretty_key << group['title'].capitalize
        pretty_key << ": #{result['_id'][group['title']]}"
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
    if (not self.query.generated?)
      return <<NON_GENERATED_MAP
        function() {
          #{build_library_functions(query)}
          if (this.status == "#{Result::COMPLETE}") {
            for(var key in this.value) {
              if (key != "_id" && key != 'created_at' && key != 'query_id') {
                emit(key, this.value[key]);
              }
            }
          }
        }
NON_GENERATED_MAP
    end
    
    reducer_code = CoffeeScript.compile(Rails.root.join('app/assets/javascripts/builder/reducer.js.coffee').read, :bare=>true)
    
    <<GENERATED_MAP
    function() {
      #{reducer_code}
      if (this.status == "#{Result::COMPLETE}") {
        for(var key in this.value) {
          if (key != "_id" && key != "created_at" && key != "query_id") {
            if ((key.match(new RegExp("type_population")) || key.match(new RegExp("type_group")))) {
              var hashifiedKey = {};
              if (key.match(new RegExp("type_population"))) {
                hashifiedKey['type'] = 'population';
              } else {
                hashifiedKey['type'] = 'group';
              }
              if (hashifiedKey.type == 'group') {
                var queryStructure = #{self.query.query_structure.to_json}
                for (var group in queryStructure['extract']['groups']) {
                  var match = RegExp(queryStructure['extract']['groups'][group]['title'] + "_(.*)", '');
                  var results = key.match(match);
                  hashifiedKey[queryStructure['extract']['groups'][group]['title']] = results[1];
                }
              }
              
              this.value[key] = new reducer.Value(this.value[key]['values'], this.value[key]['rereduced']);
            }
            
            var originalKey = key;
            key = hashifiedKey;
            
            emit(key, this.value[originalKey]);
          }
        }
      }
    }
GENERATED_MAP
  end
  
  private 
  
  def _reduce
     "function(k,v){

         var iter = function(x){
           this.index = 0;
           this.arr = (x==null)? [] : x;

           this.hasNext = function(){
             return this.index < this.arr.length;
           };

           this.next = function(){
             return this.arr[this.index++];
           }
         };

         #{full_reduce(self.query)}
         return reduce(k,new iter(v));
      }"
    end
end