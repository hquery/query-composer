require 'cud_actions'
class ScheduledJobsController < ActionController::Base
  include CudActions

  creates_updates_destroys :query

  def parse_array(string)
    string[1..-2].gsub!(/[^0-9A-Za-z,-]/, '').split(',')
  end

  # Model constraints:
  #   usernames are required to be unique in the user model,
  #   a query must have a title,
  #   an endpoint must have a name.
  # Query titles and descriptions do not have to be unique; A combination
  # of title, description and username is more likely to be unique but for
  # convenience only description is currently implemented.
  def batch_query
    render nothing: true

    # logger.info "params: " + params.inspect
    #
    # endpoints_all = Endpoint.all
    # logger.info "List of all endpoints:"
    # endpoints_all.each do |endpoint|
    #   logger.info '  name: ' + endpoint[:name] + ', url: ' + endpoint[:base_url]
    # end

    # Select endpoints using array of endpoint names;
    # Unfortunately, they are not necessarily unique
    endpoint_names = params[:endpoint_names]
    logger.info 'param endpoint_names:' + endpoint_names.inspect
    selected_endpoints = []
    if endpoint_names
      parse_array(endpoint_names).each do |endpoint_name|
        match_ep = Endpoint.find_by_name(endpoint_name)
        if match_ep
          logger.info endpoint_name + ' matches: ' + match_ep.inspect
          selected_endpoints.push(match_ep)
        else
          logger.info 'WARNING: ' + endpoint_name + ' has no match!'
        end
      end
    end
    logger.info 'selected endpoings: ' + selected_endpoints.inspect


    # users = User.all
    # users.each do |user|
    #   logger.info 'username: ' + user[:username]
    # end

    # queries_all = Query.all
    # logger.info "List of all queries:"
    # queries_all.each do |query|
    #   logger.info '  title: ' + query[:title] + ', desc: ' + query[:description]
    # end

    # Select query using array of query descriptions;
    # Unfortunately, they are not necessarily unique
    #query_titles = params[:query_titles]
    #user_username = params[:user_username]
    query_descriptions = params[:query_descriptions]
    logger.info 'param query_descriptions:' + query_descriptions.inspect
    selected_queries = []
    if query_descriptions
      parse_array(query_descriptions).each do |query_desc|
        match_query = Query.find_by_description(query_desc)
        if match_query
          logger.info query_desc + ' matches: ' + match_query.inspect
          selected_queries.push(match_query)
        else
          logger.info 'WARNING: ' + query_desc + ' has no match!'
        end
      end
    end
    logger.info 'selected queries: ' + selected_queries.inspect

    if selected_endpoints && !selected_endpoints.empty? &&
        selected_queries && !selected_queries.empty?
      notify = params[:notification]
      selected_queries.each do |eachQuery|
        # execute the query, and pass in the endpoints and if the user should be notified by email when execution completes
        logger.info 'title: ' + eachQuery[:title].inspect
        logger.info 'desc:  ' + eachQuery[:description].inspect
        logger.info 'user_id: ' + eachQuery[:user_id].inspect
        eachQuery.execute(selected_endpoints, notify)
      end
    else
      flash[:alert] = 'Cannot execute a query if no endpoints are provided.'
    end
  end
end
