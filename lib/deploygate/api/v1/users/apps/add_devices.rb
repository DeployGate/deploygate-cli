module DeployGate::API::V1::Users::Apps
  class AddDevices
    ENDPOINT = "/users/%s/platforms/%s/apps/%s/add_devices"

    class << self
      def create(token, name, package_name, distribution_key, platform = 'ios')
        params = {distribution_access_key: distribution_key} unless distribution_key.nil?
        res = DeployGate::API::V1::Base.new(token).post(sprintf(ENDPOINT, name, platform, package_name), params || {})

        results = {
            error: res['error']
        }
        if results[:error]
          results.merge!(
              {
                  message: res['message']
              }
          )
        else
          results.merge!(
              {
                  push_token: res['results']['push_token'],
                  webpush_server: res['results']['webpush_server']
              }
          )
        end

        results
      end

      def heartbeat(token, name, package_name, distribution_key, push_token, platform = 'ios')
        params = {distribution_access_key: distribution_key} unless distribution_key.nil?
        res = DeployGate::API::V1::Base.new(token).get("#{sprintf(ENDPOINT, name, platform, package_name)}/#{push_token}/heartbeat", params || {})

        {
            error: res['error']
        }
      end
    end
  end
end
