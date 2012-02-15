require 'stringio'
require 'net/http/post/multipart'

class QueriesController < ApplicationController
  # load resource must be before authorize resource
  load_resource exclude: %w{index log clone_template}
  authorize_resource
  before_filter :authenticate_user!

  # add breadcrumbs
  add_breadcrumb 'Queries', :queries_url
  add_breadcrumb_for_resource :query, :title, only: %w{edit show log builder builder_simple}
  add_breadcrumb_for_actions only: %w{edit new log builder builder_simple}

  creates_updates_destroys :query

  def index
    @queries = (current_user.admin?) ? Query.all : current_user.queries
  end

  def log
  end

  def show
    @endpoints = []
  end
  
  def edit
    if (@query.generated?) 
      @query = @query.clone
      @query.title = "#{@query.title} (cloned)"
      @query.generated = false;
      @query.save!
    end
    
    if (@query.map.nil?)
      @query.map = "function map(patient) {\r\n  \r\n}"
    end
    if (@query.reduce.nil?)
      @query.reduce = "function reduce(key, values) {\r\n  \r\n}"
    end
  end

  def before_create
    @query.user = current_user
    @query.init_query_structure!
  end
  
  def after_create
    if @query.generated?
      redirect_to builder_query_path(@query)
    else
      redirect_to edit_query_path(@query)
    end
  end
  
  def before_update
    convert_to_hash(:query_structure)
  end

  def new
    template = params[:builder] ? "queries/builder": "queries/new"
    render :template=> template
  end

  def builder
     @endpoints = []
  end
  
  def result
    @presenter = @query.result_presenter
  end

  def execute
    # execute the query, and pass in the endpoints and if the user should be notified by email when execution completes
    @query.execute(session, :priority => params[:priority], :due_date => as_time(params[:due_date]), :activity_name => params[:activity_name], :activity_description => params[:activity_description])
    return_url = session[:pmn_session_data][:return_url]
    session[:pmn_session_data] = nil

    # redirect to the PopMedNet portal
    redirect_to return_url
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
    if (@query.last_execution)
      @incomplete_results = nil
      @incomplete_results ||= @query.last_execution.results.where(aggregated: false).count > 0
    else
      @incomplete_results = false
    end
    @query.reload
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def clone_template
    @query = TemplateQuery.find(params[:template_id]).to_query
    @query.title = "#{@query.title} (cloned)"
    render :new
  end

  private
  
  def as_time(str)
    return (Time.now + 7*24*60*60) if str==nil || str.length != 10 # one week from today
    return Time.local(str[6,4].to_i, str[0,2].to_i, str[3,2].to_i)
  end

  def convert_to_hash(field)
    params[:query][field] = JSON.parse(params[:query][field]) if params[:query][field]
  end

end
