# frozen_string_literal: true

# == Schema Information
#
# Table name: clockwork_database_events
#
#  id                 :integer          not null, primary key
#  frequency_quantity :integer
#  frequency_period   :integer
#  at                 :string
#  job_name           :string
#  job_arguments      :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ClockworkDatabaseEvent < ApplicationRecord
  enum frequency_period: { seconds: 0, minutes: 1, hours: 2, days: 3, weeks: 4, months: 5 }

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
