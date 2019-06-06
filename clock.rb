require "clockwork"
require "clockwork/database_events"
require_relative "./config/boot"
require_relative "./config/environment"

module Clockwork
  # handler do |job|
  #   puts "Running #{job}"
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

  sync_database_events model: ClockworkDatabaseEvent, every: 1.minute, &:perform_async
end
