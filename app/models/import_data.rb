# frozen_string_literal: true

# == Schema Information
#
# Table name: import_data
#
#  id          :bigint           not null, primary key
#  complete    :boolean          default("false")
#  import_type :enum
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_import_data_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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
