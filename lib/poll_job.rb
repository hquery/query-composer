require 'net/http'
require 'query_logger'

class PollJob < Struct.new(:query_id, :execution_id, :result_id)
  
  @@logger = nil
  
  def self.logger
    @@logger ||= QueryLogger.new
  end
  
  # Called by the Delayed Job worker, poll the specified endpoint and process
  # the response
  def perform()
    query = Query.find(BSON::ObjectId.from_string(query_id))
    result = query.executions.find(execution_id).results.find(result_id);

    url = URI.parse result.result_url
    request = Net::HTTP::Get.new(url.path)
    PollJob.submit(request, url, query, result)
  end
  
  # Loop through all the endpoints and submit each one in turn
  def self.submit_all(execution)

    execution.results.each do |result|
      # build the multi-part elements for the request
      # need to do this inside the loop since UploadIO is single-use
      filter = UploadIO.new(StringIO.new(execution.query.filter), 'application/json')
      map = UploadIO.new(StringIO.new(execution.query.map), 'application/javascript')
      reduce = UploadIO.new(StringIO.new(execution.query.reduce), 'application/javascript')
    
      # get the endpoint url and build the request
      url = URI.parse result.endpoint.submit_url
      request = Net::HTTP::Post::Multipart.new(url.path, {'map'=>map, 'reduce'=>reduce, 'filter'=>filter})
      
      submit(request, url, execution.query, result)
    end    
  end
  
  # Submit a HTTP request and process the results according to the
  # hQuery protocol. Redirects cause a new poll to be scheduled, success
  # triggers aggregation.
  def self.submit(request, url, query, result)
    
    begin

      logger.add(query, "Starting #{request.method} #{url}")
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.request(request)
        case response
        when Net::HTTPSuccess
          result.status = 'Complete'
          result.value = JSON.parse(response.body)
          logger.add(query, "Complete", {:result => result.value})
          result.next_poll = nil
          result.result_url = nil
          
        when Net::HTTPRedirection
          result.status = 'Queued'
          result.result_url = response['location']
          result.next_poll = response['retry-after'] ? response['retry-after'].to_i : 5
          logger.add(query, "Queued", {:next_poll => result.next_poll, :poll_url => result.result_url})
          Delayed::Job.enqueue(PollJob.new(query.id.to_s, result.execution.id.to_s, result.id.to_s), :run_at=>result.next_poll.seconds.from_now)
          
        else
          logger.add(query, "Failed", {:error => "#{response.message}"})
          result.status = response.message
          result.result_url = nil
          result.next_poll = nil
          
        end
      end
    rescue Exception => ex
      logger.add(query, "Failed", {:error => "#{ex.to_s}"})
      result.status = ex.to_s
      result.result_url = nil
      result.next_poll = nil
    end

    result.save!
    aggregate result.execution
  end
  
  # Aggregate all of the current results
  def self.aggregate(execution)
     queries_collection = MONGO_DB.collection('queries')
     response = queries_collection.map_reduce(map_fn(execution), execution.query.reduce, :raw => true, :out => {:inline => true}, :query => {:_id => execution.query.id})
     results = response['results']
     if results
       execution.aggregate_result = {}
       results.each do |result|
         execution.aggregate_result[result['_id']] = result['value']
       end
       execution.query.save!
     end
   end
  
  def self.map_fn(execution)
    execution_id = nil;
    execution_id = execution.id if execution

        <<END_OF_FN
                function() {
                  var query = this;
                  var execution = null;
                  var execution = null;
                  for(var i in query.executions) {
                    if (query.executions[i]._id.toString() == "#{execution_id}") execution = query.executions[i];
                  }
                  for(var i in execution.results) {
                    var endpoint = execution.results[i];
                    if (endpoint.status=="Complete") {
                      for(var key in endpoint.value) {
                        if (key != "_id") {
                          emit(key, endpoint.value[key]);
                        }
                      }
                    }
                  }
                }
END_OF_FN

#     <<END_OF_FN
#     function() {
#       var query = this;
#       for(var i in query.endpoints) {
#         var endpoint = query.endpoints[i];
#         if (endpoint.status=="Complete") {
#           for(var key in endpoint.result) {
#             if (key != "_id") {
#               emit(key, endpoint.result[key]);
#             }
#           }
#         }
#       }
#     }
# END_OF_FN
  end

end
