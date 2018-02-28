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
    # Totally foolproof
    if @import_data.upload.content_type == "application/json"
      @import_data.update import_type: "pinboard"
    else
      @import_data.update import_type: "pocket"
    end
  end

  def schedule_typed_job
    case @import_data.import_type
    when "pinboard"
      ImportData::PinboardJob.perform_later import_data: @import_data
    when "pocket"
      ImportData::PocketJob.perform_later import_data: @import_data
    end
  end
end
