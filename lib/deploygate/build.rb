module DeployGate
  class Build
    class << self

      # @param [String] path
      # @return [Boolean]
      def ios?(path)
        workspaces = DeployGate::Build::Ios.find_workspaces(path)
        DeployGate::Build::Ios.workspace?(path) || !workspaces.empty?
      end

      # @param [String] path
      # @return [Boolean]
      def android?(path)
        false # TODO: support android build
      end
    end
  end
end
