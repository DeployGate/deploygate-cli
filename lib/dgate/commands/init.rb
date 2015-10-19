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
            puts 'Login failed...'
            puts "Error message: #{data[:message]}"
            exit
          else
            # login success
            puts 'Login Success!'
          end
        end

        def finish
          puts 'Finish dgate init!'
        end
      end
    end
  end
end
