require 'stringio'
require 'net/http/post/multipart'
require 'poll_job'

class QueriesController < ApplicationController

  def index
    @queries = Query.all
  end

  def new
    @query = Query.new
  end

  def create
    @query = Query.new(params[:query])
    endpoint = Endpoint.new
    endpoint.submit_url = 'http://localhost:3001/queues'
    @query.endpoints << endpoint
    @query.save!
    redirect_to :action => 'show', :id=>@query.id
  end

  def show
    @query = Query.find(params[:id])
  end

  def edit
    @query = Query.find(params[:id])
  end
  
  def update
    @query = Query.find(params[:id])
    @query.update_attributes!(params[:query])
    render :action => 'show'
  end
  
  def execute
    @query = Query.find(params[:id])
    
    map = UploadIO.new(StringIO.new(@query.map), 'application/javascript')
    reduce = UploadIO.new(StringIO.new(@query.reduce), 'application/javascript')
    
    @query.endpoints.each do |endpoint|
      endpoint.result = nil
      url = URI.parse endpoint.submit_url
      request = Net::HTTP::Post::Multipart.new(url.path, {'map'=>map, 'reduce'=>reduce})
      PollJob.submit(request, url, @query, endpoint)
    end
    
    redirect_to :action => 'show'
  end

end
