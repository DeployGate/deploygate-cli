module Dgate
  module API
    module V1
      class Base
        BASE_URL     = 'https://deploygate.com'
        API_BASE_URL = "#{BASE_URL}/api"

        def initialize(token = nil)
          @token = token
        end

        def get(path, params)
          url = API_BASE_URL + path

          res = client.get(url, params, headers)
          JSON.parse(res.body)
        end

        def post(path, params)
          url = API_BASE_URL + path

          res = client.post(url, params, headers)
          JSON.parse(res.body)
        end

        private

        def client
          HTTPClient.new(:agent_name => "dgate/#{Dgate::VERSION}")
        end

        def headers
          extheaders = []
          unless @token.nil?
            extheaders.push(['AUTHORIZATION', @token])
          end

          extheaders
        end
      end
    end
  end
end
