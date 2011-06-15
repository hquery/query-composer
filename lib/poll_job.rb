require 'net/http'
require 'query_logger'

class PollJob < Struct.new(:query_id, :endpoint_id)
  
  @@logger = nil
  
  def self.logger
    @@logger ||= QueryLogger.new
  end
  
  # Called by the Delayed Job worker, poll the specified endpoint and process
  # the response
  def perform()
    query = Query.find(BSON::ObjectId.from_string(query_id))
    endpoint = query.endpoints.find(BSON::ObjectId.from_string(endpoint_id))

    url = URI.parse endpoint.result_url
    request = Net::HTTP::Get.new(url.path)
    PollJob.submit(request, url, query, endpoint)
  end
  
  # Loop through all the endpoints and submit each one in turn
  def self.submit_all(query)

    # build the multi-part elements for the request
    filter = UploadIO.new(StringIO.new(query.filter), 'application/json')
    map = UploadIO.new(StringIO.new(query.map), 'application/javascript')
    reduce = UploadIO.new(StringIO.new(query.reduce), 'application/javascript')
    
    query.endpoints.each do |endpoint|
      # get the endpoint url and build the request
      url = URI.parse endpoint.submit_url
      request = Net::HTTP::Post::Multipart.new(url.path, {'map'=>map, 'reduce'=>reduce, 'filter'=>filter})
      
      submit(request, url, query, endpoint)
    end    
  end
  
  # Submit a HTTP request and process the results according to the
  # hQuery protocol. Redirects cause a new poll to be scheduled, success
  # triggers aggregation.
  def self.submit(request, url, query, endpoint)
    
    begin
      
      logger.add(query, "Starting #{request.method} #{url}")
      Net::HTTP.start(url.host, url.port) do |http|
        result = http.request(request)
        case result
        when Net::HTTPSuccess
          endpoint.status = 'Complete'
          endpoint.result = JSON.parse(result.body)
          logger.add(query, "Complete", {:result => endpoint.result})
          endpoint.next_poll = nil
          endpoint.result_url = nil
          
        when Net::HTTPRedirection
          endpoint.status = 'Queued'
          endpoint.result_url = result['location']
          endpoint.next_poll = result['retry-after'] ? result['retry-after'].to_i : 5
          logger.add(query, "Queued", {:next_poll => endpoint.next_poll, :poll_url => endpoint.result_url})
          Delayed::Job.enqueue(PollJob.new(query.id.to_s, endpoint.id.to_s), :run_at=>endpoint.next_poll.seconds.from_now)
          
        else
          logger.add(query, "Failed", {:error => "#{result.message}"})
          endpoint.status = result.message
          endpoint.result_url = nil
          endpoint.next_poll = nil
          
        end
      end
    rescue Exception => ex
      logger.add(query, "Failed", {:error => "#{ex.to_s}"})
      endpoint.status = ex.to_s
      endpoint.result_url = nil
      endpoint.next_poll = nil
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
