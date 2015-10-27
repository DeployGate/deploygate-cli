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

            identifier = analyze.target_bundle_identifier(target_shceme)
            data = DeployGate::Builds::Ios::Export.find_local_data(identifier)
            profiles = data[:profiles]
            teams = data[:teams]

            target_provisioning_profile = nil
            if teams.empty?
              target_provisioning_profile = create_provisioning(identifier)
            elsif teams.count == 1
             target_provisioning_profile = DeployGate::Builds::Ios::Export.select_profile(profiles[teams.keys.first])
            elsif teams.count >= 2
              target_provisioning_profile = select_teams(teams, profiles)
            end
            method = DeployGate::Builds::Ios::Export.method(target_provisioning_profile)
            codesigning_identity = DeployGate::Builds::Ios::Export.codesigning_identity(target_provisioning_profile)

            ipa_path = DeployGate::Builds::Ios.build(analyze, target_shceme, codesigning_identity, method)
            Push.upload([ipa_path], options)
          end

          # @param [Array] schemes
          # @return [String]
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
          # @return [String]
          def create_provisioning(identifier)
            print 'apple developer Username: '
            username = STDIN.gets.chop

            begin
              set_profile = DeployGate::Builds::Ios::SetProfile.new(username, identifier)
            rescue => e
              DeployGate::Message::Error.print("Error: Please login try again")
              raise e
            end

            begin
              if set_profile.app_id_create
                puts "Create #{identifier} app id"
              end
            rescue => e
              DeployGate::Message::Error.print("Error: App id create error")
              raise e
            end

            begin
              provisioning_profile_path = set_profile.create_provisioning
            rescue => e
              DeployGate::Message::Error.print("Error: Failed create provisioning")
              raise e
            end

            provisioning_profile_path
          end
        end
      end
    end
  end
end
