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
            provisioning_profiles = DeployGate::Builds::Ios::Export.target_provisioning_profiles(identifier)

            method = nil
            if provisioning_profiles.empty?
              method = create_provisioning(identifier)
            elsif provisioning_profiles.count == 1
              method = DeployGate::Builds::Ios::Export.method(provisioning_profiles.first)
            elsif provisioning_profiles.count >= 2
              # TODO: user select provisioning profile
            end

            ipa_path = DeployGate::Builds::Ios.build(analyze, target_shceme, method)
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
              set_profile.create_provisioning
            rescue => e
              DeployGate::Message::Error.print("Error: Failed create provisioning")
              raise e
            end

            set_profile.method
          end
        end
      end
    end
  end
end
