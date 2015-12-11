module DeployGate
  module Xcode
    module Ios
      WORK_DIR_EXTNAME = '.xcworkspace'
      PROJECT_DIR_EXTNAME = '.xcodeproj'

      class NotSupportExportMethodError < StandardError
      end

      class << self
        # @param [Analyze] ios_analyze
        # @param [String] target_scheme
        # @param [String] codesigning_identity
        # @param [String] export_method
        # @return [String]
        def build(ios_analyze, target_scheme, codesigning_identity, export_method = DeployGate::Xcode::Export::AD_HOC)
          raise NotSupportExportMethodError, 'Not support export' unless DeployGate::Xcode::Export::SUPPORT_EXPORT_METHOD.include?(export_method)

          values = {
              :export_method => export_method,
              :workspace => ios_analyze.build_workspace,
              :configuration => DeployGate::Xcode::Analyze::BUILD_CONFIGRATION,
              :scheme => target_scheme,
              :codesigning_identity => codesigning_identity
          }
          v = FastlaneCore::Configuration.create(Gym::Options.available_options, values)

          begin
            absolute_ipa_path = File.expand_path(Gym::Manager.new.work(v))
          rescue => e
            # TODO: build error handling
            use_xcode_path = `xcode-select -p`
            DeployGate::Message::Error.print("Current Xcode used to build: #{use_xcode_path} (via xcode-select)")
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
