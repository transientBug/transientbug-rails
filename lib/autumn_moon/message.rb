module AutumnMoon
  class Message
    attr_reader :chat, :user, :body, :options, :decompositions

    def initialize chat:, user: nil, body:, options: {}
      @chat = chat
      @user = user
      @body = body

      @options = options
    end

    def decompositions
      @decompositions ||= {}
    end
  end
end
