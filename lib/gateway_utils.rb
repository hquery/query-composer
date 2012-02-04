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
      # reduce = "function(key, values) {"
     
      reduce = query.reduce + builder_reduce_javascript_library
      # reduce += "return reduce(key, values);}"
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
    else
      functions = query.user.library_function_definitions if query.user
    end
    
    return functions
  end
  
  def submit(execution)
    proxy_addr = 'gatekeeper.mitre.org'
    proxy_port = 80
  
    # First add the serialized query
    service_url = execution.pmn_service_url
    session_id = execution.pmn_session_id
#     url = URI.parse("#{service_url}/#{session_id}/Document")
#     request = query_request(full_map(query), full_reduce(query), build_library_functions(query),  query.filter, url)
#     content_type = request['content-type']
#     body = request.body_stream.read
#     request = Net::HTTP::Post.new(url.path)
#     request.body = post_document(execution.query.title, content_type, false, body)
#     request.content_type = 'application/xml'
#     response = Net::HTTP::Proxy(proxy_addr, proxy_port).start(url.host, url.port) do |http|
#       http.request(request)
#     end
    # Next add a human readable version
    url = URI.parse("#{service_url}/#{session_id}/Document")
    request = Net::HTTP::Post.new(url.path)
    request.body = post_document(execution.query.title, 'text/plain', true, 'This is a hQuery')
    request.content_type = 'application/xml'
    response = Net::HTTP::Proxy(proxy_addr, proxy_port).start(url.host, url.port) do |http|
      http.request(request)
    end
    # Now commit the query
    url = URI.parse("#{service_url}/#{session_id}/Commit")
    request = Net::HTTP::Post.new(url.path)
    request.body = finish_request(execution.query.title, execution.query.description, '', '', '2012-05-05T12:00:00', 'Low')
    request.content_type = 'application/xml'
    response = Net::HTTP::Proxy(proxy_addr, proxy_port).start(url.host, url.port) do |http|
      http.request(request)
    end
  end
  
  def post_document(name, content_type, viewable, body)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.PostDocument("xmlns" => "http://lincolnpeak.com/schemas/DNS4/API") do
      xml.Name(name)
      xml.MimeType(content_type)
      xml.Viewable(viewable)
      xml.Body(Base64.encode64(body))
    end
    xml.target!
  end
  
  def finish_request(name, description, activity, activity_description, due_date, priority)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.RequestCreated("xmlns" => "http://lincolnpeak.com/schemas/DNS4/API") do
      xml.Header do
        xml.Name(name)
        xml.Description(description)
        xml.Activity(activity)
        xml.ActivityDescription(activity_description)
        xml.DueDate(due_date)
        xml.Priority(priority)
      end
      xml.ApplicableDataMarts
    end
    xml.target!
  end
  
end