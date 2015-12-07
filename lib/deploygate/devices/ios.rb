module DeployGate
  module Devices
    class Ios
      attr_reader :udid, :user_name ,:device_name
      attr_accessor :register_name

      # @param [String] udid
      # @param [String] user_name
      # @param [String] device_name
      # @return [DeployGate::Devices::Ios]
      def initialize(udid, user_name, device_name)
        @udid = udid
        @user_name = user_name
        @device_name = device_name
        @register_name = "#{@user_name} - #{@device_name}"
      end

      # @return [void]
      def register!
        client = DeployGate::AppleDeveloper.instance
        return if client.device_registered?(self)

        client.device_register!(self)
      end

      # @return [String]
      def to_s
        "Name: #{self.register_name}, UDID: #{self.udid}"
      end
    end
  end
end
