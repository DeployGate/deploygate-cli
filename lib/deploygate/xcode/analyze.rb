module DeployGate
  module Xcode
    class Analyze
      attr_reader :workspaces, :scheme_workspace, :build_workspace, :scheme, :xcodeproj

      BASE_WORK_DIR_NAME = 'project.xcworkspace'
      DEFAULT_BUILD_CONFIGURATION = 'Release'

      PROVISIONING_STYLE_AUTOMATIC = 'Automatic'
      PROVISIONING_STYLE_MANUAL    = 'Manual'

      class BundleIdentifierDifferentError < DeployGate::RavenIgnoreException
      end

      # @param [Array] workspaces
      # @param [String] build_configuration
      # @param [String] target_scheme
      # @return [DeployGate::Xcode::Analyze]
      def initialize(workspaces, build_configuration = nil, target_scheme = nil)
        @workspaces = workspaces
        @build_configuration = build_configuration || DEFAULT_BUILD_CONFIGURATION
        @scheme_workspace = find_scheme_workspace(workspaces)
        @build_workspace = find_build_workspace(workspaces)
        @xcodeproj = File.dirname(@scheme_workspace)

        config = FastlaneCore::Configuration.create(Gym::Options.available_options, { project: @xcodeproj })
        Gym.config = config
        @project = FastlaneCore::Project.new(config)

        if @project.schemes.length > 1 && target_scheme && @project.schemes.include?(target_scheme)
          @project.options[:scheme] = target_scheme
        else
          @project.select_scheme
        end
        @scheme = @project.options[:scheme]
      end

      def code_sign_style
        style = nil
        resolve_build_configuration do |build_configuration, target|
          style = build_configuration.resolve_build_setting("CODE_SIGN_STYLE", target)
        end

        style
      end

      def code_sign_identity
        identity = nil
        resolve_build_configuration do |build_configuration, target|
          identity = build_configuration.resolve_build_setting("CODE_SIGN_IDENTITY", target)
        end

        identity
      end

      # Support Xcode7 more
      # @return [String]
      def target_bundle_identifier
        bundle_identifier = nil
        resolve_build_configuration do |build_configuration, target|
          bundle_identifier = build_configuration.resolve_build_setting("PRODUCT_BUNDLE_IDENTIFIER", target)
        end

        bundle_identifier
      end

      def developer_team
        team = nil
        resolve_build_configuration do |build_configuration, target|
          team = build_configuration.resolve_build_setting("DEVELOPMENT_TEAM", target)
        end

        team
      end

      def project_profile_info
        gym = Gym::CodeSigningMapping.new(project: @project)

        {
            provisioningProfiles: gym.detect_project_profile_mapping
        }
      end

      def target_provisioning_profile
        gym = Gym::CodeSigningMapping.new(project: @project)
        bundle_id = target_bundle_identifier

        Xcode::Export.provisioning_profile(bundle_id, nil, developer_team, gym.merge_profile_mapping[bundle_id.to_sym])
      end

      private

      def resolve_build_configuration(&block)
        gym = Gym::CodeSigningMapping.new(project: @project)
        specified_configuration = gym.detect_configuration_for_archive

        Xcodeproj::Project.open(@xcodeproj).targets.each do |target|
          target.build_configuration_list.build_configurations.each do |build_configuration|
            # Used the following code as an example
            # https://github.com/fastlane/fastlane/blob/2.148.1/gym/lib/gym/code_signing_mapping.rb#L138
            current = build_configuration.build_settings
            next if gym.test_target?(current)
            sdk_root = build_configuration.resolve_build_setting("SDKROOT", target)
            next unless gym.same_platform?(sdk_root)
            next unless specified_configuration == build_configuration.name

            block.call(build_configuration, target)
          end
        end
      end

      # @param [Array] workspaces
      # @return [String]
      def find_scheme_workspace(workspaces)
        return nil if workspaces.empty?
        return workspaces.first if workspaces.count == 1

        select = nil
        workspaces.each do |workspace|
          if BASE_WORK_DIR_NAME == File.basename(workspace)
            select = workspace
          end
        end

        select
      end

      # @param [Array] workspaces
      # @return [String]
      def find_build_workspace(workspaces)
        return nil if workspaces.empty?
        return workspaces.first if workspaces.count == 1

        select = nil
        workspaces.each do |workspace|
          if BASE_WORK_DIR_NAME != File.basename(workspace)
            select = workspace
          end
        end

        select
      end
    end
  end
end
