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

            analyze = DeployGate::Xcode::Analyze.new(workspaces, build_configuration, target_scheme)
            target_scheme = analyze.scheme

            # TODO: Support export method option (ex: --method adhoc)
            codesigning_identity= nil
            provisioning_style = analyze.provisioning_style
            provisioning_profile_info = nil
            if (!over_xcode?(8) && provisioning_style == nil) ||
                provisioning_style == DeployGate::Xcode::Analyze::PROVISIONING_STYLE_MANUAL

              # Only run Provisioning Style is Manual or nil
              bundle_identifier = analyze.target_bundle_identifier
              xcode_provisioning_profile_uuid = analyze.target_xcode_setting_provisioning_profile_uuid
              provisioning_team = analyze.provisioning_team
              target_provisioning_profile = DeployGate::Xcode::Export.provisioning_profile(
                  bundle_identifier,
                  xcode_provisioning_profile_uuid,
                  provisioning_team
              )

              method = DeployGate::Xcode::Export.method(target_provisioning_profile)
              codesigning_identity = DeployGate::Xcode::Export.codesigning_identity(target_provisioning_profile)

              profile = FastlaneCore::ProvisioningProfile.parse(target_provisioning_profile)
              provisioning_profile_info = {
                  provisioningProfiles: {
                      "#{bundle_identifier}" => profile['Name']
                  }
              }
            else
              method = select_method
            end

            ipa_path = DeployGate::Xcode::Ios.build(
                analyze,
                target_scheme,
                codesigning_identity,
                provisioning_profile_info,
                build_configuration,
                method,
                over_xcode?(9) && codesigning_identity.nil?
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
