class QueryLogger
  LOG_COLLECTION = "poll_job_log_events"

  def initialize(options = {})
    @mongo_db = options[:mongo] || MONGO_DB
  end
  
  def add(query, message, extra={})
    @mongo_db[LOG_COLLECTION].insert(extra.merge(
      {"query"=>query.id, "message"=>message, :time=>Time.new}))
  end
  
  def log(query_id)
    entries =  @mongo_db[LOG_COLLECTION].find({:query=>query_id}).to_a
  end
end
