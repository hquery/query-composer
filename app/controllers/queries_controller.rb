require 'stringio'
require 'net/http/post/multipart'

class QueriesController < ApplicationController
  # load resource must be before authorize resource
  load_resource exclude: %w{index log clone_template}
  authorize_resource
  before_filter :authenticate_user!

  # add breadcrumbs
  add_breadcrumb 'Queries', :queries_url
  add_breadcrumb_for_resource :query, :title, only: %w{edit show log execution_history builder builder_simple}
  add_breadcrumb_for_actions only: %w{edit new log execution_history builder builder_simple}

  creates_updates_destroys :query

  def index
    @queries = (current_user.admin?) ? Query.all : current_user.queries
  end

  def log
    #@events = Event.all(:conditions => {:query_id => params[:id]})
  end

  def show
    @endpoints = Endpoint.all
  end
  
  def edit
    if (@query.generated?)
      redirect_to action: 'builder_simple'
    else
      redirect_to action: 'edit_code'
    end
  end
  
  def edit_code
    if (@query.generated?) 
      @query = @query.clone
      @query.title = "#{@query.title} (cloned)"
      @query.generated = false;
      @query.save!
    end
  end

  def before_create
    @query.user = current_user
    @query.init_query_structure!
  end
  
  def after_create
    redirect_to edit_query_path(@query)
  end
  
  def before_update
    convert_to_hash(:query_structure)
  end

  def new
    template = params[:builder] ? "queries/builder": "queries/new"
    render :template=> template
  end

  def builder
  end
  
  def result
    @presenter = @query.result_presenter
  end

  def builder_simple
  end

  def execute
    endpoint_ids = params[:endpoint_ids]
    if (endpoint_ids && !endpoint_ids.empty?) 
      endpoint_ids = endpoint_ids.map! {|id| BSON::ObjectId(id)}
      endpoints = Endpoint.criteria.for_ids(endpoint_ids)

      notify = params[:notification]
      
      # execute the query, and pass in the endpoints and if the user should be notified by email when execution completes
      @query.execute(endpoints, notify)

      redirect_to :action => 'show'
    else
      flash[:alert] = "Cannot execute a query if no endpoints are provided."
      redirect_to :action => 'show'
    end
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
      @incomplete_results = @query.last_execution.unfinished_results.count > 0
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

  def convert_to_hash(field)
    params[:query][field] = JSON.parse(params[:query][field]) if params[:query][field]
  end

end
