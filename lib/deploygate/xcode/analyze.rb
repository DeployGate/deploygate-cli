module DeployGate
  module Xcode

    # - xcworkspace can have multiple projects (.xcodeproj)
    # - xcodeproj can have multiple subprojects (.xcodeproj)
    #
    # This means we have to satisfy the following constraints.
    #
    # 1. Choose one xcworkspace if multiple workspaces are found. Some of
    # 2. Choose a proper xcodeproj (root. not subproject)
    class Analyze
      BASE_WORK_DIR_NAME = 'project.xcworkspace'
      DEFAULT_BUILD_CONFIGURATION = 'Release'

      PROVISIONING_STYLE_AUTOMATIC = 'Automatic'
      PROVISIONING_STYLE_MANUAL    = 'Manual'

      CODE_SIGN_STYLE_KEY = "CODE_SIGN_STYLE"
      CODE_SIGN_IDENTITY_KEY = "CODE_SIGN_IDENTITY"
      PRODUCT_BUNDLE_IDENTIFIER_KEY = "PRODUCT_BUNDLE_IDENTIFIER"
      DEVELOPMENT_TEAM_KEY = "DEVELOPMENT_TEAM"

      class BundleIdentifierDifferentError < DeployGate::RavenIgnoreException
      end
      class NotSupportExportMethodError < DeployGate::RavenIgnoreException
      end

      # @param [String, nil] build_configuration
      # @param [String, nil] target_scheme
      # @param [String, nil] xcodeproj_path
      # @return [DeployGate::Xcode::Analyze]
      def initialize(
        xcodeproj_path: nil,
        workspace_path: nil,
        build_configuration: nil,
        target_scheme: nil
      )
        # Don't duplicate this options. This would be modified through fastlane's methods.
        options = FastlaneCore::Configuration.create(
          Gym::Options.available_options,
          {
            project: xcodeproj_path.presence,
            workspace: workspace_path.presence,
            configuration: build_configuration,
            scheme: target_scheme
          }
        )

        # This will detect projects, scheme, configuration and so on. This also throws an error if invalid.
        # scheme, project/workspace, configuration, export_team_id would be resolved
        Gym.config = options

        options[:export_team_id] = Gym.project.build_settings(key: DEVELOPMENT_TEAM_KEY, optional: false)
        options[:codesigning_identity] = Gym.project.build_settings(key: CODE_SIGN_IDENTITY_KEY, optional: false) if Gym.project.build_settings(key: CODE_SIGN_STYLE_KEY) == PROVISIONING_STYLE_MANUAL

        # TODO: Need to support UDID additions for watchOS and App Extension

        if (profiles = Gym.config.values.dig(:export_options, :provisioningProfiles)).present?
          target_provisioning_profile = ::DeployGate::Xcode::Export.provisioning_profile(
            bundle_identifier,
            uuid = nil,
            options[:export_team_id],
            profiles[bundle_identifier.to_sym]
          )

          options[:export_method] = ::DeployGate::Xcode::Export.method(target_provisioning_profile) || select_export_method
        end
      ensure
        # Run value auto detection again after filling values
        Gym.config = Gym.config
      end

      # @return [String]
      def scheme
        fastlane_project.options[:scheme]
      end

      # @return [String]
      def xcodeproj_path
        if fastlane_project.workspace?
          available_schemes = fastlane_project.workspace.schemes.reject { |_, v| v.include?("Pods/Pods.xcodeproj") }
          available_schemes[self.scheme]
        else
          fastlane_project.project.path&.to_s
        end
      end

      def build_configuration
        Gym.detect_configuration_for_archive
      end

      def export_team_id
        fastlane_project.options[:export_team_id]
      end

      def export_method
        fastlane_project.options[:export_method]
      end

      def bundle_identifier
        Gym.project.build_settings(key: PRODUCT_BUNDLE_IDENTIFIER_KEY, optional: false)
      end

      # @return [Hash, FastlaneCore::Configuration]
      def fastlane_config
        Gym.config
      end

      private

      def select_export_method
        result = nil
        cli = HighLine.new
        cli.choose do |menu|
          menu.prompt = I18n.t('commands.deploy.build.select_method.title')
          menu.choice(::DeployGate::Xcode::Export::AD_HOC) {
            result = ::DeployGate::Xcode::Export::AD_HOC
          }
          menu.choice(DeployGate::Xcode::Export::ENTERPRISE) {
            result = ::DeployGate::Xcode::Export::ENTERPRISE
          }
        end

        raise NotSupportExportMethodError, "#{result} is not supported" unless ::DeployGate::Xcode::Export::SUPPORT_EXPORT_METHOD.include?(result)

        result
      end

      # @return [FastlaneCore::Project]
      def fastlane_project
        Gym.project
      end

      # @return [Xcodeproj::Project]
      def xcode_project
        #noinspection RubyMismatchedReturnType
        if fastlane_project.workspace?
          Xcodeproj::Project.open(self.xcodeproj_path)
        else
          fastlane_project.project
        end
      end
    end
  end
end
