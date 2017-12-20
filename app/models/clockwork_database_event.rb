class ClockworkDatabaseEvent < ApplicationRecord
  enum frequency_period: [ :seconds, :minutes, :hours, :days, :weeks, :months ]

  def frequency
    frequency_quantity.send frequency_period.pluralize
  end

  def arguments
    job_arguments.symbolize_keys
  end

  def perform_async
    job_name.constantize.perform_later(**arguments)
  end
end
