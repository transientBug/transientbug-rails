class ServiceAnnouncement < ApplicationRecord
  # https://semantic-ui.com/globals/site.html#colors
  enum color: {
    plain: "plain",
    red: "red",
    orange: "orange",
    yellow: "yellow",
    olive: "olive",
    green: "green",
    teal: "teal",
    blue: "blue",
    violet: "violet",
    purple: "purple",
    pink: "pink",
    brown: "brown",
    grey: "grey",
    black: "black"
  }

  # https://semantic-ui.com/elements/icon.html#message
  enum icon: {
    announcement: "announcement",
    help: "help",
    info: "info",
    warning: "warning",
    talk: "talk",
    settings: "settings",
    alarm: "alarm",
    lab: "lab"
  }

  scope :active, -> { where(active: true) }
  scope :current, -> { where("(start_at IS NULL OR start_at <= NOW()) AND (end_at IS NULL OR end_at >= NOW())") }
  scope :displayable, -> { active.current }
end
