module EndpointsHelper
  def fetch_endpoint_statuses
    @endpoint_server_statuses = {}
    @endpoints.each do |endpoint|
      url = endpoint.status_url
      begin
	#use ssl
        response = Net::HTTP.start(url.host, url.port, :use_ssl => true, :key => CLIENT_KEY, :cert => CLIENT_CERT) do |http|
          headers = {}
          headers['Accept'] = 'application/atom+xml'
          http.get(url.path, headers)
        end
      
        case response
        when Net::HTTPSuccess
          @endpoint_server_statuses[endpoint.id] = {
            'backend_status' => 'good'
          }
        else
          @endpoint_server_statuses[endpoint.id] = {
            'backend_status' => 'unreachable'
          }
        end

      rescue Exception => ex
        @endpoint_server_statuses[endpoint.id] = {
          'backend_status' => 'unreachable'
        }
      end
    end
  end
end
