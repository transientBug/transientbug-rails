module AutumnMoon
  class Message
    attr_reader :chat, :user, :body, :decompositions

    def initialize chat:, user: nil, body:
      @chat = chat
      @user = user
      @body = body
    end

    def decompositions
      @decompositions ||= {}
    end
  end
end
