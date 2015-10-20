module Dgate
  module Commands
    class Init
      class << self

        # @return [void]
        def run
          login unless Session.new().login?

          finish
        end

        # @return [void]
        def login
          puts 'Welcome to DeployGate!'
          puts ''
          print 'Email: '
          email= STDIN.gets.chop
          print 'Password: '
          password = STDIN.noecho(&:gets).chop
          puts ''

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

        # @return [void]
        def finish
          Message::Success.print('Enjoy development!')
        end
      end
    end
  end
end
