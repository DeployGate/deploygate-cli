module DeployGate
  module Commands
    class Logout
      class << self

        # @return [void]
        def run
          DeployGate::Session.delete

          Message::Success.print('Logout success!')
          Message::Success.print('Goodbye! :)')
        end
      end
    end
  end
end
