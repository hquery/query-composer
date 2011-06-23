require 'stringio'
require 'net/http/post/multipart'
require 'poll_job'

class QueriesController < ApplicationController

  load_and_authorize_resource
  before_filter :authenticate_user!
  
  def index
    @queries = current_user.queries
    #@queries = Query.all
  end

  def log
    @events = Event.all(:conditions => {:query_id => params[:id]})
  end
  
  def new
    @query = Query.new
  end

  def create
    @query = Query.new(params[:query])
    endpoint = Endpoint.new
    endpoint.name = 'Default Local Queue'
    endpoint.submit_url = 'http://localhost:3001/queues'
    @query.endpoints << endpoint
    @query.user = current_user
    @query.save!
    redirect_to :action => 'show', :id=>@query.id
  end

  def show
    @query = Query.find(params[:id])
  end

  def edit
    @query = Query.find(params[:id])
  end
  
  def destroy
    @query = Query.find(params[:id])
    @query.destroy

    redirect_to(queries_url)
  end
  
  def update
    @query = Query.find(params[:id])
    @query.update_attributes!(params[:query])
    render :action => 'show'
  end
  
  def update_endpoint
    @query = Query.find(params[:id])
    endpoint = @query.endpoints.find(params[:endpoint][:id])
    endpoint.update_attributes!(params[:endpoint])
    @query.save!
    render :action => 'edit'
  end
  
  def add_endpoint
    @query = Query.find(params[:id])
    endpoint = Endpoint.new
    endpoint.name = 'Default Local Queue'
    endpoint.submit_url = 'http://localhost:3001/queues'
    @query.endpoints << endpoint
    @query.save!
    render :action => 'edit'
  end
  
  def destroy_endpoint
    @query = Query.find(params[:id])
    endpoint = @query.endpoints.find(params[:endpoint][:id])
    endpoint.destroy
    render :action => 'edit'
  end
  
  def execute
    @query = Query.find(params[:id])
    @query.aggregate_result = nil
    @query.endpoints.each do |endpoint|
      endpoint.result = nil
    end
    @query.save!
    
    PollJob.submit_all(@query)
        
    redirect_to :action => 'show'
  end
  
  private
  
end
