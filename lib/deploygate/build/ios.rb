module DeployGate
  module Build
    class Ios
      AD_HOC = 'ad-hoc'
      ENTERPRISE = 'enterprise'
      WORK_DIR_EXTNAMES = ['.xcworkspace', '.xcodeproj']

      class NotWorkDirExistError < StandardError
      end

      attr_reader :work_path

      def initialize(work_path)
        @work_path = work_path
        raise NotWorkDirExistError, 'Not work dir exist' unless File.exist?(@work_path)
      end

      def build(export_method = AD_HOC)
        values = {
            :export_method => export_method,
            :workspace => @work_path
        }
        v = FastlaneCore::Configuration.create(Gym::Options.available_options, values)
        absolute_ipa_path = File.expand_path(Gym::Manager.new.work(v))
        absolute_dsym_path = absolute_ipa_path.gsub(".ipa", ".app.dSYM.zip") # TODO: upload to deploygate

        absolute_ipa_path
      end
    end
  end
end
