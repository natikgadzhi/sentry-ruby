# frozen_string_literal: true

require "clockwork"

module Clockwork
  error_handler do |error|
    Sentry.capture_exception(error) if Sentry.initialized?
  end
end

module Sentry
  module Clockwork
    # Clockwork invokes Event.execute every time it runs a job.
    # We hook into it to wrap it with Monitor Check Ins
    module Event
      # def initialize(manager, period, job, block, options={})
      #   validate_if_option(options[:if])
      #   @manager = manager
      #   @period = period
      #   @job = job
      #   @at = At.parse(options[:at])
      #   @block = block
      #   @if = options[:if]
      #   @thread = options.fetch(:thread, @manager.config[:thread])
      #   @timezone = options.fetch(:tz, @manager.config[:tz])
      #   @skip_first_run = options[:skip_first_run]
      #   @last = @skip_first_run ? convert_timezone(Time.now) : nil
      # end
    end
  end
end

Sentry.register_patch(:sentry_clockwork) do



  Clockwork::Event.send(:include, Sentry::Cron::MonitorCheckIns)
  Clockwork::Event.send(:sentry_monitor_check_ins,
                        slug: name,
                        monitor_config: Sentry::Cron::MonitorConfig.from_crontab(cron))
end
