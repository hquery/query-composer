module GatewayUtils
  def query_request(map, reduce, filter, query_url)
    # build the multi-part elements for the request
    # need to do this inside the loop since UploadIO is single-use
    filter_io = if filter
      UploadIO.new(StringIO.new(filter), 'application/json')
    end
    map_io = UploadIO.new(StringIO.new(map), 'application/javascript')
    reduce_io = UploadIO.new(StringIO.new(reduce), 'application/javascript')

    # get the endpoint url and build the request
    payload = {'map' => map, 'reduce' => reduce_io}
    payload['filter'] = filter_io if filter
    Net::HTTP::Post::Multipart.new(query_url.path, payload)
  end
  
  # javascript that takes the namespaced user functions and creates non-namespaced aliases in the current scope
  # then redefines hquery_user_functions in the local scope so that users cannot access other users functions
  def js_to_localize_user_functions(user)
    composer_id = COMPOSER_ID
    "if (typeof hquery_user_functions != 'undefined' 
         && null != hquery_user_functions['f#{composer_id}'] 
         && null != hquery_user_functions['f#{composer_id}']['f#{user.id.to_s}']) { 
           for(var key in hquery_user_functions.f#{composer_id}.f#{user.id.to_s}) { 
             eval(key+'=hquery_user_functions.f#{composer_id}.f#{user.id.to_s}.'+key) 
           } 
           hquery_user_functions = {}; 
     } \r\n"
  end
  
  def submit(endpoint)
    query_url = nil
    query_url = endpoint.submit_url
    full_map = js_to_localize_user_functions(query.user) + query.map
    request = query_request(full_map, query.reduce, query.filter, query_url)
    begin
      Net::HTTP.start(query_url.host, query_url.port) do |http|
        response = http.request(request)
        if response.code == '201' 
          query_url = response['Location']
          EndpointLog.create(status: :create, message: "Created new query: #{query_url}", endpoint: endpoint)
        else
          EndpointLog.create(status: :error, message: "Did not understand the response: #{response.code} : #{response.message}", endpoint: endpoint)
        end
      end
    rescue Exception => ex
      EndpointLog.create(status: :error, message: "Exception submitting endpoint: #{ex}", endpoint: endpoint)
    end    
    query_url
  end
  
  def post_library_function(endpoint, user)
    functions = UploadIO.new(StringIO.new(user.library_function_definitions), 'application/javascript')

    url = endpoint.functions_url
    request = Net::HTTP::Post::Multipart.new(url.path, {'functions'=>functions, 'user_id'=> user.id, 'composer_id'=>COMPOSER_ID})

    begin
      Net::HTTP.start(url.host, url.port) do |http|
        response = http.request(request)
        case response
        when Net::HTTPSuccess
          EndpointLog.create(status: :user_functions, message: "user functions inserted", endpoint: endpoint)
        else
          EndpointLog.create(status: :user_functions, message: "user functions failed", endpoint: endpoint)
        end
      end
    rescue Exception => ex
      EndpointLog.create(status: :user_functions, message: "user functions failed: #{ex}", endpoint: endpoint)
    end
  end
end