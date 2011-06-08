require 'net/http'

class PollJob < Struct.new(:query_id, :endpoint_id)
  def perform()
    query = Query.find(BSON::ObjectId.from_string(query_id))
    endpoint = query.endpoints.find(BSON::ObjectId.from_string(endpoint_id))

    url = URI.parse endpoint.result_url
    request = Net::HTTP::Get.new(url.path)
    PollJob.submit(request, url, query, endpoint)
  end
  
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
          endpoint.result = result.body
          endpoint.next_poll = nil
          endpoint.result_url = nil
          
        when Net::HTTPRedirection
          endpoint.status = 'Queued'
          endpoint.result_url = result['location']
          endpoint.next_poll = result['retry_after'] ? result['retry_after'].to_i : 10
          Delayed::Job.enqueue(PollJob.new(query.id.to_s, endpoint.id.to_s), :run_at=>endpoint.next_poll.seconds.from_now)
          
        else
          endpoint.status = result.message #'Failed'
        end
      end
    rescue Exception => ex
      endpoint.status = ex.to_s
    end

    endpoint.save!
  end
end
