module DeployGate
  module Commands
    module Deploy
      class Build
        COMMAND = 'build'

        class << self

          # @param [Array] args
          # @param [Hash] options
          # @return [void]
          def run(args, options)
            # android/ios build
            work_dir = args.empty? ? Dir.pwd : args.first

            # override options command
            options.command = options.command || COMMAND

            if DeployGate::Project.ios?(work_dir)
              ios(work_dir, options)
            elsif DeployGate::Project.android?(work_dir)
              DeployGate::Android::GradleDeploy.new(work_dir, options).deploy
            else
              print_no_target
            end
          end

          # @param [String] work_dir
          # @param [Hash] options
          # @return [void]
          def ios(work_dir, options)
            DeployGate::Xcode::Export.check_local_certificates

            # Change the current working directory for fastlane else.
            root_path = DeployGate::Xcode::Ios.project_root_path(work_dir)
            Dir.chdir(root_path)

            analyze = DeployGate::Xcode::Analyze.new(
                build_configuration: options.configuration,
                target_scheme: options.scheme,
                xcodeproj_path: options.xcodeproj
            )

            ipa_path = DeployGate::Xcode::Ios.build(ios_analyze: analyze)
            Push.upload([ipa_path], options)
          end

          def print_no_target
            puts ''
            puts HighLine.color(I18n.t('commands.deploy.build.print_no_target'), HighLine::YELLOW)
            puts ''
          end

          def over_xcode?(version_number)
            version = Gym::Xcode.xcode_version
            if version == nil
              print_no_install_xcode
              exit 1
            end

            version.split('.')[0].to_i >= version_number
          end

          def print_no_install_xcode
            puts ''
            puts HighLine.color(I18n.t('commands.deploy.build.print_no_install_xcode'), HighLine::YELLOW)
            puts ''
          end
        end
      end
    end
  end
end
