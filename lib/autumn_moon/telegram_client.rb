module AutumnMoon
  class TelegramClient
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

      fail TelegramForbiddenError, error_message if status == 403
      fail TelegramNotFoundError, error_message if status == 404
      fail TelegramAPIError, "#{ res.status }: #{ error_message }"
    end

    def url for_action:
      @url_template.expand(action: for_action)
    end
  end
end
