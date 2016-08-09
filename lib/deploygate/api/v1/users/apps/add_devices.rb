module DeployGate::API::V1::Users::Apps
  class AddDevices
    ENDPOINT = "/users/%s/platforms/%s/apps/%s/add_devices"

    class << self
      def create(token, name, package_name, distribution_key, platform = 'ios')
        params = {distribution_access_key: distribution_key} unless distribution_key.nil?
        res = DeployGate::API::V1::Base.new(token).post(sprintf(ENDPOINT, name, platform, package_name), params || {})

        results = res['results']
        {
            error: res['error'],
            push_token: results['push_token'],
            webpush_server: results['webpush_server']
        }
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
