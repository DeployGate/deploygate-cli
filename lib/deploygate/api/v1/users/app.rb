module DeployGate
  module API
    module V1
      module Users
        class App
          ENDPOINT = "/users/%s/platforms/%s/apps/%s"

          class << self
            def not_provisioned_udids(token, name, package_name, platform = 'ios')
              res = Base.new(token).get("#{sprintf(ENDPOINT, name, platform, package_name)}/udids", {})

              udids_results = {
                  :error => res['error'],
                  :message => res['because']
              }

              results = res['results']
              unless results.nil?
                results.reject!{|r| r['is_provisioned']}

                udids_results[:results] =
                    results.map do |result|
                      {
                          :udid => result['udid'],
                          :user_name => result['user_name'],
                          :device_name => result['device_name'],
                          :is_provisioned => result['is_provisioned']
                      }
                    end
              end

              udids_results
            end
          end
        end
      end
    end
  end
end
