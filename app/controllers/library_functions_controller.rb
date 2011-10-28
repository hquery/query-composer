class LibraryFunctionsController < ApplicationController
  load_resource exclude: %w{index}
  authorize_resource
  before_filter :authenticate_user!

  # add breadcrumbs
  add_breadcrumb 'Library Functions', :library_functions_url
  add_breadcrumb_for_resource :library_function, :name, only: %w{edit show log execution_history}
  add_breadcrumb_for_actions only: %w{edit new}

  creates_updates_destroys :library_function

  def index
    @library_functions = (current_user.admin?) ? LibraryFunction.all : current_user.library_functions
  end

  def new
    @library_function.definition = "function<name>(<params>) {
    
    }\r\n"
  end

  def before_create
    @library_function.user = current_user
  end

end
