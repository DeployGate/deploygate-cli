module Dgate
  module API
    module V1
      class Session
        ENDPOINT = '/sessions'

        class << self
          def check(name, token)
            res = Base.new(token).get(ENDPOINT + '/user', {})
            return false if res['error']

            name == res['results']['name']
          end

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
