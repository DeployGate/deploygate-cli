module DeployGate
  module Builds
    module Ios
      BASE_WORK_DIR_NAME = 'project.xcworkspace'
      WORK_DIR_EXTNAME = '.xcworkspace'
      PROJECT_DIR_EXTNAME = '.xcodeproj'

      class NotSupportExportMethodError < StandardError
      end

      class << self
        # @param [Array] workspaces
        # @param [String] export_method
        # @return [String]
        def build(workspaces, export_method = Export::AD_HOC)
          raise NotSupportExportMethodError, 'Not support export' unless Export::SUPPORT_EXPORT_METHOD.include?(export_method)

          scheme_workspace = scheme_workspace(workspaces)
          build_workspace  = build_workspace(workspaces)
          config = FastlaneCore::Configuration.create(Gym::Options.available_options, {:workspace => scheme_workspace})
          project = FastlaneCore::Project.new(config)
          schemes = project.schemes

          values = {
              :export_method => export_method,
              :workspace => build_workspace,
              :scheme => schemes.count == 1 ? schemes.first : nil
          }
          v = FastlaneCore::Configuration.create(Gym::Options.available_options, values)
          absolute_ipa_path = File.expand_path(Gym::Manager.new.work(v))
          absolute_dsym_path = absolute_ipa_path.gsub(".ipa", ".app.dSYM.zip") # TODO: upload to deploygate

          absolute_ipa_path
        end

        # @param [String] path
        # @return [Boolean]
        def workspace?(path)
          WORK_DIR_EXTNAME == File.extname(path)
        end

        # @param [String] path
        # @return [Boolean]
        def project?(path)
          PROJECT_DIR_EXTNAME == File.extname(path)
        end

        # @param [String] path
        # @return [Array]
        def find_workspaces(path)
          projects = []
          rule = File::Find.new(:pattern => "*#{WORK_DIR_EXTNAME}", :path => [path])
          rule.find {|f| projects.push(f)}

          projects
        end

        # @param [String] path
        # @return [String]
        def project_root_path(path)
          result = path
          if workspace?(path) || project?(path)
            result = project_root_path(File.dirname(path))
          end
          result
        end

        # @param [Array] workspaces
        # @return [String]
        def scheme_workspace(workspaces)
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
        def build_workspace(workspaces)
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
