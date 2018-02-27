class ImportDataJob < ApplicationJob
  queue_as :default
  attr_reader :import_data

  def perform import_data:
    @import_data = import_data

    determine_type
    schedule_typed_job
  end

  private

  def determine_type
    # TODO: Guess what this is going to be, since there are like 17 standards
    # for bookmark exports
    @import_data.update import_type: "pinboard"
  end

  def schedule_typed_job
    case @import_data.import_type
    when :pinboard
      ImportData::Pinboard.perform_later import_data: @import_data
    when :pocket
      ImportData::Pocket.perform_later import_data: @import_data
    end
  end
end
