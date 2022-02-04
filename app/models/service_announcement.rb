# frozen_string_literal: true

# == Schema Information
#
# Table name: service_announcements
#
#  id             :integer          not null, primary key
#  title          :text
#  message        :text
#  color_text     :text
#  start_at       :datetime
#  end_at         :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  icon_text      :text
#  active         :boolean          default("true")
#  icon           :enum
#  color          :enum
#  logged_in_only :boolean          default("false")
#

class ServiceAnnouncement < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :current, -> { where("(start_at IS NULL OR start_at <= NOW()) AND (end_at IS NULL OR end_at >= NOW())") }
  scope :displayable, -> { active.current }

  validates :title, :message, presence: true
end
