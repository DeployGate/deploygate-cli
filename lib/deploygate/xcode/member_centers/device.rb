module DeployGate
  module Xcode
    module MemberCenters
      class Device
        attr_reader :udid, :user_name ,:device_name, :member_center
        attr_accessor :register_name

        REGISTER_NAME_MAX_LENGTH = 50

        # @param [String] udid
        # @param [String] user_name
        # @param [String] device_name
        # @param [Xcode::MemberCenter] member_center
        # @return [DeployGate::Devices::Ios]
        def initialize(udid, user_name, device_name, member_center)
          @udid = udid
          @user_name = user_name
          @device_name = device_name
          @member_center = member_center

          @register_name = generate_register_name(@user_name, @device_name)
        end

        def registered?
          !@member_center.launcher.device.find_by_udid(@udid).nil?
        end

        # @return [void]
        def register!
          return if registered?

          @member_center.launcher.device.create!(name: @register_name, udid: @udid)
        end

        # @return [String]
        def to_s
          "Name: #{self.register_name}, UDID: #{self.udid}"
        end

        private

        def generate_register_name(user_name, device_name)
          name = ''
          name += "#{user_name} - " if !user_name.nil? && user_name != ''
          name += device_name

          register_name_trim(name)
        end

        # Device name must be 50 characters or less.
        def register_name_trim(name)
          return name if name.length <= REGISTER_NAME_MAX_LENGTH
          name.slice(0, REGISTER_NAME_MAX_LENGTH)
        end
      end
    end
  end
end
