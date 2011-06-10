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
    endpoint.name = 'Default Local Queue'
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
  
  def destroy
    @query = Query.find(params[:id])
    @query.destroy

    redirect_to(queries_url)
  end
  
  
  def update
    @query = Query.find(params[:id])
    @query.update_attributes!(params[:query])
    render :action => 'show'
  end
  
  def update_endpoint
    @query = Query.find(params[:id])
    endpoint = @query.endpoints.find(params[:endpoint][:id])
    endpoint.update_attributes!(params[:endpoint])
    @query.save!
    render :action => 'edit'
  end
  
  def add_endpoint
    @query = Query.find(params[:id])
    endpoint = Endpoint.new
    endpoint.name = 'Default Local Queue'
    endpoint.submit_url = 'http://localhost:3001/queues'
    @query.endpoints << endpoint
    @query.save!
    render :action => 'edit'
  end
  
  def destroy_endpoint
    @query = Query.find(params[:id])
    endpoint = @query.endpoints.find(params[:endpoint][:id])
    endpoint.destroy
    render :action => 'edit'
  end
  
  def execute
    @query = Query.find(params[:id])
    @query.aggregate_result = nil
    
    @query.endpoints.each do |endpoint|
      filter = UploadIO.new(StringIO.new(@query.filter), 'application/json')
      map = UploadIO.new(StringIO.new(@query.map), 'application/javascript')
      reduce = UploadIO.new(StringIO.new(@query.reduce), 'application/javascript')
    
      endpoint.result = nil
      url = URI.parse endpoint.submit_url
      multipart_request = Net::HTTP::Post::Multipart.new(url.path, {'map'=>map, 'reduce'=>reduce, 'filter'=>filter})
      PollJob.submit(multipart_request, url, @query, endpoint)
    end
    @query.save!
    
    redirect_to :action => 'show'
  end
  
  def aggregate
    @query = Query.find(params[:id])
    queries_collection = MONGO_DB.collection('queries')
    result = queries_collection.map_reduce(map_fn, @query.reduce, :raw => true, :out => {:inline => true}, :query => {:_id => @query.id})
    @query.aggregate_result = result['results'][0]['value']
    @query.save!
    redirect_to :action => 'show', :id=>@query.id
  end
  
  def map_fn
    <<END_OF_FN
    function() {
      var query = this;
      for(var i=0;i<query.endpoints.length;i++) {
        var endpoint = query.endpoints[i];
        if (endpoint.status=="Complete") {
          emit(null, endpoint.result);
        }
      }
    }
END_OF_FN
  end

end
