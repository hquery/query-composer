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
    execution = Execution.new(time: Time.now.to_i)
    @query.endpoints.each do |endpoint|
      execution.results << Result.new(endpoint: endpoint)
    end
    @query.executions << execution
    @query.save!
    
    PollJob.submit_all(execution)
        
    redirect_to :action => 'show'
  end
  
  def update_query_info
	  @unfinished_query_count = 0
	  if (@query.last_execution)
	    @query.last_execution.results.each do |result|
		    if result.status != 'Complete'
			    @unfinished_query_count += 1
		    end
		  end
	  end
	
	  respond_to do |format|
		  format.js { render :layout => false }
	  end
  end

  private

end
