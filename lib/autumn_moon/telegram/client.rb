module AutumnMoon
  module Telegram
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
        answerInlineQuery

        editMessageText
        editMessageCaption
        editMessageReplyMarkup
        deleteMessage
      }.freeze

      API_MAPPINGS = {
      }.freeze

      class ForbiddenError < StandardError; end
      class NotFoundError < StandardError; end
      class APIError < StandardError; end

      attr_reader :token

      def initialize token:
        @token        = token
        @url_template = Addressable::Template.new(URL_TEMPLATE).partial_expand(token: token)
        @client       = HTTP.headers(
          user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0) Gecko/20100101 Firefox/57.0",
          accept_language: "en-US,en;q=0.5",
          accept: "application/json;q=0.9,*/*;q=0.8; charset=utf-8"
        )
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

        fail ForbiddenError, error_message if status == 403
        fail NotFoundError, error_message if status == 404
        fail APIError, "#{ res.status }: #{ error_message }"
      end

      def url for_action:
        @url_template.expand(action: for_action)
      end
    end
  end
end
