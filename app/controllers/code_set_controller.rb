class CodeSetController < ApplicationController
  
  
  
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

  def save_json
    json = params[:json]
    @code_list = CodeSet.find(params[:id]).from_json(json)
   
  end
  
end