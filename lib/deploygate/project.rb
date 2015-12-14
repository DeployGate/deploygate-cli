module DeployGate
  class Project
    class << self

      # @param [String] path
      # @return [Boolean]
      def ios?(path)
        DeployGate::Xcode::Ios.workspace?(path) || DeployGate::Xcode::Ios.project?(path) || DeployGate::Xcode::Ios.ios_root?(path)
      end

      # @param [String] path
      # @return [Boolean]
      def android?(path)
        DeployGate::Android::GradleProject.root_dir?(path)
      end
    end
  end
end
