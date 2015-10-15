module Dgate
  class Deploy
    class << self
      def push(file_path, target_user, message, disable_notify)
        session = Dgate::Session.new()
        return unless session.login?
        token = session.token

        API::V1::Push.upload(file_path, target_user, token, message, disable_notify)
      end
    end
  end
end
