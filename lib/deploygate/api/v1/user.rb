module DeployGate
  module API
    module V1
      class User

        ENDPOINT = '/users'

        class << self
          # @param [String] name
          # @param [String] email
          # @param [String] password
          # @param [String] locale
          # @return [Hash]
          def create(name, email, password, locale = 'en')
            res = Base.new().post(ENDPOINT, {:name => name, :email => email, :password => password, :locale => locale})

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
          def registered?(name, email)
            res = Base.new().get("#{ENDPOINT}/registered", {:name => name, :email => email})
            res['results']['registered']
          end
        end
      end
    end
  end
end
