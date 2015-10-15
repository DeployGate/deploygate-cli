module Dgate
  module API
    module V1
      class Base
        API_BASE_URL = 'https://deploygate.com/api'

        def initialize(name = nil, token = nil)
          @name = name
          @token = token
        end

        def get(path, params)
          url = API_BASE_URL + path
          client = new_client
          res = client.get(url, params, headers)
          return unless res.status_code == 200

          res_object = JSON.parse(res.body)
          return if res_object['error'] == true

          res_object['results']
        end

        def post(path, params)
          url = API_BASE_URL + path
          client = new_client
          res = client.post(url, params, headers)
          return unless res.status_code == 200

          res_object = JSON.parse(res.body)
          if res_object['error'] == true
            raise res_object['because'] || "error"
          end

          return res_object['results']
        end

        private

        def new_client
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
