module DeployGate
  class Build
    class << self
      def ios?(path)
        workspaces = DeployGate::Build::Ios.find_workspaces(path)
        DeployGate::Build::Ios.workspace?(path) || !workspaces.empty?
      end

      def android?(path)
        false # TODO: support android build
      end
    end
  end
end
