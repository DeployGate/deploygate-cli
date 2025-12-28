module DeployGate
  module Xcode
    module Ios
      WORK_DIR_EXTNAME = '.xcworkspace'
      PROJECT_DIR_EXTNAME = '.xcodeproj'

      class << self
        # @param [DeployGate::Xcode::Analyze] ios_analyze
        # @param [Boolean] allow_provisioning_updates
        # @return [String]
        def build(
          ios_analyze:,
          allow_provisioning_updates: true
        )
          if allow_provisioning_updates
            Gym.config[:xcargs]        = '-allowProvisioningUpdates'
            Gym.config[:export_xcargs] = '-allowProvisioningUpdates'
          end

          begin
            absolute_ipa_path = File.expand_path(Gym::Manager.new.work(ios_analyze.fastlane_config))
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
