require "autumn_moon"

class TransientBugBot < AutumnMoon::Bot
  VERSION = "v0.1.0".freeze

  autoload :BaseController, "transient_bug_bot/base_controller"
  autoload :WeatherController, "transient_bug_bot/weather_controller"

  # Provides the `intent: :command` shortcut for routes and parses an intent
  # out of messages
  router.add_decomposer AutumnMoon::Telegram::IntentDecomposer

  # Provides the `context: :thing` shortcut for routes
  # Controllers can include the ControllerMethods mixin for `set_context` and
  # `clear_context`
  router.add_decomposer AutumnMoon::ContextDecomposer


  # Basic stuff for a base bot

  # Initial message from telegram. Would be bad course to not say anything to
  # this
  route "/start", to: "transient_bug_bot/base_controller#start",
    intent: :command

  # Get some help and information about this bot
  route "/help", to: "transient_bug_bot/base_controller#testing_topic_help",
    intent: :command,
    doc: "get ye some infoz!"

  route "Commands", to: "transient_bug_bot/base_controller#help_commands",
    intent: :message,
    context: :help

  route "About", to: "transient_bug_bot/base_controller#help_about",
    intent: :message,
    context: :help


  # Weather fetching
  route "/weather", to: "transient_bug_bot/weather_controller#weather_check",
    intent: :command, on: [ ->{ session[:user_location].present? } ],
    doc: "get ye some weather!"

  route "/weather",
    to: "transient_bug_bot/weather_controller#request_location",
    intent: :command,
    on: [ ->{ session[:user_location].blank? } ]

  route "Custom", to: "transient_bug_bot/weather_controller#custom_location",
    intent: :message,
    context: :request_location

  route to: "transient_bug_bot/weather_controller#custom_location_search",
    intent: :message,
    context: :custom_location_search

  route to: "transient_bug_bot/weather_controller#choose_location",
    intent: :callback_query,
    context: :custom_location_search

  route to: "transient_bug_bot/weather_controller#get_location",
    intent: :location,
    context: :request_location


  # Default route
  route to: "transient_bug_bot/base_controller#default_route"
end
