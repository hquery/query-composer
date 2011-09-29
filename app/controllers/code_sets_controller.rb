class CodeSetsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @code_sets = CodeSet.all
  end
  
  

  def create
    @code_set.set_properties(params[:code_set])
    redirect_to :action=>:show, :id=>@code_set
  end
  
  
  def update 
    @code_set.set_properties(params[:code_set])
    redirect_to :action=>:show
  end
  
  def by_type
    @code_sets = CodeSet.where(type:params[:type])
    respond_to do |format|
       format.html {render :template=>"code_sets/index.html"}
       format.json {render :json=>@code_sets}
      end
  end
  

end