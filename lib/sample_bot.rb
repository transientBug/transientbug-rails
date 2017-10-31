require "autumn_moon"
require "dark_sky"

class SampleBot < AutumnMoon::TelegramBot
  VERSION = "v0.0.0".freeze

  DARK_SKY_CLIENT = DarkSky.new token: Rails.application.credentials.dark_sky

  register AutumnMoon::Cache
  register AutumnMoon::ContextRouter

  command "/help", to: :testing_topic_help
  def testing_topic_help
    set_context :help

    body = <<~MSG
      Please choose a topic for more information
    MSG

    respond_with text: body, reply_markup: {
      keyboard: [
        [
          "Commands"
        ],
        [
          "About"
        ]
      ],
      resize_keyboard: true,
      one_time_keyboard: true,
    }
  end

  message "Commands", to: :help_commands, context: :help
  def help_commands
    body = <<~MSG
      Available commands:

      /help
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }
  end

  message "About", to: :help_about, context: :help
  def help_about
    body = <<~MSG
      #{ bot_name } - #{ VERSION }
      AutumnMoon Framework - Version #{ AutumnMoon::VERSION }

      Author: @JoshAshby
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }
  end

  command "/weather", to: :weather_check
  def weather_check
    weather = DARK_SKY_CLIENT.forecast latitude: 40.027435, longitude: -105.251945

    temp_wording = case weather[:currently][:temperature]
                   when -Float::INFINITY..40 then "COLD"
                   when 40..65 then "CHILLY"
                   when 65..80 then "NICE"
                   when 80..110 then "HOT"
                   else "¯\_(ツ)_/¯"
                   end

    precip_wording = case weather[:currently][:precipProbability]
                     when 0.0..0.15 then "PROBABLY DRY"
                     when 0.15..40 then "QUESTIONABLY WET"
                     when 0.40..0.60 then "PROBABLY WET"
                     when 0.60..1.0 then "SUPAWET"
                     else "NOAP"
                     end

    body = <<~MSG
      #{ weather[:currently][:icon] }
      WEATHER: #{ weather[:currently][:summary] }

      Temp: #{ temp_wording }
      Precip: #{ precip_wording }
    MSG

    respond_with text: body
  end

  inline_query "*", to: :inline
  def inline
    inline_reply_with results: [
    ]
  end

  default to: :default_route
  def default_route
    reply_with text: "I'm sorry, I don't know what to say"
  end
end
