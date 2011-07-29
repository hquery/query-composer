class EndpointsController < ApplicationController
  include EndpointsHelper

  load_and_authorize_resource
  before_filter :authenticate_user!
  add_breadcrumb 'Endpoints', :endpoints_url
  add_breadcrumb_for_resource :endpoint, :name, only: %w{edit show}
  add_breadcrumb_for_actions only: %w{edit new}
  
  creates_updates_destroys :endpoint

  def index
    fetch_endpoint_statuses
  end

  def refresh_endpoint_statuses
    fetch_endpoint_statuses

    respond_to do |format|
      format.js { render :layout => false }
    end
  end
end