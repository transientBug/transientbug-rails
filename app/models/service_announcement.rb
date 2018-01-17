class ServiceAnnouncement < ApplicationRecord
  validates :color, inclusion: {
    in: %w( plain red orange yellow olive green teal blue violet purple pink brown grey black )
  }

  default_scope { active }

  def self.active
    where("(start_at IS NULL OR start_at <= NOW()) AND (end_at IS NULL OR end_at >= NOW())")
      .where(active: true)
  end
end
