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
          send(:get, path, params)
        end

        def post(path, params)
          send(:post, path, params)
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

        def send(method, path, params)
          url = API_BASE_URL + path

          res = nil
          case method
            when :get
              res = client.get(url, params, headers)
            when :post
              res = client.post(url, params, headers)
          end
          return unless res.status_code == 200

          res_object = JSON.parse(res.body)
          return if res_object['error']

          res_object['results']
        end
      end
    end
  end
end
