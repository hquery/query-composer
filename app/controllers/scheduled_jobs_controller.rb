require 'cud_actions'
class ScheduledJobsController < ActionController::Base
  include CudActions

  creates_updates_destroys :query

  def batch_query
    endpoint_ids = params[:endpoint_ids]

    if endpoint_ids && !endpoint_ids.empty?
      endpoint_ids = endpoint_ids.map! {|id| Moped::BSON::ObjectId(id)}
      endpoints = Endpoint.criteria.for_ids(endpoint_ids)

      notify = params[:notification]

      current_user.queries.each do |eachQuery|
        # execute the query, and pass in the endpoints and if the user should be notified by email when execution completes
        STDERR.puts "here"
        STDERR.puts current_user.inspect
        eachQuery.execute(endpoints, notify)
      end
    else
      flash[:alert] = 'Cannot execute a query if no endpoints are provided.'
    end
  end
end
