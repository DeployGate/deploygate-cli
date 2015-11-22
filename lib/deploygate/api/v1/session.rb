module DeployGate
  module API
    module V1
      class Session
        ENDPOINT = '/sessions'

        class << self

          # @param [String] token
          # @return [Hash]
          def show(token)
            res = Base.new(token).get(ENDPOINT + '/user', {})
            return nil if res['error']

            res['results']
          end

          # @param [String] name
          # @param [String] token
          # @return [Boolean]
          def check(name, token)
            results = show(token)
            return false if results.nil?

            name == results['name']
          end

          # @param [String] email
          # @param [String] password
          # @return [Hash]
          def login(email, password)
            res = Base.new().post(ENDPOINT, {:email => email, :password => password})

            login_results = {
                :error => res['error'],
                :message => res['because']
            }

            results = res['results']
            unless results.nil?
              login_results.merge!({
                                       :name => results['name'],
                                       :token => results['api_token']
                                   })
            end

            login_results
          end
        end
      end
    end
  end
end
