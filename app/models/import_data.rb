# frozen_string_literal: true

# == Schema Information
#
# Table name: import_data
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  import_type :enum
#  complete    :boolean          default("false")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_import_data_on_user_id  (user_id)
#

class ImportData < ApplicationRecord
  belongs_to :user

  has_and_belongs_to_many :error_messages

  has_one_attached :upload

  enum import_type: {
    pinboard: "pinboard",
    pocket: "pocket",
  }

  after_create_commit :schedule_import

  protected

  def schedule_import()= ImportDataJob.perform_later(import_data: self)
end
