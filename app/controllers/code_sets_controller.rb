class CodeSetsController < ApplicationController
  skip_authorization_check
  
  
  def index
    @code_sets = CodeSet.all
  end
  
  
  def new
    @code_set = CodeSet.new
  end
  
  def create
    @code_set = CodeSet.new
    @code_set.set_properties(params[:code_set])
    redirect_to :action=>:show, :id=>@code_set
  end
  
  def show
    @code_set = CodeSet.find(params[:id])
  end
 
  def edit
    @code_set = CodeSet.find(params[:id])
  end
  
  def update
    @code_set = CodeSet.find(params[:id])
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
  
  def save_json
    json = params[:json]
    @code_set = CodeSet.find(params[:id]).from_json(json)
  end
  
end