module Dgate
  module Commands
    class Init
      class << self
        def run
          login unless Session.new().login?

          finish
        end

        def login
          puts 'Start login!'
          print 'Email: '
          email= STDIN.gets.chop
          print 'Password: '
          password = STDIN.noecho(&:gets).chop
          puts ''

          data = Session.login(email, password)
          if data[:error]
            # login failed
            Message::Error.print('Login failed')
            puts "Error message: #{data[:message]}"
            exit
          else
            # login success
            Message::Success.print('Login success!')
          end
        end

        def finish
          Message::Success.print('Finish dgate init!')
        end
      end
    end
  end
end
