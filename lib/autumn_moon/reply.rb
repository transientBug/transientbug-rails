module AutumnMoon
  class Reply
    attr_reader :chat, :user, :message, :body, :extra

    def initialize chat:, user: nil, message:, body:, extra: {}
      @chat = chat
      @user = user
      @message = message

      @body = body

      @extra = extra
    end
  end
end
