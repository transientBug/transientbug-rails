# frozen_string_literal: true

# == Schema Information
#
# Table name: service_announcements
#
#  id             :bigint           not null, primary key
#  active         :boolean          default(TRUE)
#  color          :enum
#  color_text     :text
#  end_at         :datetime
#  icon           :enum
#  icon_text      :text
#  logged_in_only :boolean          default(FALSE)
#  message        :text
#  start_at       :datetime
#  title          :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ServiceAnnouncement < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :current, -> { where("(start_at IS NULL OR start_at <= NOW()) AND (end_at IS NULL OR end_at >= NOW())") }
  scope :displayable, -> { active.current }

  validates_presence_of :title, :message
end
