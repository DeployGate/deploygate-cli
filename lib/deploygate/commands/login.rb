module DeployGate
  module Commands
    class Login
      class << self

        # @return [void]
        def run(args, options)
          welcome()

          if options.terminal
            start_login_or_create_account()
          else
            DeployGate::BrowserLogin.new().start()
          end
        end

        def welcome
          puts I18n.t('commands.login.start_login_or_create_account.welcome')
          print_deploygate_aa()
        end

        # @return [void]
        def start_login_or_create_account
          puts ''
          email = ask(I18n.t('commands.login.start_login_or_create_account.email'))

          puts ''
          puts I18n.t('commands.login.start_login_or_create_account.check_account')
          if DeployGate::User.registered?('', email)
            puts ''
            password = input_password(I18n.t('commands.login.start_login_or_create_account.input_password'))
            puts ''
            start(email, password)
          else
            create_account(email)
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

        # @param [String] email
        # @return [void]
        def create_account(email)
          puts I18n.t('commands.login.create_account.prompt')
          puts ''

          name = input_new_account_name()
          puts ''

          password = input_new_account_password()
          puts ''

          unless check_terms
            puts HighLine.color(I18n.t('commands.login.check_terms.error'), HighLine::RED)
            exit 1
          end

          print I18n.t('commands.login.create_account.creating')
          if DeployGate::User.create(name, email, password).nil?
            puts HighLine.color(I18n.t('commands.login.create_account.error'), HighLine::RED)
            raise 'User create error'
          else
            puts HighLine.color(I18n.t('commands.login.create_account.success'), HighLine::GREEN)
            start(email, password)
          end
        end

        # @return [String]
        def input_new_account_name
          user_name = ask(I18n.t('commands.login.input_new_account_name.input_user_name'))
          print I18n.t('commands.login.input_new_account_name.checking')

          if DeployGate::User.registered?(user_name, '')
            puts HighLine.color(I18n.t('commands.login.input_new_account_name.already_used_user_name', user_name: user_name), HighLine::RED)
            return input_new_account_name()
          else
            puts HighLine.color(I18n.t('commands.login.input_new_account_name.success', user_name: user_name), HighLine::GREEN)
            return user_name
          end
        end

        # @return [String]
        def input_new_account_password
          password = input_password(I18n.t('commands.login.input_new_account_password.input_password'))
          secound_password = input_password(I18n.t('commands.login.input_new_account_password.input_same_password'))

          if password == secound_password
            return password
          else
            puts HighLine.color(I18n.t('commands.login.input_new_account_password.error'), HighLine::RED)
            return input_new_account_password()
          end
        end

        # @return [boolean]
        def check_terms
          puts I18n.t('commands.login.check_terms.terms_url')
          puts I18n.t('commands.login.check_terms.privacy_url')
          puts I18n.t('commands.login.check_terms.note')
          puts ''
          HighLine.agree(I18n.t('commands.login.check_terms.text')) {|q| q.default = "n"}
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
