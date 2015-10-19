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
              upload_error({
                               :message => 'Target file is not found'
                           })
              return false
            end

            data = Dgate::Deploy.push(file_path, owner, message, disable_notify)

            if data[:error]
              upload_error(data)
            else
              upload_success(data, open)
            end
          end

          def openable?
            RbConfig::CONFIG['host_os'].include?('darwin')
          end


          def upload_success(data, open)
            Message::Success.print('Push app file successful!')
            data_message = <<EOS
Name: \t\t #{data[:application_name]}
Owner: \t\t #{data[:owner_name]}
Package: \t #{data[:package_name]}
Revision: \t #{data[:revision]}
URL: \t\t #{data[:web_url]}
EOS
            puts(data_message)
            if((open || data[:revision] == 1) && openable?)
              system "open #{data[:web_url]}"
            end
          end

          def upload_error(data)
            Message::Error.print('Push app file error!')
            puts "Error message: #{data[:message]}"
          end
        end
      end
    end
  end
end
