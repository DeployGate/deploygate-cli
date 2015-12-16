module DeployGate
  module Commands
    class Logout
      class << self

        # @return [void]
        def run
          DeployGate::Session.delete

          puts HighLine.color(I18n.t('commands.logout.success'), HighLine::GREEN)
        end
      end
    end
  end
end
