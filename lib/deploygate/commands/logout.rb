module DeployGate
  module Commands
    class Logout
      class << self

        # @return [void]
        def run
          DeployGate::Session.delete

          Message::Success.print(I18n.t('commands.logout.success'))
        end
      end
    end
  end
end
