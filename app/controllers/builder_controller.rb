class BuilderController < ApplicationController


  before_filter :authenticate_user!
  
  def vital_signs_editor
    @vital_signs = CodeSet.where(type:"vital_sign_codes")
    render :partial=>"queries/builder/vital_signs_editor"
  end
  
  
end
