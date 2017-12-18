module AutumnMoon
  class Reply
    attr_reader :chat, :user, :body, :options

    def initialize chat:, user: nil, body:, **opts
      @chat = chat
      @user = user
      @body = body

      @options = opts
    end
  end
end
