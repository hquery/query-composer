class EndpointsController < ApplicationController

  load_resource
  authorize_resource
  before_filter :authenticate_user!

  def create
    if @endpoint.save
      redirect_to @endpoint, notice: 'Endpoint was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    if @endpoint.update_attributes(params[:endpoint])
      redirect_to @endpoint, notice: 'Endpoint was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @endpoint.destroy
    redirect_to endpoints_url
  end
end
