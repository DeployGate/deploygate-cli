module DeployGate
  class Build
    class << self

      # @param [String] path
      # @return [Boolean]
      def ios?(path)
        DeployGate::Builds::Ios.workspace?(path) || DeployGate::Builds::Ios.project?(path) || DeployGate::Builds::Ios.ios_root?(path)
      end

      # @param [String] path
      # @return [Boolean]
      def android?(path)
        false # TODO: support android build
      end
    end
  end
end
