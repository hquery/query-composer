class CodeSetsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @code_sets = CodeSet.asc(:type,:name)
  end
  
  
  def new
    @code_set.type=params[:type]
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
    #@code_sets = CodeSet.group_by(&:type)
    @code_sets = CodeSet.where(type:params[:type]).asc(:name)
    respond_to do |format|
       format.html {render :template=>"code_sets/index2.html"}
       format.json {render :json=>@code_sets}
      end
  end
  

  

end