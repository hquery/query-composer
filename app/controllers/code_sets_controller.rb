class CodeSetsController < ApplicationController
  skip_authorization_check
  
  
  def index
    @code_lists = CodeList.all
  end
  
  
  def new
    @code_list = CodeList.new
  end
  
  
  def add_code
    
  end
  
  def remove_code
    
  end
 
  def by_type
    @code_set = CodeSet.where(type:params[:type])
    respond_to do |format|
       format.html
       format.json {render :json=>@code_set}
      end
  end
  
  def save_json
    json = params[:json]
    @code_list = CodeSet.find(params[:id]).from_json(json)
  end
  
end