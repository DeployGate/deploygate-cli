module DeployGate
  module Commands
    class Config
      class << self

        # @param [Array] args
        # @param [Commander::Command::Options] options
        def run(args, options)
          json_format  = options.json
          name         = options.name
          token        = options.token

          if name.nil? || token.nil?
            login_user = DeployGate::Session.new().show_login_user
            if login_user.nil?
              print_not_login(json_format)
            else
              print_login_user(login_user, json_format)
            end
          else
            login(name, token, json_format)
          end
        end

        # @param [String] name
        # @param [String] token
        # @param [Boolean] json_format
        # @return [void]
        def login(name, token, json_format)
          if API::V1::Session.check(name, token)
            DeployGate::Session.save(name, token)
            login_user = DeployGate::Session.new().show_login_user
            print_login_success(login_user, json_format)
          else
            print_login_failed(json_format)
          end
        end

        # @param [Hash] login_user
        # @param [Boolean] json_format
        # @return [void]
        def print_login_success(login_user, json_format)
          message = 'Login success'
          data = {:message => message, :error => false}

          unless json_format
            DeployGate::Message::Success.print(message)
            puts ''
          end

          print_login_user(login_user, json_format, data)
        end

        # @param [Boolean] json_format
        # @param [Hash] data
        # @return [void]
        def print_login_failed(json_format, data = {})
          message = 'Login failed'
          data[:error]   = true
          data[:message] = message

          if json_format
            print_json(data)
          else
            DeployGate::Message::Error.print(message)
            puts <<EOF

Please check your name and api token.
EOF
          end
        end

        # @param [Boolean] json_format
        # @param [Hash] data
        # @return [void]
        def print_not_login(json_format, data = {})
          message = 'Not user login'
          data[:error]   = true
          data[:message] = message

          if json_format
            print_json(data)
          else
            DeployGate::Message::Warning.print(message)
            puts <<EOF

Please login to dg command.
$ dg login
EOF
          end
        end

        # @param [Hash] login_user
        # @param [Boolean] json_format
        # @param [Hash] data
        # @return [void]
        def print_login_user(login_user, json_format, data = {})
          data[:error] = data[:error].nil? ? false : data[:error]
          data[:name]  = login_user['name']

          if json_format
            print_json(data)
          else
            puts <<EOF
User name: #{data[:name]}
EOF
          end
        end

        # @param [Hash] data
        # @return [void]
        def print_json(data)
          puts data.to_json
        end
      end
    end
  end
end
