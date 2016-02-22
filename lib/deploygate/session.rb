module DeployGate
  class Session
    class LoginError < DeployGate::NotIssueError
    end

    attr_reader :name, :token

    module ENVKey
      DG_USER_NAME = 'DG_USER_NAME'
      DG_TOKEN = 'DG_TOKEN'
    end

    @@login = nil

    # @return [DeployGate::Session]
    def initialize
      load_setting
    end

    # @return [Boolean]
    def login?
      @@login = @@login.nil? ? API::V1::Session.check(@name, @token) : @@login
    end

    def show_login_user
      API::V1::Session.show(@token)
    end

    # @param [String] email
    # @param [String] password
    # @return [void]
    def self.login(email, password)
      data = API::V1::Session.login(email, password)
      raise LoginError, data[:message] if data[:error]

      name = data[:name]
      token = data[:token]
      save(name, token)
      @@login = true
    end

    # @param [String] name
    # @param [String] token
    # @return [void]
    def self.save(name, token)
      settings = {
          :name => name,
          :token => token
      }
      Config::Credential.write(settings)
    end

    # @return [void]
    def self.delete
      save('', '') # delete config values
      @@login = false
    end

    private

    # @return [void]
    def load_setting
      return if load_env
      return unless Config::Credential.exist?
      settings = Config::Credential.read

      @name = settings['name']
      @token = settings['token']
    end

    # @return [Boolean]
    def load_env
      @name = ENV[ENVKey::DG_USER_NAME]
      @token = ENV[ENVKey::DG_TOKEN]

      !@name.nil? && !@token.nil?
    end

  end
end
