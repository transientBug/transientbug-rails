module AutumnMoon
  class Session
    def self.data
      @data ||= Hash.new { |h, k| h[k] = {} }
    end

    attr_reader :chat, :user

    def initialize chat:, user: nil
      @chat = chat
      @user = user
    end

    def data
      self.class.data["#{ chat.id }:#{ user.id }"]
    end

    def [] key
      data[key]
    end

    def []= key, value
      data[key] = value
    end

    def fetch key, default
      data.fetch key, default
    end

    def delete key
      data.delete key
    end
  end
end
