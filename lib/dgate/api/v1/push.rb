module Dgate
  module API
    module V1
      class Push
        ENDPOINT = "/users/%s/apps"

        class << self
          def upload(file_path, target_user, token, message, disable_notify = false)
            res = nil
            open(file_path) do |file|
              res = Base.new(token).post(
                sprintf(ENDPOINT, target_user),
                { :file => file , :message => message, :disable_notify => disable_notify ? 'yes' : 'no' })
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
