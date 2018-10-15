module DeployGate
  class User
    attr_reader :name

    # @param [String] name
    # @return [DeployGate::User]
    def initialize(name)
      @name = name
    end

    # @param [String] name
    # @param [String] email
    # @param [String] password
    # @return [nil or Hash]
    def self.create(name, email, password)
      locale = Locale.current.language
      results = DeployGate::API::V1::User.create(name, email, password, locale)
      return results if results[:error]
      DeployGate::User.new(results[:name])

      return nil
    end

    # @param [String] name
    # @param [String] email
    # @return [Boolean]
    def self.registered?(name, email)
      DeployGate::API::V1::User.registered?(name, email)
    end
  end
end
