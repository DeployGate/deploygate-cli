module Dgate
  module Commands
    module Deploy
      class << self
        def run(args, options)
          # push or build(android/ios)
          Push.upload(args, options)
        end
      end
    end
  end
end
