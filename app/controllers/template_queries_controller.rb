require 'stringio'
require 'net/http/post/multipart'
require 'poll_job'

class TemplateQueriesController < ApplicationController

  # load resource must be before authorize resource
  load_and_authorize_resource
  before_filter :authenticate_user!
	
  # add breadcrumbs
  add_breadcrumb 'Query Template Admin', :template_queries_url
  add_breadcrumb_for_resource :template_query, :title, only: %w{edit show}
  add_breadcrumb_for_actions only: %w{edit new}

  def modify
    @querynew = TemplateQuery.find(params[:id])
    @template_query = @querynew
  end

def modup
   @template_query = TemplateQuery.find(params[:id])  
   @template_query.update_attributes!(params[:template_query])
   redirect_to :action => 'index'
end

  # POST /template_queries
  # POST /template_queries.json
  def create
    @template_query.save
    redirect_to :action =>'index'
  end

# PUT /template_queries/1
  # PUT /template_queries/1.json
  def update
    @template_query.update_attributes(params[:template_query])
    redirect_to template_queries_url
  end

  # DELETE /template_queries/1
  # DELETE /template_queries/1.json
  def destroy
    @template_query.destroy
    redirect_to template_queries_url 
  end
end
