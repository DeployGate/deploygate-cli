module DeployGate
  class Deploy
    class NotLoginError < DeployGate::NotIssueError
    end
    class NotFileExistError < DeployGate::NotIssueError
    end
    class UploadError < DeployGate::NotIssueError
    end

    class << self

      # @param [String] file_path
      # @param [String] target_user
      # @param [String] message
      # @param [String] distribution_key
      # @param [Boolean] disable_notify
      # @yield Upload process block
      # @return [Hash]
      def push(file_path, target_user, message, distribution_key, disable_notify = false, &process_block)
        raise NotFileExistError, 'Target file is not found' if file_path.nil? || !File.exist?(file_path)

        session = DeployGate::Session.new()
        raise NotLoginError, 'Must login user' unless session.login?
        token = session.token


        data = API::V1::Push.upload(file_path, target_user, token, message, distribution_key || '', disable_notify) { process_block.call unless process_block.nil? }
        raise UploadError, data[:message] if data[:error]

        data
      end
    end
  end
end
