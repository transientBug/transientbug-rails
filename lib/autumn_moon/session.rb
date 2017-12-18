module AutumnMoon
  class Session
    attr_reader :chat, :user

    def initialize chat:, user: nil
      @chat = chat
      @user = user

      @data = {}
    end

    def [] key
      @data[key]
    end

    def []= key, value
      @data[key] = value
    end

    def fetch key, default
      @data.fetch key, default
    end

    def delete key
      @data.delete key
    end
  end
end
