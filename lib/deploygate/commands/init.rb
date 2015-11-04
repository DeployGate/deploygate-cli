module DeployGate
  module Commands
    class Init
      class << self

        # @return [void]
        def run
          start_login_or_create_account() unless Session.new().login?

          finish
        end

        # @return [void]
        def start_login_or_create_account
          puts 'Welcome to DeployGate!'
          puts ''
          print 'Email: '
          email = STDIN.gets.chop

          puts ''
          puts 'Checking for your account...'
          if DeployGate::User.find_user(email).nil?
            create_account(email)
          else
            puts ''
            password = input_password()
            puts ''
            login(email, password)
          end
        end

        # @param [String] email
        # @param [String] password
        # @return [void]
        def login(email, password)
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
            login(email, password)
          end
        end

        # @return [String]
        def input_new_account_name
          print 'Username: '
          user_name = STDIN.gets.chop
          print 'Checking for availability... '

          if DeployGate::User.find_user(user_name).nil?
            Message::Success.print("Good, #{user_name} is available.")
            return user_name
          else
            Message::Error.print("Bad, #{user_name} is already used. Please try again.")
            return input_new_account_name()
          end
        end

        # @return [String]
        def input_new_account_password
          print 'Password: '
          password = STDIN.noecho(&:gets).chop
          puts ''
          print 'Type the same password: '
          secound_password = STDIN.noecho(&:gets).chop

          if password == secound_password
            return password
          else
            puts ''
            Message::Error.print("Password Please enter the same thing.")
            return input_new_account_password()
          end
        end

        # @return [String]
        def input_password
          print 'Password: '
          password = STDIN.noecho(&:gets).chop
        end

        # @return [void]
        def finish
          Message::Success.print('Enjoy development!')
        end
      end
    end
  end
end
