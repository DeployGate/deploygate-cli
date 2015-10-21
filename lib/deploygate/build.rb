module DeployGate
  class Build
    class << self

      # @param [String] path
      # @return [Boolean]
      def ios?(path)
        workspaces = DeployGate::Builds::Ios.find_workspaces(path)
        DeployGate::Builds::Ios.workspace?(path) || DeployGate::Builds::Ios.project?(path) || !workspaces.empty?
      end

      # @param [String] path
      # @return [Boolean]
      def android?(path)
        false # TODO: support android build
      end
    end
  end
end
