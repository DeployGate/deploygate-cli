module DeployGate
  module Build
    class Ios
      AD_HOC = 'ad-hoc'
      ENTERPRISE = 'enterprise'
      WORK_DIR_EXTNAMES = ['.xcworkspace', '.xcodeproj']
      EX_WORK_NAMES = ['Pods.xcodeproj', 'project.xcworkspace']

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

      def self.workspace?(path)
        WORK_DIR_EXTNAMES.include?(File.basename(path))
      end

      def self.find_workspaces(path)
        projects = []
        WORK_DIR_EXTNAMES.each do |pattern|
          rule = File::Find.new(:pattern => "*#{pattern}", :path => [path])
          rule.find {|f| projects.push(f) unless EX_WORK_NAMES.include?(File.basename(f))}
        end

        projects
      end

      def self.select_workspace(workspaces)
        select = workspaces.empty? ? nil : workspaces.first
        workspaces.each do |workspace|
          select = workspace if DeployGate::Build::Ios::WORK_DIR_EXTNAMES.first == File.extname(workspace)
        end

        select
      end
    end
  end
end
