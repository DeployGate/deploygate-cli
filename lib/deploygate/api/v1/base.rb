module DeployGate
  module API
    module V1
      class Base
        BASE_URL     = ENV['DG_DEVELOP_URL'] || 'https://deploygate.com'
        API_BASE_URL = "#{BASE_URL}/api"
        BASE_HEADERS = [
          ['X-DEPLOYGATE-CLIENT-ID', "cli/#{::DeployGate::VERSION_CODE}"],
          ['X-DEPLOYGATE-CLIENT-VERSION-NAME', ::DeployGate::VERSION],
        ].freeze

        # @param [String] token
        # @return [DeployGate::API::V1::Base]
        def initialize(token = nil)
          @token = token
        end

        # @param [String] path
        # @param [Hash] params
        # @return [Hash] Responce parse json
        def get(path, params)
          url = API_BASE_URL + path

          res = client.get(url, params, headers)
          JSON.parse(res.body)
        end

        # @param [String] path
        # @param [Hash] params
        # @yield Upload process block
        # @return [Hash] Responce parse json
        def post(path, params, &process_block)
          url = API_BASE_URL + path

          connection = client.post_async(url, params, headers)
          while true
            break if connection.finished?
            process_block.call unless process_block.nil?
          end
          io = connection.pop.content
          body = ''
          while str = io.read(40)
            body += str
          end

          JSON.parse(body)
        end

        private

        def client
          timeout = 60 * 5 # 5 minutes
          HTTPClient.new(agent_name: "dg/#{DeployGate::VERSION}").tap do |c|
            c.receive_timeout = timeout
            c.send_timeout = timeout
          end
        end

        def headers
          extheaders = BASE_HEADERS.dup

          unless @token.nil?
            extheaders.push(['AUTHORIZATION', "token #{@token}"])
          end

          extheaders
        end
      end
    end
  end
end
