module AutumnMoon
  class Message
    attr_reader :id, :chat, :user, :body, :original, :decompositions

    def initialize id:, chat:, user: nil, body:, original: {}
      @id   = id
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
