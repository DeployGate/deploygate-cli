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

          if Session.login(email, password)
            # login success
            puts 'Login Success!'
          else
            # login failed
            puts 'Login failed...'
          end
        end

        def finish
          puts 'Finish dgate init!'
        end
      end
    end
  end
end
