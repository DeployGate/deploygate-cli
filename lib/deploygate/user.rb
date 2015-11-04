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
    # @return [DeployGate::User]
    def self.create(name, email, password)
      results = DeployGate::API::V1::User.create(name, email, password)
      return if results[:error]
      DeployGate::User.new(results[:name])
    end

    # @param [String] email_or_name
    # @return [DeployGate::User]
    def self.find_user(email_or_name)
      results = DeployGate::API::V1::User.show(email_or_name)
      return if results[:error]
      DeployGate::User.new(results[:name])
    end
  end
end
