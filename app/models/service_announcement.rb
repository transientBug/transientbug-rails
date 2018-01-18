class ServiceAnnouncement < ApplicationRecord
  validates :color, inclusion: {
    in: %w( plain red orange yellow olive green teal blue violet purple pink brown grey black )
  }

  scope :active, ->{ where(active: true) }
  scope :current, ->{ where("(start_at IS NULL OR start_at <= NOW()) AND (end_at IS NULL OR end_at >= NOW())") }
  scope :displayable, ->{ active.current }
end
