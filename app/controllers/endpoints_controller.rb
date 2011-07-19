require 'net/http'

class EndpointsController < ApplicationController
  include EndpointsHelper
  
  load_and_authorize_resource
  before_filter :authenticate_user!
  add_breadcrumb 'Endpoints', :endpoints_url
  add_breadcrumb_for_resource :endpoint, :name, only: %w{edit show}
  add_breadcrumb_for_actions only: %w{edit new}

  def create
    if @endpoint.save
      redirect_to @endpoint, notice: 'Endpoint was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @endpoint.update_attributes(params[:endpoint])
      redirect_to @endpoint, notice: 'Endpoint was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @endpoint.destroy
    redirect_to endpoints_url
  end
  
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