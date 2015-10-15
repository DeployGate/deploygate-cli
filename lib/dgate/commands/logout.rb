module Dgate
  module Commands
    class Logout
      class << self
        def run
          Dgate::Session.delete

          puts 'Logout finish!'
        end
      end
    end
  end
end
