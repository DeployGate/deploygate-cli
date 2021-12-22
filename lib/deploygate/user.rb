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
    # @return [Boolean]
    def self.registered?(name, email)
      DeployGate::API::V1::User.registered?(name, email)
    end
  end
end
