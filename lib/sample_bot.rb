require "autumn_moon"
require "dark_sky"
require "mapzen"
require "rose"

class ContextDecomposer < AutumnMoon::Decomposer
  module ControllerMethods
    def set_context value
      session[:context] = value
    end

    def clear_context
      session.delete :context
    end
  end

  def modify_route route
    return route unless route.options[:context]

    route.on_conditions << lambda do
      session[:context] == route.options[:context]
    end
  end
end

class SampleBot < AutumnMoon::Bot
  VERSION = "v0.0.0".freeze

  router.add_decomposer AutumnMoon::Telegram::IntentDecomposer
  router.add_decomposer ContextDecomposer

  route "/start", to: "base_controller#start", intent: :command
  route "/help", to: "base_controller#testing_topic_help", intent: :command, doc: "get ye some infoz!"
  route "Commands", to: "base_controller#help_commands", intent: :message, context: :help
  route "About", to: "base_controller#help_about", intent: :message, context: :help

  route "/weather",
    to: "weather_controller#weather_check",
    intent: :command, on: [ ->{ session[:user_location].present? } ],
    doc: "get ye some weather!"

  route "/weather", to: "weather_controller#request_location", intent: :command, on: [ ->{ session[:user_location].blank? } ]
  route "Custom", to: "weather_controller#custom_location", intent: :message, context: :request_location
  route to: "weather_controller#custom_location_search", intent: :message, context: :custom_location_search
  route to: "weather_controller#choose_location", intent: :callback_query, context: :custom_location_search
  route to: "weather_controller#get_location", intent: :location, context: :request_location

  route to: "base_controller#default_route"
end

class BaseController < AutumnMoon::Controller
  include ContextDecomposer::ControllerMethods
  include AutumnMoon::Telegram::ControllerMethods

  def start
    respond_with text: "Hia!"
  end

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
      one_time_keyboard: true
    }
  end

  def help_commands
    body = <<~MSG
      Available commands:

    MSG

    bot.router.routes
      .select { |route|  route.options[:doc].present? }
      .each do |route|
        body += "#{ route.raw_pattern } - #{ route.options[:doc] }\n"
      end

    respond_with text: body, reply_markup: { remove_keyboard: true }
  end

  def help_about
    body = <<~MSG
      Version: #{ SampleBot::VERSION }
      AutumnMoon Ruby Bot Framework - Version: #{ AutumnMoon::VERSION }

      Author: @JoshAshby
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }
  end

  def default_route
    reply_with text: "I'm sorry, I don't know what to say"
  end
end

class WeatherController < AutumnMoon::Controller
  include ContextDecomposer::ControllerMethods
  include AutumnMoon::Telegram::ControllerMethods

  DARK_SKY_CLIENT = DarkSky.new token: Rails.application.credentials.dark_sky
  MAPZEN_CLIENT = Mapzen.new token: Rails.application.credentials.mapzen

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

  def custom_location
    body = <<~MSG
      Great! Where at? (say something like "Boulder, CO")
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }

    set_context :custom_location_search
  end

  def custom_location_search
    results = MAPZEN_CLIENT.search(query: message.body)
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

  def choose_location
    location = session[:search_results][:features].find do |feature|
      feature[:properties][:id] == message.body
    end

    session[:user_location] = [:longitude, :latitude].zip(location[:geometry][:coordinates]).to_h

    edit_message_reply_markup inline_keyboard: [[]]
    respond_with text: "Great! I'll remember that when fetching the weather!", reply_markup: { remove_keyboard: true }

    weather_check
  end

  def get_location
    session[:user_location] = message.original[:telegram][:message][:location]
    respond_with text: "Great! I'll remember that when fetching the weather!", reply_markup: { remove_keyboard: true }

    weather_check
  end

  def weather_check
    weather = DARK_SKY_CLIENT.forecast(**session[:user_location].symbolize_keys)

    temp_wording = TempRose.word weather[:currently][:temperature]
    precip_wording = PrecipRose.word weather[:currently][:precipIntensity]
    wind_direction_wording = CompassRose.direction weather[:currently][:windBearing]

    body = <<~MSG
      It's currently a #{ temp_wording } #{ weather[:currently][:temperature] }˚F with #{ precip_wording } precipitation
      #{ weather[:currently][:windSpeed] } mph winds from the #{ wind_direction_wording }

      Summary: #{ weather[:minutely][:summary] }

      Temperature: #{ weather[:currently][:temperature] }˚F
      Possibility of Precipitation: #{ weather[:currently][:precipProbability] * 100.0 }%

      Next Hour: #{ weather[:hourly][:summary] }
    MSG

    respond_with text: body
  end
end
