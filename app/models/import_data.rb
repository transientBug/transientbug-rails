class ImportData < ApplicationRecord
  belongs_to :user

  has_and_belongs_to_many :error_messages

  has_one_attached :upload

  enum import_type: {
    pinboard: "pinboard",
    pocket: "pocket"
  }

  after_create_commit :schedule_import

  def schedule_import
    ImportDataJob.perform_later import_data: self
  end
end
