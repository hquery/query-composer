require 'net/http'

module GatewayUtils
  def query_request(map, reduce, functions, filter)
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
    Net::HTTP::Post::Multipart.new('/', payload)
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
  
  def submit(execution, options)
    # first add the serialized JS query package
    request = query_request(full_map(query), full_reduce(query), build_library_functions(query),  query.filter)
    content_type = request['content-type']
    body = post_document_xml(execution.query.title, content_type, false, request.body_stream.read)
    post_request(execution, 'Document', body)
    # Next add a human readable version
    body = post_document_xml(execution.query.title, 'text/plain', true, "#{execution.query.title}: #{execution.query.description}\n\n#{execution.query.map}")
    post_request(execution, 'Document', body)
    # Now commit the query
    body = finish_request_xml(execution.query.title, execution.query.description, 
      options[:activity_name], options[:activity_description], options[:due_date].strftime("%Y-%m-%dT%H:%M:%S"),
      options[:priority].capitalize)
    post_request(execution, 'Commit', body)
  end
  
  def post_request(execution, action, body)
    proxy_addr = 'gatekeeper.mitre.org'
    proxy_port = 80
    url = URI.parse("#{execution.pmn_session_data.service_url}/#{execution.pmn_session_data.session_token}/#{action}")
    request = Net::HTTP::Post.new(url.path)
    request.body = body
    request.content_type = 'application/xml'
    response = Net::HTTP::Proxy(proxy_addr, proxy_port).start(url.host, url.port) do |http|
      http.request(request)
    end
  end
  
  def get_session_data(service_url, session_token)
    proxy_addr = 'gatekeeper.mitre.org'
    proxy_port = 80
    url = URI.parse("#{service_url}/#{session_token}/Session")
    request = Net::HTTP::Get.new(url.path)
    response = Net::HTTP::Proxy(proxy_addr, proxy_port).start(url.host, url.port) do |http|
      http.request(request)
    end
    doc = Nokogiri::XML(response.body)
    doc.root.add_namespace_definition('pmn', 'http://lincolnpeak.com/schemas/DNS4/API')
    {
      :return_url => doc.at_xpath('/SessionMetadata/ReturnUrl').inner_text,
      :session_token => session_token,
      :service_url => service_url,
      :request_id => doc.at_xpath('/SessionMetadata/RequestId').inner_text
    }
  end
  
  def get_results(service_url, session_token)
    proxy_addr = 'gatekeeper.mitre.org'
    proxy_port = 80
    url = URI.parse("#{service_url}/#{session_token}/Session")
    request = Net::HTTP::Get.new(url.path)
    response = Net::HTTP::Proxy(proxy_addr, proxy_port).start(url.host, url.port) do |http|
      http.request(request)
    end
    doc = Nokogiri::XML(response.body)
    doc.root.add_namespace_definition('pmn', 'http://lincolnpeak.com/schemas/DNS4/API')
    result_doc_urls = doc.xpath('//pmn:Document[pmn:MimeType="application/json"]').collect do |result_doc|
      result_doc.at_xpath('./pmn:LiveUrl').inner_text
    end
    
    execution = Execution.from_result_id(doc.at_xpath('//pmn:Session/RequestId').inner_text)
    
    result_doc_urls.each do |result_doc_url|
      # fetch data and add to execution as new result
      url = URI.parse(result_doc_url)
      request = Net::HTTP::Get.new(url.path)
      response = Net::HTTP::Proxy(proxy_addr, proxy_port).start(url.host, url.port) do |http|
        http.request(request)
      end
      json = JSON.parse(response.body)
      execution.results << Result.new({:value => json, :aggregated => false})
    end
    execution.status = Execution.COMPLETE
    execution.save!
    execution.aggregate
    execution.query
  end
  
  def post_document_xml(name, content_type, viewable, body)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.PostDocument("xmlns" => "http://lincolnpeak.com/schemas/DNS4/API") do
      xml.Name(name)
      xml.MimeType(content_type)
      xml.Viewable(viewable)
      xml.Body(Base64.encode64(body))
    end
    xml.target!
  end
  
  def finish_request_xml(name, description, activity, activity_description, due_date, priority)
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