module EndpointsHelper
  def fetch_endpoint_statuses
    @endpoint_server_statuses = {}
    @endpoints.each do |endpoint|
      url = endpoint.status_url
      request = Net::HTTP::Get.new(url.path + "/server_status")
      begin
        Net::HTTP.start(url.host, url.port) do |http|
          response = http.request(request)
          if Net::HTTPSuccess
            @endpoint_server_statuses[endpoint.id] = JSON.parse(response.body)
          end
        end
        
      rescue Exception => ex
        @endpoint_server_statuses[endpoint.id] = {
          'queued' => 'unknown',
          'running' => 'unknown',
          'successful' => 'unknown',
          'failed' => 'unknown',
          'retried' => 'unknown',
          'avg_runtime' => 'unknown',
          'backend_status' => 'unreachable'
        }
      end
    end
  end
end
