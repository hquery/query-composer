# Disclaimer - This has nothing to do with the UNIX cron. It is just similar in functionality
# Checks endpoints for active queries. If there are any it will pull the atom feed to
# see if there are any changes in status.
class EndpointCronJob
  include ScheduledJob
  
  run_every 5.minutes
  
  def perform
    Endpoint.all.each do |endpoint|
      if endpoint.unfinished_results?
        
      end
    end
  end
end