# Pulled from http://terrbear.org/?p=230
# Mixin to allow for recurring jobs with delayed_job
module Jobs
  module ScheduledJob
    def self.included(base)
      base.extend(ClassMethods)
    end

    def perform_with_schedule
      Delayed::Job.enqueue self, :run_at => self.class.schedule.from_now.getutc
      perform_without_schedule
    end

    module ClassMethods
      def method_added(name)
        if name.to_s == "perform" && !@redefined
          @redefined = true
          alias_method_chain :perform, :schedule
        end
      end

      def schedule
        @schedule
      end

      def run_every(time)
        @schedule = time
      end
    end
  end
end