module DeployGate
  module Commands
    module Deploy
      class Push
        BASE_URL = 'https://deploygate.com'

        class << self

          # @param [Array] args
          # @param [Commander::Command::Options] options
          # @return [void]
          def upload(args, options)
            session = DeployGate::Session.new()
            unless session.login?
              Login.start_login_or_create_account()
              session = DeployGate::Session.new()
            end

            message          = options.message
            owner            = options.user || session.name
            distribution_key = options.distribution_key
            open             = options.open
            disable_notify   = options.disable_notify
            file_path        = args.first

            data = nil
            print I18n.t('commands.deploy.push.upload.loading', owner: owner)
            begin
              data = DeployGate::Deploy.push(file_path, owner, message, distribution_key, disable_notify) {
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
            puts HighLine.color(I18n.t('commands.deploy.push.upload_success.done'), HighLine::GREEN)
            puts I18n.t('commands.deploy.push.upload_success.data_message',
                        application_name: data[:application_name],
                        owner_name: data[:owner_name],
                        package_name: data[:package_name],
                        revision: data[:revision],
                        web_url: data[:web_url])
            if((open || data[:revision] == 1) && openable?)
              Launchy.open(data[:web_url])
            end
          end

          # @param [StandardError] error
          # @return [void]
          def upload_error(error)
            puts HighLine.color(I18n.t('commands.deploy.push.upload_error'), HighLine::RED)
            raise error
          end
        end
      end
    end
  end
end
