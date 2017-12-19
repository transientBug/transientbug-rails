module AutumnMoon
  class Message
    attr_reader :chat, :user, :body, :original, :decompositions

    def initialize chat:, user: nil, body:, original: {}
      @chat = chat
      @user = user
      @body = body

      @original = original
    end

    def decompositions
      @decompositions ||= {}
    end
  end
end
