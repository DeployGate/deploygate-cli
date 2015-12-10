module DeployGate
  class Build
    class << self

      # @param [String] path
      # @return [Boolean]
      def ios?(path)
        DeployGate::Xcode::Ios.workspace?(path) || DeployGate::Xcode::Ios.project?(path) || DeployGate::Xcode::Ios.ios_root?(path)
      end

      # @param [String] path
      # @return [Boolean]
      def android?(path)
        false # TODO: support android build
      end
    end
  end
end
