module DeployGate
  module Builds
    class Ios
      AD_HOC = 'ad-hoc'
      ENTERPRISE = 'enterprise'
      SUPPORT_EXPORT_METHOD = [AD_HOC, ENTERPRISE]
      WORK_DIR_EXTNAMES = ['.xcworkspace', '.xcodeproj']
      EX_WORK_NAMES = ['Pods.xcodeproj', 'project.xcworkspace']

      class NotWorkDirExistError < StandardError
      end
      class NotSupportExportMethodError < StandardError
      end

      attr_reader :work_path

      # @param [String] work_path
      # @return [DeployGate::Builds::Ios]
      def initialize(work_path)
        @work_path = work_path
        raise NotWorkDirExistError, 'Not work dir exist' unless File.exist?(@work_path)
      end

      # @param [String] export_method
      # @return [String]
      def build(export_method = AD_HOC)
        raise NotSupportExportMethodError, 'Not support export' unless SUPPORT_EXPORT_METHOD.include?(export_method)

        values = {
            :export_method => export_method,
            :workspace => @work_path
        }
        v = FastlaneCore::Configuration.create(Gym::Options.available_options, values)
        absolute_ipa_path = File.expand_path(Gym::Manager.new.work(v))
        absolute_dsym_path = absolute_ipa_path.gsub(".ipa", ".app.dSYM.zip") # TODO: upload to deploygate

        absolute_ipa_path
      end

      # @param [String] path
      # @return [Boolean]
      def self.workspace?(path)
        WORK_DIR_EXTNAMES.include?(File.basename(path))
      end

      # @param [String] path
      # @return [Array]
      def self.find_workspaces(path)
        projects = []
        WORK_DIR_EXTNAMES.each do |pattern|
          rule = File::Find.new(:pattern => "*#{pattern}", :path => [path])
          rule.find {|f| projects.push(f) unless EX_WORK_NAMES.include?(File.basename(f))}
        end

        projects
      end

      # @param [Array] workspaces
      # @return [String]
      def self.select_workspace(workspaces)
        select = workspaces.empty? ? nil : workspaces.first
        workspaces.each do |workspace|
          select = workspace if DeployGate::Builds::Ios::WORK_DIR_EXTNAMES.first == File.extname(workspace)
        end

        select
      end
    end
  end
end
