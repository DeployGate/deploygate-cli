module DeployGate
  module Xcode
    class Analyze
      attr_reader :workspaces, :scheme_workspace, :build_workspace, :scheme

      BASE_WORK_DIR_NAME = 'project.xcworkspace'
      BUILD_CONFIGRATION = 'Release'

      class BundleIdentifierDifferentError < DeployGate::NotIssueError
      end

      # @param [Array] workspaces
      # @return [DeployGate::Xcode::Analyze]
      def initialize(workspaces)
        @workspaces = workspaces
        @scheme_workspace = find_scheme_workspace(workspaces)
        @build_workspace = find_build_workspace(workspaces)
        @xcodeproj = File.dirname(@scheme_workspace)

        config = FastlaneCore::Configuration.create(Gym::Options.available_options, {:workspace => @scheme_workspace})
        project = FastlaneCore::Project.new(config)
        if project.schemes.empty?
          config = FastlaneCore::Configuration.create(Gym::Options.available_options, {:workspace => @build_workspace})
          project = FastlaneCore::Project.new(config)
        end
        project.select_scheme
        @scheme = project.options[:scheme]
      end

      # Support Xcode7 more
      # @return [String]
      def target_bundle_identifier
        begin
          product_name = target_product_name
          product_bundle_identifier = target_build_configration.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
          product_bundle_identifier = convert_bundle_identifier(product_bundle_identifier)

          info_plist_file_path = target_build_configration.build_settings['INFOPLIST_FILE']
          root_path = DeployGate::Xcode::Ios.project_root_path(@scheme_workspace)
          plist_bundle_identifier =
              File.open(File.join(root_path, info_plist_file_path)) do |file|
                plist = Plist.parse_xml file.read
                plist['CFBundleIdentifier']
              end
          plist_bundle_identifier = convert_bundle_identifier(plist_bundle_identifier)

          if product_bundle_identifier != plist_bundle_identifier
            raise BundleIdentifierDifferentError,
                  I18n.t('xcode.analyze.target_bundle_identifier.bundle_identifier_different', plist_id: plist_bundle_identifier, product_id: product_bundle_identifier)
          end

          bundle_identifier = product_bundle_identifier
          bundle_identifier.gsub!(/\$\(PRODUCT_NAME:.+\)/, product_name)
        rescue BundleIdentifierDifferentError => e
          raise e
        rescue => e
          cli = HighLine.new
          puts I18n.t('xcode.analyze.target_bundle_identifier.prompt')
          bundle_identifier = cli.ask(I18n.t('xcode.analyze.target_bundle_identifier.ask')) { |q| q.validate = /^(\w+)\.(\w+).*\w$/ }
        end

        bundle_identifier
      end

      # @param [String] bundle_identifier
      # @return [String]
      def convert_bundle_identifier(bundle_identifier)
        identifier = bundle_identifier
        if match = bundle_identifier.match(/\$\((.+)\)/)
          custom_id = match[1]
          identifier = target_build_configration.build_settings[custom_id]
        end
        identifier = convert_bundle_identifier(identifier) if bundle_identifier.match(/\$\((.+)\)/)

        identifier
      end

      # @return [String]
      def target_xcode_setting_provisioning_profile_uuid
        uuid = target_build_configration.build_settings['PROVISIONING_PROFILE']
        UUID.validate(uuid) ? uuid : nil
      end

      private

      def target_build_configration
        target_project_setting.build_configuration_list.build_configurations.reject{|conf| conf.name != BUILD_CONFIGRATION}.first
      end

      def target_product_name
        target_project_setting.product_name
      end

      def target_project_setting
        scheme_file = find_xcschemes
        xs = Xcodeproj::XCScheme.new(scheme_file)
        target_name = xs.profile_action.buildable_product_runnable.buildable_reference.target_name

        project = Xcodeproj::Project.open(@xcodeproj)
        project.native_targets.reject{|target| target.name != target_name}.first
      end

      def find_xcschemes
        shared_schemes = Dir[File.join(@xcodeproj, 'xcshareddata', 'xcschemes', '*.xcscheme')].reject do |scheme|
          @scheme != File.basename(scheme, '.xcscheme')
        end
        user_schemes = Dir[File.join(@xcodeproj, 'xcuserdata', '*.xcuserdatad', 'xcschemes', '*.xcscheme')].reject do |scheme|
          @scheme != File.basename(scheme, '.xcscheme')
        end

        shared_schemes.concat(user_schemes).first
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
