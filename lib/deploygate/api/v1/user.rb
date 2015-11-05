module DeployGate
  module API
    module V1
      class User

        ENDPOINT = '/users'

        class << self
          # @param [String] name
          # @param [String] email
          # @param [String] password
          # @return [Hash]
          def create(name, email, password)
            res = Base.new().post(ENDPOINT, {:name => name, :email => email, :password => password})

            user_create_results = {
                :error => res['error'],
                :message => res['because']
            }

            results = res['results']
            unless results.nil?
              user_create_results.merge!({
                                       :name => results['user']['name'],
                                       :token => results['api_token']
                                   })
            end

            user_create_results
          end

          # @param [String] name
          # @param [String] email
          # @return [Boolean]
          def already_registered?(name, email)
            res = Base.new().get("#{ENDPOINT}/check_already_registered", {:name => name, :email => email})
            res['results']['already_registered']
          end
        end
      end
    end
  end
end
