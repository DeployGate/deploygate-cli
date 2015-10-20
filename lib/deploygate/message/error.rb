module DeployGate
  module Message
    class Error
      class << self
        def print(message)
          CE.once.ch :red
          puts message
        end
      end
    end
  end
end
