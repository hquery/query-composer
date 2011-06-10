require 'net/http'

class PollJob < Struct.new(:query_id, :endpoint_id)
  
  # Called by the Delayed Job worker, poll the specified endpoint and process
  # the response
  def perform()
    query = Query.find(BSON::ObjectId.from_string(query_id))
    endpoint = query.endpoints.find(BSON::ObjectId.from_string(endpoint_id))

    url = URI.parse endpoint.result_url
    request = Net::HTTP::Get.new(url.path)
    PollJob.submit(request, url, query, endpoint)
  end
  
  # Submit a HTTP request and process the results according to the
  # hQuery protocol. Redirects cause a new poll to be scheduled, success
  # triggers aggregation.
  def self.submit(request, url, query, endpoint)
    begin
      puts "Starting #{url}"
      Net::HTTP.start(url.host, url.port) do |http|
        puts "Requesting #{url}"
        result = http.request(request)
        puts "Finished #{url}"
        case result
        when Net::HTTPSuccess
          endpoint.status = 'Complete'
          endpoint.result = JSON.parse(result.body)
          endpoint.next_poll = nil
          endpoint.result_url = nil
          
        when Net::HTTPRedirection
          endpoint.status = 'Queued'
          endpoint.result_url = result['location']
          endpoint.next_poll = result['retry_after'] ? result['retry_after'].to_i : 5
          Delayed::Job.enqueue(PollJob.new(query.id.to_s, endpoint.id.to_s), 
            :run_at=>endpoint.next_poll.seconds.from_now)
          
        else
          endpoint.status = result.message #'Failed'
        end
      end
    rescue Exception => ex
      endpoint.status = ex.to_s
    end

    endpoint.save!
    aggregate query
  end
  
  # Aggregate all of the current results
  def self.aggregate(query)
    queries_collection = MONGO_DB.collection('queries')
    response = queries_collection.map_reduce(map_fn, query.reduce, :raw => true, 
      :out => {:inline => true}, :query => {:_id => query.id})
    results = response['results']
    if results
      result = results[0]
      if result
        value = result['value']
        query.aggregate_result = value
        query.save!
      end
    end
  end
  
  def self.map_fn
    <<END_OF_FN
    function() {
      var query = this;
      for(var i=0;i<query.endpoints.length;i++) {
        var endpoint = query.endpoints[i];
        if (endpoint.status=="Complete") {
          emit(null, endpoint.result);
        }
      }
    }
END_OF_FN
  end

end
