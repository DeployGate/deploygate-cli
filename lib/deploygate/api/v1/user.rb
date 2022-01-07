module DeployGate
  module API
    module V1
      class User

        ENDPOINT = '/users'

        class << self
          # @param [String] name
          # @param [String] email
          # @return [Boolean]
          def registered?(name, email)
            res = Base.new().get("#{ENDPOINT}/registered", {:name => name, :email => email})
            res['results']['registered']
          end
        end
      end
    end
  end
end
