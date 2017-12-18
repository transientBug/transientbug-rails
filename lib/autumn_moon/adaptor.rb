module AutumnMoon
  class Adaptor
    def initialize *data
      @args = data
    end

    def send reply_obj
      fail NotImplementedError
    end

    def parse raw_payload
      #fail NotImplementedError

      chat_obj = Chat.new id: raw_payload[:chat][:id]
      user_obj = User.new id: raw_payload[:user][:id]

      message_obj = Message.new text: raw_payload[:text], chat: chat_obj, user: user_obj

      message_obj
    end

    def receive with_bot:
      fail NotImplementedError

      # payload = fetch
      # message_obj = parse payload
      # with_bot.dispatch message_obj
      # send result
    end
  end
end
