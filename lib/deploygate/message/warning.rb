module DeployGate
  module Message
    class Warning
      class << self
        def print(message)
          CE.once.ch :yellow
          puts message
        end
      end
    end
  end
end
