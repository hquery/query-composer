# Provides the entry point for the PopMedNet Portal. Stores PopMedNet session id and
# other related information in the user session and then redirects to the main queries
# page. Queries are still maintained per user, so users need to login to hQuery. At
# some point we should investigate some kind of SSO between PMN and hQuery to save this
# additional authentication step.

class PmnController < ApplicationController
  add_breadcrumb 'pmn', :pmn_query_path
  skip_authorization_check
  
  def query
    session[:pmn_session_id] = params[:pmn_session_id]
    redirect_to :controller => 'queries', :action => 'index'
  end

end
