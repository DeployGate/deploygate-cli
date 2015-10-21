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
            puts 'Select Export method:'
            puts '1. ad-hoc'
            puts '2. Enterprise'
            print '? '
            input = STDIN.gets.chop

            method = nil
            case input
              when '1'
                method = DeployGate::Builds::Ios::AD_HOC
              when '2'
                method = DeployGate::Builds::Ios::ENTERPRISE
            end

            ipa_path = DeployGate::Builds::Ios.new.build(workspaces, method)
            Push.upload([ipa_path], options)
          end
        end
      end
    end
  end
end
