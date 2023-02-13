module DeployGate
  module API
    module V1
      class Push
        ENDPOINT = "/users/%s/apps"

        class << self

          # @param [String] command
          # @param [String] file_path
          # @param [String] target_user
          # @param [String] token
          # @param [String] message
          # @param [String] distribution_key
          # @param [Boolean] disable_notify
          # @yield Upload process block
          # @return [Hash]
          def upload(command, file_path, target_user, token, message, distribution_key, disable_notify = false, &process_block)
            res = nil
            env_ci = ENV['CI']
            open(file_path) do |file|
              res = Base.new(token).post(
                sprintf(ENDPOINT, target_user),
                { :file => file ,
                  :message => message,
                  :distribution_key => distribution_key,
                  :disable_notify => disable_notify,
                  :dg_command => command || '',
                  :env_ci => env_ci
                }) { process_block.call unless process_block.nil? }
            end

            upload_results = {
                :error => res['error'],
                :message => res['because']
            }

            results = res['results']
            unless results.nil?
              upload_results.merge!({
                  :application_name => results['name'],
                  :owner_name => results['user']['name'],
                  :package_name => results['package_name'],
                  :revision => results['revision'],
                  :web_url => Base::BASE_URL + results['path']
              })
            end

            upload_results
          end
        end
      end
    end
  end
end
