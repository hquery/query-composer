require 'stringio'
require 'net/http/post/multipart'
require 'poll_job'

class QryadminController < ApplicationController

  # load resource must be before authorize resource
  #load_resource exclude: %w{index log}
  #authorize_resource
  #before_filter :authenticate_user!

  # add breadcrumbs
  #akling - need to ask what this is
  add_breadcrumb 'Query Admin', :qryadmin_url
  #add_breadcrumb_for_resource :qryadmin, :title, only: %w{edit show log execution_history}
  #add_breadcrumb_for_actions only: %w{edit new log execution_history}

  ### from qry admin
  def index
    #if (current_user.admin?) 
    @queries = Query.all
    #else 
    #@queries = current_user.queries
    #end
  end

  def admin
    @queries = Query.all
  end

  def modify
    @querynew = Query.find(params[:id])
    @query = @querynew
  end

  def modup
    @query = Query.find(params[:id])  
    @query.update_attributes!(params[:query])

    redirect_to :action => 'index'
  end

  def adminnew
    @query = Query.new
    #  redirect_to :action => 'admin'
  end

  def admincreate
    @query = Query.new(params[:query])
    endpoint = Endpoint.new
    endpoint.name = 'Default Local Queue'
    endpoint.submit_url = 'http://localhost:3001/queues'
    @query.endpoints << endpoint
    @query.save!
    redirect_to :action => 'index'
  end

  def clone
    @query = Query.find(params[:id])
    @querynew = Query.new(params[:query])
    @querynew.title = @query.title + " cloned"
    @querynew.description =@query.description
    @querynew.map = @query.map
    @querynew.reduce = @query.reduce
    #@querynew.status = @query.status

    endpoint = Endpoint.new
    endpoint.name = 'Default Local Queue'
    endpoint.submit_url = 'http://localhost:3001/queues'
    @querynew.endpoints << endpoint
    @querynew.save!
    redirect_to :action => 'index'
  end

  def destroy
    @query = Query.find(params[:id])
    # Query.delete(params[:id])
    @query.destroy
    redirect_to :action => 'index'
  end

end

#########
