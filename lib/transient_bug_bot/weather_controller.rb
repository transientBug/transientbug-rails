require "dark_sky"
require "mapzen"
require "rose"

class TransientBugBot
  class WeatherController < AutumnMoon::Controller
    include AutumnMoon::ContextDecomposer::ControllerMethods
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
end
