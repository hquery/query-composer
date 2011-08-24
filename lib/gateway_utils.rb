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
  def get_denamespace_js(user)
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
end