module Dgate
  module Commands
    module Deploy
      class Push
        BASE_URL = 'https://deploygate.com'

        class << self
          def upload(args, options)
            session = Dgate::Session.new()
            unless session.login?
              Init.login
              session = Dgate::Session.new()
            end

            message        = options.message
            owner          = options.user || session.name
            open           = options.open
            disable_notify = options.disable_notify

            file_path = args.first
            if file_path.nil? || !File.exist?(file_path)
              puts 'target file is not found.\n'
              return false
            end

            data = Dgate::Deploy.push(file_path, owner, message, disable_notify)

            puts 'Push app file successful!'
            puts ''
            puts "Name :\t\t #{data[:application_name]}"
            puts "Owner :\t\t #{data[:owner_name]}"
            puts "Package :\t #{data[:package_name]}"
            puts "Revision :\t #{data[:revision]}"
            puts "URL :\t\t #{data[:web_url]}"
            if((open || data[:revision] == 1) && openable?)
              system "open #{data[:web_url]}"
            end
          end

          def openable?
            RbConfig::CONFIG['host_os'].include?('darwin')
          end
        end
      end
    end
  end
end
