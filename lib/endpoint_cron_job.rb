require_relative 'jobs/scheduled_job'

# Disclaimer - This has nothing to do with the UNIX cron. It is just similar in functionality
# Checks endpoints for active queries. If there are any it will pull the atom feed to
# see if there are any changes in status.
class EndpointCronJob
  include Jobs::ScheduledJob
  
  run_every 5.seconds
  
  def perform
    Endpoint.all.each do |endpoint|
      if endpoint.unfinished_results?
        endpoint.check
      end
    end
  end
end