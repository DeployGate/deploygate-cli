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
              if DeployGate::Build::Ios.workspace?(work_dir)
                ios(args, options)
              else
                workspaces = DeployGate::Build::Ios.find_workspaces(work_dir)
                workspace = DeployGate::Build::Ios.select_workspace(workspaces)
                ios([workspace], options)
              end
            elsif DeployGate::Build.android?(work_dir)
              # TODO: support android build
            end
          end

          # @param [Array] args
          # @param [Hash] options
          # @return [void]
          def ios(args, options)
            ios = DeployGate::Build::Ios.new(args.first)

            puts 'Select Export method:'
            puts '1. ad-hoc'
            puts '2. Enterprise'
            print '? '
            input = STDIN.gets.chop

            method = nil
            case input
              when '1'
                method = DeployGate::Build::Ios::AD_HOC
              when '2'
                method = DeployGate::Build::Ios::ENTERPRISE
            end

            ipa_path = ios.build(method)
            Push.upload([ipa_path], options)
          end
        end
      end
    end
  end
end
