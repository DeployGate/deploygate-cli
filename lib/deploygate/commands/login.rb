module DeployGate
  module Commands
    class Login
      class << self

        # @return [void]
        def run
          start_login_or_create_account() unless Session.new().login?

          finish
        end

        # @return [void]
        def start_login_or_create_account
          puts 'Welcome to DeployGate!'
          print_deploygate_aa()
          puts ''
          email = ask("Email: ")

          puts ''
          puts 'Checking for your account...'
          if DeployGate::User.registered?('', email)
            puts ''
            password = input_password('Password: ')
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
            Message::Error.print('Login failed...')
            Message::Error.print('Please try again')
            raise e
          end

          # login success
          session = Session.new
          Message::Success.print("Hello #{session.name}!")
        end

        # @param [String] email
        # @return [void]
        def create_account(email)
          puts "Looks new to DeployGate. Let's set up your account, just choose your username and password."
          puts ''

          name = input_new_account_name()
          puts ''

          password = input_new_account_password()
          puts ''

          print 'Creating your account... '
          if DeployGate::User.create(name, email, password).nil?
            Message::Error.print('User create error')
            Message::Error.print('Please try again')
            raise 'User create error'
          else
            Message::Success.print('done! Your account has been set up successfully.')
            start(email, password)
          end
        end

        # @return [String]
        def input_new_account_name
          user_name = ask("Username: " )
          print 'Checking for availability... '

          if DeployGate::User.registered?(user_name, '')
            Message::Error.print("Bad, #{user_name} is already used. Please try again.")
            return input_new_account_name()
          else
            Message::Success.print("Good, #{user_name} is available.")
            return user_name
          end
        end

        # @return [String]
        def input_new_account_password
          password = input_password('Password: ')
          secound_password = input_password('Type the same password: ')

          if password == secound_password
            return password
          else
            Message::Error.print("Password Please enter the same thing.")
            return input_new_account_password()
          end
        end

        # @return [String]
        def input_password(message)
          ask(message) { |q| q.echo = "*" }
        end

        # @return [void]
        def finish
          Message::Success.print('Enjoy development!')
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
