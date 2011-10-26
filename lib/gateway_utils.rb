module GatewayUtils
  def query_request(map, reduce, functions, filter, query_url)
    # build the multi-part elements for the request
    # need to do this inside the loop since UploadIO is single-use
    filter_io = if filter
      UploadIO.new(StringIO.new(filter), 'application/json')
    end
    
    function_io = if functions
      UploadIO.new(StringIO.new(functions), 'application/json')
    end
    map_io = UploadIO.new(StringIO.new(map), 'application/javascript')
    reduce_io = UploadIO.new(StringIO.new(reduce), 'application/javascript')

    # get the endpoint url and build the request
    payload = {'map' => map_io, 'reduce' => reduce_io}
    payload['filter'] = filter_io if filter
    payload['functions'] = function_io if function_io
    Net::HTTP::Post::Multipart.new(query_url.path, payload)
  end
  
 
  
  def full_map query
    query.map
  end
  
  # The reduce function is only allowed to be exactly one function, so we stuff everything inside
  def full_reduce query
    if (query.generated?)
      reduce = "function(key, values) {"
      reduce += query.reduce + builder_reduce_javascript_library
      reduce += "return reduce(key, values);}"
    else
      reduce = query.reduce
    end
    return reduce
  end
  
  # get javascript for builder queries
  def builder_map_javascript_library
    container = CoffeeScript.compile(Rails.root.join('app/assets/javascripts/builder/container.js.coffee').read, :bare=>true)
    container = "var queryStructure = queryStructure || {}; \n" + container
    reducer = CoffeeScript.compile(Rails.root.join('app/assets/javascripts/builder/reducer.js.coffee').read, :bare=>true)
    rules = CoffeeScript.compile(Rails.root.join('app/assets/javascripts/builder/rules.js.coffee').read, :bare=>true)
    return container + reducer + rules
  end
  
  def builder_reduce_javascript_library
    return CoffeeScript.compile(Rails.root.join('app/assets/javascripts/builder/reducer.js.coffee').read, :bare=>true)
  end
  
  
  def build_library_functions(query)
    if (query.generated?)
      functions = builder_map_javascript_library 
      functions += query.user.library_function_definitions if query.user
      functions
    else
      functions = query.user.library_function_definitions if query.user
    end
    return functions
  end
  
  
  def submit(endpoint)
    query_url = nil
    query_url = endpoint.submit_url
    request = query_request(full_map(query), full_reduce(query), build_library_functions(query),  query.filter, query_url)
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
  

end