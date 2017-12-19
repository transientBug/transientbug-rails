module AutumnMoon
  class Reply
    attr_reader :chat, :user, :body, :extra

    def initialize chat:, user: nil, body:, extra: {}
      @chat = chat
      @user = user
      @body = body

      @extra = extra
    end
  end
end
