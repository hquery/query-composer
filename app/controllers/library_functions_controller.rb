class LibraryFunctionsController < ApplicationController
  load_resource exclude: %w{index}
  authorize_resource
  before_filter :authenticate_user!

  # add breadcrumbs
  add_breadcrumb 'Library Functions', :library_functions_url
  add_breadcrumb_for_resource :library_function, :name, only: %w{edit show log execution_history}
  add_breadcrumb_for_actions only: %w{edit new}

  def index
    if (current_user.admin?) 
      @library_functions = LibraryFunction.all
    else 
      @library_functions = current_user.library_functions
    end
  end


  # GET /library_functions/new
  def new
    @library_function.definition = <<END_OF_FN
    #{current_user.username}.example = function() {
        
      }
END_OF_FN

  end

  # POST /library_functions
  def create
    @library_function.user = current_user

    if @library_function.save
      redirect_to @library_function, notice: 'Library function was successfully created.'
    else
      render action: "new" 
    end
  end

  # PUT /library_functions/1
  def update
    if @library_function.update_attributes(params[:library_function])
      redirect_to @library_function, notice: 'Library function was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /library_functions/1
  def destroy
    @library_function.destroy
    redirect_to library_functions_url
  end
  
end
