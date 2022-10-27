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
              root_path = DeployGate::Xcode::Ios.project_root_path(work_dir)
              workspaces = DeployGate::Xcode::Ios.find_workspaces(root_path)
              ios(workspaces, options)
            elsif DeployGate::Project.android?(work_dir)
              DeployGate::Android::GradleDeploy.new(work_dir, options).deploy
            else
              print_no_target
            end
          end

          # @param [Array] workspaces
          # @param [Hash] options
          # @return [void]
          def ios(workspaces, options)
            DeployGate::Xcode::Export.check_local_certificates
            build_configuration = options.configuration
            target_scheme = options.scheme
            xcodeproj_path = options.xcodeproj

            analyze = DeployGate::Xcode::Analyze.new(workspaces, build_configuration, target_scheme, xcodeproj_path)
            target_scheme = analyze.scheme

            code_sign_identity = nil
            project_profile_info = nil
            allow_provisioning_updates = true
            if analyze.code_sign_style == Xcode::Analyze::PROVISIONING_STYLE_MANUAL
              code_sign_identity = analyze.code_sign_identity
              project_profile_info = analyze.project_profile_info
            end

            method = Xcode::Export.method(analyze.target_provisioning_profile) || select_method

            ipa_path = DeployGate::Xcode::Ios.build(
                analyze,
                target_scheme,
                code_sign_identity,
                project_profile_info,
                build_configuration,
                method,
                allow_provisioning_updates
            )
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

          def select_method
            result = nil
            cli = HighLine.new
            cli.choose do |menu|
              menu.prompt = I18n.t('commands.deploy.build.select_method.title')
              menu.choice(DeployGate::Xcode::Export::AD_HOC) {
                result = DeployGate::Xcode::Export::AD_HOC
              }
              menu.choice(DeployGate::Xcode::Export::ENTERPRISE) {
                result = DeployGate::Xcode::Export::ENTERPRISE
              }
            end

            result
          end
        end
      end
    end
  end
end
