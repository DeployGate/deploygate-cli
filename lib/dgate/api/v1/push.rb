module Dgate
  module API
    module V1
      class Push
        ENDPOINT = "/users/%s/apps"

        class << self

          # @param [String] file_path
          # @param [String] target_user
          # @param [String] token
          # @param [String] message
          # @param [Boolean] disable_notify
          # @yield Upload process block
          # @return [Hash]
          def upload(file_path, target_user, token, message, disable_notify = false, &process_block)
            res = nil
            open(file_path) do |file|
              res = Base.new(token).post(
                sprintf(ENDPOINT, target_user),
                { :file => file , :message => message, :disable_notify => disable_notify ? 'yes' : 'no' }) { process_block.call unless process_block.nil? }
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
