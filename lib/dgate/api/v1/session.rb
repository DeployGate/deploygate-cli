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
            return false if res['error']

            results = res['results']
            name  = results['name']
            token = results['api_token']
            Dgate::Session.save(name, token)

            true
          end
        end
      end
    end
  end
end
