module Dgate
  module Commands
    class Logout
      class << self

        # @return [void]
        def run
          Dgate::Session.delete

          Message::Success.print('Logout finish!')
        end
      end
    end
  end
end
