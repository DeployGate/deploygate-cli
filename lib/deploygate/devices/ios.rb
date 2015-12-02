module DeployGate
  module Devices
    class Ios
      attr_reader :udid, :device_name

      def initialize(udid, device_name)
        @udid = udid
        @device_name = device_name
      end

      def register!(name = self.device_name)
        client = DeployGate::AppleDeveloper.instance
        return if client.device_registered?(self)

        client.device_register!(self, name)
      end
    end
  end
end
