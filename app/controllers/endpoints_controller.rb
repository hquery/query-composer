class EndpointsController < ApplicationController

  load_and_authorize_resource
  before_filter :authenticate_user!

  def index
    @endpoints = Endpoint.all
  end

  def show
    @endpoint = Endpoint.find(params[:id])
  end

  def new
    @endpoint = Endpoint.new
  end

  def edit
    @endpoint = Endpoint.find(params[:id])
  end

  def create
    @endpoint = Endpoint.new(params[:endpoint])

    if @endpoint.save
      redirect_to @endpoint, notice: 'Endpoint was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @endpoint = Endpoint.find(params[:id])

    if @endpoint.update_attributes(params[:endpoint])
      redirect_to @endpoint, notice: 'Endpoint was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @endpoint = Endpoint.find(params[:id])
    @endpoint.destroy

    redirect_to endpoints_url
  end
end
