require "shadow_ridge"

class AutumnMoon
  class Handler
    class Route
      attr_reader :pattern, :method_name, :conditions

      def initialize pattern, method_name:, conditions: []
        @pattern = Mustermann.new pattern
        @conditions = Array(conditions)
        @method_name = method_name
      end

      def match params
        return false unless should_match? params
        return false unless pattern.match match_text_for(params)

        conditions.all? { |condition| condition.call params }
      end

      def should_match? params
        fail NotImplementedError
      end

      def match_text_for params
        fail NotImplementedError
      end
    end

    class CommandRoute < Route
      def should_match? params
        params[:entities][:bot_command].present?
      end

      def match_text_for params
        params[:entities][:bot_command]
      end
    end

    class HandlerRoute < Route
      def should_match? params
        true
      end

      def match_text_for params
        params[:text]
      end
    end

    class << self
      def routes
        @routes ||= []
      end

      def default_route
        @default_route ||= nil
      end

      def default to:
        @default_route = to
      end

      def command pattern, to:, on: []
        routes << CommandRoute.new(pattern, method_name: to, conditions: on)
      end

      def handle pattern, to:, on: []
        routes << HandlerRoute.new(pattern, method_name: to, conditions: on)
      end

      def route payload
        entities = payload[:entities].map do |entity|
          entity[:type] = entity[:type].to_sym
          entity[:text] = payload[:text][entity[:offset], entity[:length]]
          entity
        end.group_by { |entity| entity[:type] }

        if entities[:bot_command]
          entities[:bot_command] = entities[:bot_command].first[:text]
        end

        timestamp = Time.at payload[:date]

        params = {
          entities: entities,
          text: payload[:text],
          timestamp: timestamp
        }.merge payload.slice(:message_id, :from, :chat)

        route_handler = routes.find { |route| route.match(params) }
        route_handler ||= default_route

        new(params).public_send route_handler
      end
    end

    attr_reader :params

    def initialize params
      @params = params
    end

    # def respond_with type, params
    # end

    # def reply_with type, params
    # end

    # def answer_inline_query results, params:{}
    # end

    # def answer_callback_query text, params: {}
    # end

    # def edit_message type, params: {}
    # end
  end

  class SampleBot < Handler
    command "/help", to: :help
    default to: :help

    def help
      binding.pry
      # reply_with text: "#{ bot_name }: #{ bot_version }"
    end
  end

  class Client
    URL_TEMPLATE = "https://api.telegram.org/bot{token}/{action}".freeze

     # Pulled out of the telegram docs
    API_METHODS = %i{
      deleteWebhook
      getUpdates
      getWebhookInfo
      setWebhook

      getMe

      sendMessage
      forwardMessage

      sendPhoto
      sendAudio
      sendDocument
      sendVideo
      sendVoice
      sendVideoNote
      sendLocation
      editMessageLiveLocation
      stopMessageLiveLocation
      sendVenue
      sendContact
      sendChatAction

      getUserProfilePhotos
      getFile

      kickChatMember
      unbanChatMember
      restrictChatMember
      promoteChatMember

      exportChatInviteLink

      setChatPhoto
      deleteChatPhoto
      setChatTitle
      setChatDescription
      pinChatMessage
      unpinChatMessage
      leaveChat

      getChat
      getChatAdministrators
      getChatMembersCount
      getChatMember

      setChatStickerSet
      deleteChatStickerSet

      answerCallbackQuery
    }.freeze

    API_MAPPINGS = {
    }.freeze

    class TelegramForbiddenError < StandardError; end
    class TelegramNotFoundError < StandardError; end
    class TelegramAPIError < StandardError; end

    def initialize token:
      @token        = token
      @url_template = Addressable::Template.new(URL_TEMPLATE).partial_expand(token: token)
      @client       = ShadowRidge.new
    end

    API_METHODS.each do |func_name|
      define_method(func_name.to_s.underscore.to_sym) do |*args|
        body = args.first
        result = request(action: func_name, body: body)

        mapping = API_MAPPINGS[func_name]

        next result unless mapping

        mapping.call result
      end
    end

    private

    def request action:, body:
      res = @client.post url(for_action: action), json: body

      status = res.status

      parsed_response = JSON.parse res.body, symbolize_names: true
      return parsed_response[:result] if status < 300

      error_message = parsed_response.fetch :description, "N/A"

      fail TelegramForbidden, error_message if status == 403
      fail TelegramNotFound, error_message if status == 404
      fail TelegramAPIError, "#{ res.status }: #{ error_message }"
    end

    def url for_action:
      @url_template.expand(action: for_action)
    end
  end
end
