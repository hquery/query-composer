require 'stringio'
require 'net/http/post/multipart'
require 'poll_job'

class QueriesController < ApplicationController

  load_resource exclude: %w{index log}
  authorize_resource
  before_filter :authenticate_user!

  def index
    if (current_user.admin?) 
      @queries = Query.all
    else 
      @queries = current_user.queries
    end
  end

  def log
    @events = Event.all(:conditions => {:query_id => params[:id]})
  end

  def new
    @endpoints = Endpoint.all
  end

  def create
    endpoint = Endpoint.new
    endpoint.name = 'Default Local Queue'
    endpoint.submit_url = 'http://localhost:3001/queues'
    @query.endpoints << endpoint
    @query.user = current_user
    @query.save!
    redirect_to :action => 'show', :id=>@query.id
  end

  def edit
    @endpoints = Endpoint.all
  end

  def destroy
    @query.destroy
    redirect_to(queries_url)
  end

  def update
    @query.update_attributes!(params[:query])
    render :action => 'show'
  end

  def execute
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
