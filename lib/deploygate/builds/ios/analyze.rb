module DeployGate
  module Builds
    module Ios
      class Analyze
        attr_reader :workspaces, :scheme_workspace, :build_workspace, :scheme

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

        # @return [String]
        def target_bundle_identifier
          scheme_file = find_xcschemes
          xs = Xcodeproj::XCScheme.new(scheme_file)
          target_name = xs.profile_action.buildable_product_runnable.buildable_reference.target_name

          project = Xcodeproj::Project.open(@xcodeproj)
          target = project.native_targets.reject{|target| target.name != target_name}.first
          product_name =  target.product_name
          conf = target.build_configuration_list.build_configurations.reject{|conf| conf.name != BUILD_CONFIGRATION}.first
          identifier = conf.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
          identifier.gsub!(/\$\(PRODUCT_NAME:.+\)/, product_name)

          identifier
        end

        private

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
end