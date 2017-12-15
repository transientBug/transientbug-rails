require "clockwork"
require "clockwork/database_events"
require_relative "./config/boot"
require_relative "./config/environment"

module Clockwork
  # handler do |job|
    # puts "Running #{job}"
  # end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  # every(10.seconds, 'frequent.job')
  # every(3.minutes, 'less.frequent.job')
  # every(1.hour, 'hourly.job')

  # every(1.day, 'midnight.job', at: '00:00')

  Clockwork.manager = DatabaseEvents::Manager.new

  sync_database_events model: ClockworkDatabaseEvent, every: 1.minute do |model_instance|
    # do some work e.g...

    # running a DelayedJob task, where #some_action is a method
    # you've defined on the model, which does the work you need
    # model_instance.delay.some_action

    # performing some work with Sidekiq
    # YourSidekiqWorkerClass.perform_async
    model_instance.perform_async
  end
end
