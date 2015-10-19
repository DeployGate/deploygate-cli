module Dgate
  class Deploy
    class NotLoginError < StandardError
    end
    class NotFileExistError < StandardError
    end

    class << self
      def push(file_path, target_user, message, disable_notify, &process_block)
        raise NotFileExistError, 'Target file is not found' if file_path.nil? || !File.exist?(file_path)

        session = Dgate::Session.new()
        raise NotLoginError, 'Must login user' unless session.login?
        token = session.token


        API::V1::Push.upload(file_path, target_user, token, message, disable_notify) { process_block.call }
      end
    end
  end
end
