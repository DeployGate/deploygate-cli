module DeployGate
  module Commands
    module Deploy
      class Build
        class << self

          # @param [Array] args
          # @param [Hash] options
          # @return [void]
          def run(args, options)
            # android/ios build
            work_dir = args.first

            if DeployGate::Build.ios?(work_dir)
              root_path = DeployGate::Builds::Ios.project_root_path(work_dir)
              workspaces = DeployGate::Builds::Ios.find_workspaces(root_path)
              ios(workspaces, options)
            elsif DeployGate::Build.android?(work_dir)
              # TODO: support android build
            end
          end

          # @param [Array] workspaces
          # @param [Hash] options
          # @return [void]
          def ios(workspaces, options)
            analyze = DeployGate::Builds::Ios::Analyze.new(workspaces)
            schemes = analyze.schemes
            target_shceme = schemes.first # TODO: select scheme user

            data = nil
            begin
              data = analyze.run(target_shceme)
            rescue DeployGate::Builds::Ios::Analyze::NotLocalProvisioningProfileError => e
              raise e # TODO: start fastlane/sigh
            end

            ipa_path = DeployGate::Builds::Ios.build(analyze, target_shceme, data[:method])
            Push.upload([ipa_path], options)
          end
        end
      end
    end
  end
end
