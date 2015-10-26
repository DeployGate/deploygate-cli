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
            raise 'Scheme empty error' if schemes.empty?

            target_shceme = schemes.first
            if schemes.count > 1
              target_shceme = select_schemes(schemes)
            end

            data = nil
            begin
              data = analyze.run(target_shceme)
            rescue DeployGate::Builds::Ios::Analyze::NotLocalProvisioningProfileError => e
              raise e # TODO: start fastlane/sigh
            end

            ipa_path = DeployGate::Builds::Ios.build(analyze, target_shceme, data[:method])
            Push.upload([ipa_path], options)
          end

          def select_schemes(schemes)
            result = nil
            puts 'Select scheme:'
            schemes.each_with_index do |scheme, index|
              puts "#{index + 1}. #{scheme}"
            end
            print '? '
            select = STDIN.gets.chop
            begin
              result = schemes[Integer(select) - 1]
              raise 'not select' if result.nil?
            rescue => e
              puts 'Please select scheme number'
              return select_schemes(schemes)
            end

            result
          end
        end
      end
    end
  end
end
