module DeployGate
  class BrowserLogin
    DEFAULT_PORT = 9292
    LOGIN_URL = "#{DeployGate::API::V1::Base::BASE_URL}/cli/login"
    CREDENTIAL_URL = "#{DeployGate::API::V1::Base::BASE_URL}/cli/credential"
    NOTIFY_URL = "#{DeployGate::API::V1::Base::BASE_URL}/cli/notify"

    # @param [Fixnum] port
    def initialize(port = nil)
      @port = port || DEFAULT_PORT
      @login_uri = URI(LOGIN_URL)
      @login_uri.query = {port: @port, client: 'dg'}.to_query

      @credential_uri = URI(CREDENTIAL_URL)
      @notify_uri = URI(NOTIFY_URL)
    end

    def start
      server = WEBrick::HTTPServer.new(
          :Port => @port,
          :BindAddress =>"localhost",
          :Logger => WEBrick::Log.new(STDOUT, 0),
          :AccessLog => []
      )

      begin
        Signal.trap("INT") { server.shutdown }

        server.mount_proc '/' do |req, res|
          res.status = WEBrick::HTTPStatus::RC_NO_CONTENT

          cancel = req.query['cancel']
          notify_key = req.query['key']

          unless cancel
            credential = get_credential(notify_key)
            DeployGate::Session.save(credential['name'], credential['token'])
            notify_finish(notify_key)

            DeployGate::Commands::Login.login_success()
          end

          server.stop
        end

        Launchy.open(@login_uri.to_s)
        server.start
      ensure
        server.shutdown
      end
    end

    private

    # @param [String] notify_key
    # @return [Hash]
    def get_credential(notify_key)
      res = HTTPClient.new(:agent_name => "dg/#{DeployGate::VERSION}").get(@credential_uri.to_s, {key: notify_key})
      JSON.parse(res.body)
    end

    # @param [String] notify_key
    def notify_finish(notify_key)
      HTTPClient.new(:agent_name => "dg/#{DeployGate::VERSION}").post(@notify_uri.to_s, {key: notify_key, command_action: 'finished'})
    end
  end
end
