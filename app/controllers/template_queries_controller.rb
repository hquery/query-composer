require 'stringio'
require 'net/http/post/multipart'

class TemplateQueriesController < ApplicationController

  load_and_authorize_resource
  before_filter :authenticate_user!

  # add breadcrumbs
  add_breadcrumb 'Query Template Admin', :template_queries_url
  add_breadcrumb_for_resource :template_query, :title, only: %w{edit show}
  add_breadcrumb_for_actions only: %w{edit new}

  creates_updates_destroys :template_query

end
