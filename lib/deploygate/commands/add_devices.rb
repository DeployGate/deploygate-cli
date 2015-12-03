module DeployGate
  module Commands
    module AddDevices
      class << self

        # @param [Array] args
        # @param [Commander::Command::Options] options
        def run(args, options)
          session = DeployGate::Session.new
          unless session.login?
            Login.start_login_or_create_account()
            session = DeployGate::Session.new()
          end

          package_name = options.package_name
          owner        = options.user

          puts 'Not provisoned udids fetch...'
          puts ''
          res = DeployGate::API::V1::Users::App.not_provisioned_udids(session.token, owner || session.name, package_name)
          return if res[:error] # TODO: Error handling

          results = res[:results]
          devices = results.map{|r| DeployGate::Devices::Ios.new(r[:udid], r[:user_name], r[:device_name])}

          select_devices = select_devices(devices)
          if select_devices.empty?
            not_device
          else
            select_devices.each do |device|
              device.register!
              success_registered_device(device)
            end
            DeployGate::AppleDeveloper.instance.create_provisioning_profile!(package_name)
            # TODO: resign or build
          end
        end

        # @param [Array]
        # @return [Array]
        def select_devices(devices)
          return [] if devices.empty?

          select = []
          cli = HighLine.new
          cli.choose do |menu|
            menu.prompt = 'Please select add device: '
            menu.choice('All select') { select = devices }
            devices.each do |device|
              menu.choice(device.to_s) { select.push(device) }
            end
            menu.choice('Not select') { }
          end

          select
        end

        # @param [Device] device
        # @return [void]
        def success_registered_device(device)
          DeployGate::Message::Success.print("Registered #{device.to_s}")
        end

        # @return [void]
        def not_device
          DeployGate::Message::Warning.print('Not add devices')
        end
      end
    end
  end
end
