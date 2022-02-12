# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@transientbug.ninja"
  layout "mailer"
end
