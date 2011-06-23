class EndpointsController < ApplicationController

  load_and_authorize_resource

  # GET /endpoints
  # GET /endpoints.json
  def index
    @endpoints = Endpoint.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @endpoints }
    end
  end

  # GET /endpoints/1
  # GET /endpoints/1.json
  def show
    @endpoint = Endpoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @endpoint }
    end
  end

  # GET /endpoints/new
  # GET /endpoints/new.json
  def new
    @endpoint = Endpoint.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @endpoint }
    end
  end

  # GET /endpoints/1/edit
  def edit
    @endpoint = Endpoint.find(params[:id])
  end

  # POST /endpoints
  # POST /endpoints.json
  def create
    @endpoint = Endpoint.new(params[:endpoint])

    respond_to do |format|
      if @endpoint.save
        format.html { redirect_to @endpoint, notice: 'Endpoint was successfully created.' }
        format.json { render json: @endpoint, status: :created, location: @endpoint }
      else
        format.html { render action: "new" }
        format.json { render json: @endpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /endpoints/1
  # PUT /endpoints/1.json
  def update
    @endpoint = Endpoint.find(params[:id])

    respond_to do |format|
      if @endpoint.update_attributes(params[:endpoint])
        format.html { redirect_to @endpoint, notice: 'Endpoint was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @endpoint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /endpoints/1
  # DELETE /endpoints/1.json
  def destroy
    @endpoint = Endpoint.find(params[:id])
    @endpoint.destroy

    respond_to do |format|
      format.html { redirect_to endpoints_url }
      format.json { head :ok }
    end
  end
end
