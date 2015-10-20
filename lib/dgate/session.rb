module Dgate
  class Session
    attr_reader :name, :token

    @@login = nil

    # @return [Dgate::Session]
    def initialize
      load_setting
    end

    # @return [Boolean]
    def login?
      @@login = @@login.nil? ? API::V1::Session.check(@name, @token) : @@login
    end

    # @param [String] email
    # @param [String] password
    # @return [Hash]
    def self.login(email, password)
      data = API::V1::Session.login(email, password)

      unless data[:error]
        name = data[:name]
        token = data[:token]
        save(name, token)
      end

      data
    end

    # @param [String] name
    # @param [String] token
    # @return [void]
    def self.save(name, token)
      settings = {
          :name => name,
          :token => token
      }
      Config.write(settings)
    end

    # @return [void]
    def self.delete
      save('', '') # delete config values
      @@login = false
    end

    private

    # @return [void]
    def load_setting
      return unless Config.exist?
      settings = Config.read
      @name = settings['name']
      @token = settings['token']
    end

  end
end
