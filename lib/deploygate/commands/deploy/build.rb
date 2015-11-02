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
              print_no_target
            else
              print_no_target
            end
          end

          # @param [Array] workspaces
          # @param [Hash] options
          # @return [void]
          def ios(workspaces, options)
            analyze = DeployGate::Builds::Ios::Analyze.new(workspaces)
            target_scheme = analyze.scheme
            begin
              identifier = analyze.target_bundle_identifier
            rescue
              # not found bundle identifier
              puts 'Please input bundle identifier'
              puts 'Example: com.example.ios'
              identifier = input_bundle_identifier
            end
            uuid = analyze.target_xcode_setting_provisioning_profile_uuid

            data = DeployGate::Builds::Ios::Export.find_local_data(identifier, uuid)
            profiles = data[:profiles]
            teams = data[:teams]

            target_provisioning_profile = nil
            if teams.empty?
              target_provisioning_profile = create_provisioning(identifier, uuid)
            elsif teams.count == 1
              target_provisioning_profile = DeployGate::Builds::Ios::Export.select_profile(profiles[teams.keys.first])
            elsif teams.count >= 2
              target_provisioning_profile = select_teams(teams, profiles)
            end
            method = DeployGate::Builds::Ios::Export.method(target_provisioning_profile)
            codesigning_identity = DeployGate::Builds::Ios::Export.codesigning_identity(target_provisioning_profile)

            begin
              ipa_path = DeployGate::Builds::Ios.build(analyze, target_scheme, codesigning_identity, method)
            rescue => e
              # TODO: build error handling
              raise e
            end

            Push.upload([ipa_path], options)
          end

          def input_bundle_identifier
            print 'bundle identifier: '
            identifier = STDIN.gets.chop

            if identifier == '' || identifier.nil?
              puts 'You must input bundle identifier'
              return input_bundle_identifier
            end

            identifier
          end

          # @param [Hash] teams
          # @param [Hash] profiles
          # @return [String]
          def select_teams(teams, profiles)
            result = nil
            puts 'Select team:'
            teams.each_with_index do |team, index|
              puts "#{index + 1}. #{team[1]} (#{team[0]})"
            end
            print '? '
            select = STDIN.gets.chop
            begin
              team = teams.keys[Integer(select) - 1]
              team_profiles = profiles[team].first
              raise 'not select' if team_profiles.nil?

              result = DeployGate::Builds::Ios::Export.select_profile(profiles[team])
            rescue => e
              puts 'Please select team number'
              return select_teams(teams, profiles)
            end

            result
          end

          # @param [String] identifier
          # @param [String] uuid
          # @return [String]
          def create_provisioning(identifier, uuid)
            puts <<EOF

No suitable provisioning profile found to export the app.

Please enter your email and password for Apple Developer Center
to set up/download provisioning profile automatically so you can
export the app without any extra steps.

Note: Your password will be stored to Keychain and never be sent to DeployGate.

EOF
            print 'Email: '
            username = STDIN.gets.chop

            begin
              set_profile = DeployGate::Builds::Ios::SetProfile.new(username, identifier)
            rescue => e
              DeployGate::Message::Error.print("Error: Please try login again")
              raise e
            end

            begin
              if set_profile.app_id_create
                puts "App ID #{identifier} was created"
              end
            rescue => e
              DeployGate::Message::Error.print("Error: Failed to create App ID")
              raise e
            end

            begin
              provisioning_profiles = set_profile.create_provisioning(uuid)
            rescue => e
              DeployGate::Message::Error.print("Error: Failed to create provisioning profile")
              raise e
            end

            DeployGate::Builds::Ios::Export.select_profile(provisioning_profiles)
          end

          def print_no_target
            message = <<EOF

No target.
Please select apk/ipa file path or iOS working dir path.

EOF
            DeployGate::Message::Warning.print(message)
          end
        end
      end
    end
  end
end
