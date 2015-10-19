module Dgate
  module Message
    class Success
      class << self
        def print(message)
          CE.once.ch :green
          puts message
        end
      end
    end
  end
end
