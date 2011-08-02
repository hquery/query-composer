require 'stringio'
require 'net/http/post/multipart'
require 'poll_job'

class TemplateQueriesController < ApplicationController

  # load resource must be before authorize resource
  load_resource exclude: %w{index log}
  authorize_resource
  before_filter :authenticate_user!
	
  # add breadcrumbs
  add_breadcrumb 'Query Template Admin', :template_queries_url
  add_breadcrumb_for_resource :template_query, :title, only: %w{edit show log execution_history}
  add_breadcrumb_for_actions only: %w{edit new log execution_history}

  # GET /template_queries
  # GET /template_queries.json
  def index
    @template_queries = TemplateQuery.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @template_queries }
    end
  end
  
   def modify
    @querynew = TemplateQuery.find(params[:id])
    @template_query = @querynew
  end

def modup
   @template_query = TemplateQuery.find(params[:id])  
    @template_query.update_attributes!(params[:template_query])

    redirect_to :action => 'index'
  end


  # GET /template_queries/1
  # GET /template_queries/1.json
  def show
    @template_query = TemplateQuery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @template_query }
    end
  end

  # GET /template_queries/new
  # GET /template_queries/new.json
  def new
    @template_query = TemplateQuery.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @template_query }
    end
  end

  # GET /template_queries/1/edit
  def edit
    @template_query = TemplateQuery.find(params[:id])
  end

  # POST /template_queries
  # POST /template_queries.json
  def create
    @template_query = TemplateQuery.new(params[:template_query])
#redirect_to :action => 'index'
    respond_to do |format|
      if @template_query.save
#	redirect_to :action => 'index'
        format.html { redirect_to :action =>'index', notice: 'Template query was successfully created.' }
        format.json { render json: @template_query, status: :created, location: @template_query }
      else
        format.html { render action: "new" }
        format.json { render json: @template_query.errors, status: :unprocessable_entity }
end

    end
  end

  # PUT /template_queries/1
  # PUT /template_queries/1.json
  def update
    @template_query = TemplateQuery.find(params[:id])

    respond_to do |format|
      if @template_query.update_attributes(params[:template_query])
	#redirect_to :action => 'index'
        format.html { redirect_to template_queries_url, notice: 'Template query was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @template_query.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /template_queries/1
  # DELETE /template_queries/1.json
  def destroy
    @template_query = TemplateQuery.find(params[:id])
    @template_query.destroy

    respond_to do |format|
      format.html { redirect_to template_queries_url }
      format.json { head :ok }
    end
  end
end
