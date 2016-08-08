module DeployGate::API::V1::Users::Apps
  class AddDevices
    ENDPOINT = "/users/%s/platforms/%s/apps/%s/add_devices"

    class << self
      def create(token, name, package_name, platform = 'ios')
        res = DeployGate::API::V1::Base.new(token).post(sprintf(ENDPOINT, name, platform, package_name), {})

        results = res['results']
        {
            error: res['error'],
            push_token: results['push_token'],
            webpush_server: results['webpush_server']
        }
      end

      def heartbeat(token, name, package_name, push_token, platform = 'ios')
        res = DeployGate::API::V1::Base.new(token).get("#{sprintf(ENDPOINT, name, platform, package_name)}/#{push_token}/heartbeat", {})

        {
            error: res['error']
        }
      end
    end
  end
end
