module DeployGate
  module Config
    class Credential < Base
      class << self
        # @return [String]
        def file_path
          File.join(ENV["HOME"], '.dg/credentials')
        end
      end
    end
  end
end
