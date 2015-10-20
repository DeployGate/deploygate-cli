module DeployGate
  module Commands
    module Deploy
      class Build
        class << self
          def run(args, options)
            # android/ios build
            work_dir = args.first

            if DeployGate::Build::Ios::WORK_DIR_EXTNAMES.include?(File.extname(work_dir))
              ios(args, options)
            else
              projects = []
              DeployGate::Build::Ios::WORK_DIR_EXTNAMES.each do |pattern|
                rule = File::Find.new(:pattern => "*#{pattern}", :path => [work_dir])
                rule.find {|f| projects.push(f) unless DeployGate::Build::Ios::EX_WORK_NAMES.include?(File.basename(f))}
              end
              return if projects.empty?

              select_project = projects.first
              projects.each do |project|
                select_project = project if DeployGate::Build::Ios::WORK_DIR_EXTNAMES.first == File.extname(project)
              end
              ios([select_project], options)
            end
          end

          def ios(args, options)
            ios = DeployGate::Build::Ios.new(args.first)

            puts 'Select Export method:'
            puts '1. ad-hoc'
            puts '2. Enterprise'
            print '? '
            input = STDIN.gets.chop

            method = nil
            case input
              when '1'
                method = DeployGate::Build::Ios::AD_HOC
              when '2'
                method = DeployGate::Build::Ios::ENTERPRISE
            end

            ipa_path = ios.build(method)
            Push.upload([ipa_path], options)
          end
        end
      end
    end
  end
end
