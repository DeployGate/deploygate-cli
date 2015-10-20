module Dgate
  module Commands
    module Deploy
      class Push
        BASE_URL = 'https://deploygate.com'

        class << self

          # @param [Array] args
          # @param [Commander::Command::Options] options
          # @return [void]
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
            file_path      = args.first

            data = nil
            print "Uploading to #{owner}.."
            begin
              data = Dgate::Deploy.push(file_path, owner, message, disable_notify) {
                print '.'
                sleep 0.2
              }
            rescue => e
              upload_error(e)
            end

            upload_success(data, open)
          end

          # @return [Boolean]
          def openable?
            RbConfig::CONFIG['host_os'].include?('darwin')
          end

          # @param [Hash] data
          # @param [Boolean] open
          # @return [void]
          def upload_success(data, open)
            Message::Success.print('done')
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

          # @param [StandardError] error
          # @return [void]
          def upload_error(error)
            Message::Error.print('failed')
            raise error
          end
        end
      end
    end
  end
end
