require "autumn_moon"
require "dark_sky"
require "mapzen"

class SampleBot < AutumnMoon::TelegramBot
  VERSION = "v0.0.0".freeze

  DARK_SKY_CLIENT = DarkSky.new token: Rails.application.credentials.dark_sky
  MAPZEN_CLIENT = Mapzen.new token: Rails.application.credentials.mapzen

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

  command "/weather", to: :request_location, on: [ ->{ session[:user_location].blank? } ]
  def request_location
    body = <<~MSG
      OH NO! I don't seem to have a location on file for you!
      Where should I fetch the weather for?
    MSG

    respond_with text: body, reply_markup: {
      keyboard: [
        [ { text: "Can I haz location?", request_location: true } ],
        [ "Custom" ]
      ],
      resize_keyboard: true,
      one_time_keyboard: true
    }

    set_context :request_location
  end

  message "Custom", to: :custom_location, context: :request_location
  def custom_location
    body = <<~MSG
      Great! Where at? (say something like "Boulder, CO")
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }

    set_context :custom_location_search
  end

  message "*", to: :custom_location_search, context: :custom_location_search
  def custom_location_search
    results = MAPZEN_CLIENT.search(query: params[:text])
    session[:search_results] = results

    body = <<~MSG
      I found the following locations, but you can refine your search as well:

    MSG

    locations = results[:features].take(5).map.with_index do |feature, idx|
      body += "  #{ idx }) #{ feature[:properties][:label] }\n"
      { text: idx, callback_data: feature[:properties][:id] }
    end

    respond_with text: body, reply_markup: {
      inline_keyboard: [
        locations
      ]
    }

    set_context :custom_location_search
  end

  callback_query to: :choose_location, context: :custom_location_search
  def choose_location
    location = session[:search_results][:features].find do |feature|
      feature[:properties][:id] == params[:metadata][:data]
    end

    session[:user_location] = [:longitude, :latitude].zip(location[:geometry][:coordinates]).to_h

    edit_message_reply_markup inline_keyboard: [[]]
    respond_with text: "Great! I'll remember that when fetching the weather!", reply_markup: { remove_keyboard: true }

    weather_check
  end

  location to: :get_location, context: :request_location
  def get_location
    session[:user_location] = params[:metadata][:location]
    respond_with text: "Great! I'll remember that when fetching the weather!", reply_markup: { remove_keyboard: true }

    weather_check
  end

  command "/weather", to: :weather_check, on: [ ->{ session[:user_location].present? } ]
  def weather_check
    weather = DARK_SKY_CLIENT.forecast(**session[:user_location].symbolize_keys)

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

  # inline_query "*", to: :inline
  # def inline
    # inline_reply_with results: [
    # ]
  # end

  default to: :default_route
  def default_route
    reply_with text: "I'm sorry, I don't know what to say"
  end
end
