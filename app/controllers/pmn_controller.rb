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
    session[:pmn_session_id] = params[:pmn_session_id]
    session[:pmn_service_url] = params[:pmn_service_url]
    session[:pmn_return_url] = get_return_url(params[:pmn_service_url], params[:pmn_session_id])
    flash[:notice] = "Url: #{params[:pmn_service_url]}, Token: #{params[:pmn_session_id]}"
    redirect_to :controller => 'queries', :action => 'index'
  end
  
  def result
    session[:pmn_session_id] = params[:pmn_session_id]
    session[:pmn_service_url] = params[:pmn_service_url]
    # pull the results from PopMedNet and update the query
    redirect_to :controller => 'queries', :action => 'show', :id => query.id
  end

end
