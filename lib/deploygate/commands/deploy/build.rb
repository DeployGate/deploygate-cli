module DeployGate
  module Commands
    module Deploy
      class Build
        class << self
          def run(args, options)
            # android/ios build
            if DeployGate::Build::Ios::WORK_DIR_EXTNAMES.include?(File.extname(args.first))
              ios(args, options)
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
