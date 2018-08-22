module DeployGate
  module Xcode
    module Ios
      WORK_DIR_EXTNAME = '.xcworkspace'
      PROJECT_DIR_EXTNAME = '.xcodeproj'
      IGNORE_DIRS = [ '.git', 'Carthage' ]

      class NotSupportExportMethodError < DeployGate::NotIssueError
      end

      class << self
        # @param [Analyze] ios_analyze
        # @param [String] target_scheme
        # @param [String] codesigning_identity
        # @param [String] provisioning_profile_info
        # @param [String] build_configuration
        # @param [String] export_method
        # @param [Boolean] allow_provisioning_updates
        # @return [String]
        def build(ios_analyze,
                  target_scheme,
                  codesigning_identity,
                  provisioning_profile_info = nil,
                  build_configuration = nil,
                  export_method = DeployGate::Xcode::Export::AD_HOC,
                  allow_provisioning_updates = false)
          raise NotSupportExportMethodError, 'Not support export' unless DeployGate::Xcode::Export::SUPPORT_EXPORT_METHOD.include?(export_method)

          values = {
              export_method: export_method,
              workspace: ios_analyze.build_workspace,
              configuration: build_configuration || DeployGate::Xcode::Analyze::DEFAULT_BUILD_CONFIGURATION,
              scheme: target_scheme
          }
          values[:codesigning_identity] = codesigning_identity if codesigning_identity
          if allow_provisioning_updates
            values[:xcargs]        = '-allowProvisioningUpdates'
            values[:export_xcargs] = '-allowProvisioningUpdates'
          end
          values[:export_options] = provisioning_profile_info if provisioning_profile_info

          v = FastlaneCore::Configuration.create(Gym::Options.available_options, values)

          begin
            absolute_ipa_path = File.expand_path(Gym::Manager.new.work(v))
          rescue => e
            # TODO: build error handling
            use_xcode_path = `xcode-select -p`
            puts HighLine.color(I18n.t('xcode.ios.build.error.use_xcode', use_xcode_path: use_xcode_path), HighLine::RED)
            raise e
          end
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

        def ios_root?(base_path)
          Find.find(base_path) do |path|
            next if path == base_path
            return true if workspace?(path) || project?(path)
            Find.prune if FileTest.directory?(path)
          end
          false
        end

        # @param [String] base_path
        # @param [Boolean] current_only
        # @return [Array]
        def find_workspaces(base_path)
          projects = []
          Find.find(base_path) do |path|
            next if path == base_path
            if File.extname(path) == WORK_DIR_EXTNAME
              projects.push(path)
            end

            Find.prune if FileTest.directory?(path) && IGNORE_DIRS.include?(File.basename(path))
          end

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
      end
    end
  end
end
