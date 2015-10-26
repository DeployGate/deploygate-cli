module DeployGate
  module Builds
    module Ios
      class Analyze
        attr_reader :workspaces, :scheme_workspace, :build_workspace

        class NotLocalProvisioningProfileError < StandardError
        end

        BASE_WORK_DIR_NAME = 'project.xcworkspace'
        BUILD_CONFIGRATION = 'Release'

        # @param [Array] workspaces
        # @return [DeployGate::Builds::Ios::Analyze]
        def initialize(workspaces)
          @workspaces = workspaces
          @scheme_workspace = find_scheme_workspace(workspaces)
          @build_workspace = find_build_workspace(workspaces)
        end

        # @return [Array]
        def schemes
          config = FastlaneCore::Configuration.create(Gym::Options.available_options, {:workspace => @scheme_workspace})
          project = FastlaneCore::Project.new(config)
          project.schemes
        end

        # @param [String] identifier
        # @return [String]
        def run(identifier)
          provisioning_profile = Export.target_provisioning_profile(identifier)
          raise NotLocalProvisioningProfileError if provisioning_profile.nil?

          Export.adhoc?(provisioning_profile) ? Export::AD_HOC : Export::ENTERPRISE
        end

        # @param [String] scheme_name
        # @return [String]
        def target_bundle_identifier(scheme_name)
          project_file = XCProjectFile.new(File.join(File.dirname(@scheme_workspace), PBXPROJ_FILE_NAME))
          target = project_file.project.targets.reject{|target| target['name'] != scheme_name}.first
          conf = target.build_configuration_list.build_configurations.reject{|conf| conf['name'] != BUILD_CONFIGRATION}.first
          conf['buildSettings']['PRODUCT_BUNDLE_IDENTIFIER']
        end

        private

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
end
