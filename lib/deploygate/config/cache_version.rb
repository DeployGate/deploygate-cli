module DeployGate
  module Config
    class CacheVersion < Base
      class << self
        # @return [String]
        def file_path
          File.join(ENV["HOME"], '.dg/version')
        end
      end
    end
  end
end
