module DeployGate
  module Commands
    class Login
      class AccountNotFoundError < DeployGate::RavenIgnoreException; end

      class << self

        # @return [void]
        def run(args, options)
          welcome()

          if options.terminal
            start_login()
          else
            DeployGate::BrowserLogin.new().start()
          end
        end

        def welcome
          puts I18n.t('commands.login.start_login.welcome')
          print_deploygate_aa()
        end

        # @return [void]
        # @raise [AccountNotFoundError] emailに一致するUserが存在しないとき
        def start_login
          puts ''
          email = ask(I18n.t('commands.login.start_login.email'))

          puts ''
          puts I18n.t('commands.login.start_login.check_account')
          if DeployGate::User.registered?('', email)
            puts ''
            password = input_password(I18n.t('commands.login.start_login.input_password'))
            puts ''
            start(email, password)
          else
            raise AccountNotFoundError, HighLine.color(I18n.t('errors.account_not_found_error'))
          end
        end

        # @param [String] email
        # @param [String] password
        # @return [void]
        def start(email, password)
          begin
            Session.login(email, password)
          rescue Session::LoginError => e
            # login failed
            puts HighLine.color(I18n.t('commands.login.start.login_error'), HighLine::RED)
            raise e
          end

          login_success()
        end

        def login_success
          session = Session.new
          puts HighLine.color(I18n.t('commands.login.start.success', name: session.name), HighLine::GREEN)
        end

        # @return [String]
        def input_password(message)
          ask(message) { |q| q.echo = "*" }
        end

        def print_deploygate_aa
          puts <<'EOF'
         _            _                       _
        | |          | |                     | |
      __| | ___  ___ | | ___ _   ,____   ___ | |_ ___
     / _` |/ _ \' _ \| |/ _ \ \ / / _ \ / _ `| __/ _ \
    | (_| |  __/ |_) | | (_) \ v / (_| | (_| | |_' __/
     \___, \___| .__/|_|\___/ ` / \__, |\__,_|\__\___`
               |_|           /_/  |___/
EOF
        end
      end
    end
  end
end
