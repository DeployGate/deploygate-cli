module DeployGate
  module Xcode
    module MemberCenters
      class Device
        attr_reader :udid, :user_name ,:device_name, :member_center
        attr_accessor :register_name

        # @param [String] udid
        # @param [String] user_name
        # @param [String] device_name
        # @return [DeployGate::Devices::Ios]
        def initialize(udid, user_name, device_name)
          @member_center = DeployGate::Xcode::MemberCenter.instance
          @udid = udid
          @user_name = user_name
          @device_name = device_name
          @register_name = "#{@user_name} - #{@device_name}"
        end

        def registered?
          !Spaceship::Device.find_by_udid(@udid).nil?
        end

        # @return [void]
        def register!
          return if registered?

          Spaceship::Device.create!(name: @register_name, udid: @udid)
        end

        # @return [String]
        def to_s
          "Name: #{self.register_name}, UDID: #{self.udid}"
        end
      end
    end
  end
end
