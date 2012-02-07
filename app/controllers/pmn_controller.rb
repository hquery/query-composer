# Provides the entry point for the PopMedNet Portal. Stores PopMedNet session id and
# other related information in the user session and then redirects to the main queries
# page. Queries are still maintained per user, so users need to login to hQuery. At
# some point we should investigate some kind of SSO between PMN and hQuery to save this
# additional authentication step.

require 'gateway_utils'

class PmnController < ApplicationController
  include GatewayUtils
  add_breadcrumb 'pmn', :pmn_query_path
  skip_authorization_check
  
  def query
    session[:pmn_session_data] = get_session_data(params[:pmn_service_url], params[:pmn_session_id])
    redirect_to :controller => 'queries', :action => 'index'
  end
  
  def result
    # pull the results from PopMedNet and add to the query execution
    query = get_results(params[:pmn_service_url], params[:pmn_session_id])
    redirect_to :controller => 'queries', :action => 'show', :id => query.id
  end

end
