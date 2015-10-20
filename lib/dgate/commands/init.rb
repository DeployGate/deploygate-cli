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
          puts 'Start login!'
          print 'Email: '
          email= STDIN.gets.chop
          print 'Password: '
          password = STDIN.noecho(&:gets).chop
          puts ''

          begin
            Session.login(email, password)
          rescue Session::LoginError => e
            # login failed
            Message::Error.print('Login failed')
            raise e
          end

          # login success
          Message::Success.print('Login success!')
        end

        # @return [void]
        def finish
          Message::Success.print('Finish dgate init!')
        end
      end
    end
  end
end
