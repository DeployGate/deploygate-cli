module DeployGate
  module Commands
    module Deploy
      class << self

        # @param [Array] args
        # @param [Commander::Command::Options] options
        def run(args, options)
          Init.start_login_or_create_account() unless DeployGate::Session.new.login?

          # push or build(android/ios)
          args.push(Dir.pwd) if args.empty?

          work_file_path = args.first
          if File.directory?(work_file_path)
            Build.run(args, options)
          else
            # file upload
            Push.upload(args, options)
          end
        end
      end
    end
  end
end
