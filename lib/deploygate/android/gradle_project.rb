module DeployGate
  module Android
    class GradleProject
      class << self

        # @param [String] dir
        # @return [Boolean]
        def root_dir?(dir)
          File.exist?(File.join(dir, 'settings.gradle'))
        end
      end
    end
  end
end
