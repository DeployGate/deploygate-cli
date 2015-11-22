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
          DeployGate::Message::Success.print('Login success')
          puts ''
          print_login_user(login_user, json_format)
        end

        # @param [Boolean] json_format
        # @return [void]
        def print_login_failed(json_format)
          DeployGate::Message::Error.print('Login failed')
          puts <<EOF

Please check your name and api token.
EOF
        end

        # @param [Boolean] json_format
        # @return [void]
        def print_not_login(json_format)
          DeployGate::Message::Warning.print('No user login')
          puts <<EOF

Please login to dg command.
$ dg login
EOF
        end

        # @param [Hash] login_user
        # @param [Boolean] json_format
        # @return [void]
        def print_login_user(login_user, json_format)
          puts <<EOF
User name: #{login_user['name']}
EOF
        end
      end
    end
  end
end
