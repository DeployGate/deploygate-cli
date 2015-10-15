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

            res = Dgate::Deploy.push(file_path, owner, message, disable_notify)

            web_url = BASE_URL + res['path']
            puts 'Push app file successful!'
            puts ''
            puts "Name :\t\t #{res['name']}"
            puts "Owner :\t\t #{res['user']['name']}"
            puts "Package :\t #{res['package_name']}"
            puts "Revision :\t #{res['revision'].to_s}"
            puts "URL :\t\t #{web_url}"
            if((open || res['revision'] == 1) && openable?)
              system "open #{web_url}"
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
