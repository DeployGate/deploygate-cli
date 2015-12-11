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
              root_path = DeployGate::Xcode::Ios.project_root_path(work_dir)
              workspaces = DeployGate::Xcode::Ios.find_workspaces(root_path)
              ios(workspaces, options)
            elsif DeployGate::Build.android?(work_dir)
              # TODO: support android build
              print_no_target
            else
              print_no_target
            end
          end

          # @param [Array] workspaces
          # @param [Hash] options
          # @return [void]
          def ios(workspaces, options)
            DeployGate::Xcode::Export.check_local_certificates

            analyze = DeployGate::Xcode::Analyze.new(workspaces)
            target_scheme = analyze.scheme
            bundle_identifier = analyze.target_bundle_identifier
            xcode_provisioning_profile_uuid = analyze.target_xcode_setting_provisioning_profile_uuid

            target_provisioning_profile = DeployGate::Xcode::Export.provisioning_profile(bundle_identifier, xcode_provisioning_profile_uuid)
            method = DeployGate::Xcode::Export.method(target_provisioning_profile)
            codesigning_identity = DeployGate::Xcode::Export.codesigning_identity(target_provisioning_profile)

            ipa_path = DeployGate::Xcode::Ios.build(analyze, target_scheme, codesigning_identity, method)
            Push.upload([ipa_path], options)
          end

          def print_no_target
            message = <<EOF

No deploy target found.
Please run on the root directory of iOS project or specify .apk/.ipa file to deploy.

EOF
            DeployGate::Message::Warning.print(message)
          end
        end
      end
    end
  end
end
