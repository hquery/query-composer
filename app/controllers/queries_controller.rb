require 'stringio'
require 'net/http/post/multipart'
require 'poll_job'

class QueriesController < ApplicationController
  # load resource must be before authorize resource
  load_resource exclude: %w{index log clone_template}
  authorize_resource
  before_filter :authenticate_user!

  # add breadcrumbs
  add_breadcrumb 'Queries', :queries_url
  add_breadcrumb_for_resource :query, :title, only: %w{edit show log execution_history}
  add_breadcrumb_for_actions only: %w{edit new log execution_history}

  creates_updates_destroys :query

  def index
    @queries = (current_user.admin?) ? Query.all : current_user.queries
  end

  def log
    @events = Event.all(:conditions => {:query_id => params[:id]})
  end

  def new
    @endpoints = Endpoint.all
  end

  def before_create
    @query.user = current_user
  end

  def edit
    @endpoints = Endpoint.all
  end

  def execute

    # execute the query, and pass in if the user should be notified by email when execution completes
    @query.execute(params[:notification])

    redirect_to :action => 'show'
  end

  def cancel
    execution = @query.executions.find(params[:execution_id])
    execution.results.find(params[:result_id]).cancel
    redirect_to :action => 'show'
  end

  def cancel_execution
    @query.executions.find(params[:execution_id]).cancel
    redirect_to :action => 'show'
  end

  # This function is used to re-fetch the value of a query. Used to check the status of a query's execution results
  def refresh_execution_results
    @incomplete_results = (@query.last_execution) ? @query.last_execution.unfinished_results.count : 0
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def clone_template
    @query = TemplateQuery.find(params[:template_id]).to_query
    @query.title = "#{@query.title} (cloned)"
    @endpoints = Endpoint.all
    render :new
  end

  private

end
