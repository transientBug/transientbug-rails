class ServiceAnnouncement < ApplicationRecord
  # https://semantic-ui.com/globals/site.html#colors
  enum color: {
    plain: 0,
    red: 1,
    orange: 2,
    yellow: 3,
    olive: 4,
    green: 5,
    teal: 6,
    blue: 7,
    violet: 8,
    purple: 9,
    pink: 10,
    brown: 11,
    grey: 12,
    black: 13
  }

  # https://semantic-ui.com/elements/icon.html#message
  enum icon: {
    announcement: 0,
    help: 1,
    info: 2,
    warning: 3,
    talk: 4,
    settings: 5,
    alarm: 6,
    lab: 7
  }

  scope :active, ->{ where(active: true) }
  scope :current, ->{ where("(start_at IS NULL OR start_at <= NOW()) AND (end_at IS NULL OR end_at >= NOW())") }
  scope :displayable, ->{ active.current }
end
