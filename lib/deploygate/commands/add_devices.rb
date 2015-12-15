module DeployGate
  module Commands
    module AddDevices
      class << self

        # @param [Array] args
        # @param [Commander::Command::Options] options
        def run(args, options)
          work_dir = args.empty? ? Dir.pwd : args.first
          ios_only_command unless DeployGate::Project.ios?(work_dir)

          session = DeployGate::Session.new
          unless session.login?
            Login.start_login_or_create_account()
            session = DeployGate::Session.new()
          end

          owner       = options.user || session.name
          udid        = options.udid
          device_name = options.device_name

          bundle_id = bundle_id(work_dir)

          if udid.nil? && device_name.nil?
            devices = fetch_devices(session.token, owner, bundle_id)
            select_devices = select_devices(devices)
            not_device if select_devices.empty?

            select_devices.each do |device|
              device.register!
              success_registered_device(device)
            end
          else
            register_udid = udid || HighLine.ask('Input UDID: ')
            register_device_name = device_name || HighLine.ask('Input Device Name: ')
            device = DeployGate::Xcode::MemberCenters::Device.new(register_udid, '', register_device_name)

            puts device.to_s
            if HighLine.agree('It will register with the contents of the above. Is it OK? (y/n) ') {|q| q.default = "y"}
              device.register!
              success_registered_device(device)
            else
              not_device
            end
          end

          DeployGate::Xcode::MemberCenters::ProvisioningProfile.new(bundle_id).create!
          team = DeployGate::Xcode::MemberCenter.instance.team
          DeployGate::Xcode::Export.clean_provisioning_profiles(bundle_id, team)
          DeployGate::Commands::Deploy::Build.run(args, options)
        end

        def fetch_devices(token, owner, bundle_id)
          puts 'Not provisoned udids fetch...'
          puts ''
          res = DeployGate::API::V1::Users::App.not_provisioned_udids(token, owner, bundle_id)
          return if res[:error] # TODO: Error handling

          results = res[:results]
          devices = results.map{|r| DeployGate::Xcode::MemberCenters::Device.new(r[:udid], r[:user_name], r[:device_name])}

          devices
        end

        # @param [String] work_dir
        # @return [String]
        def bundle_id(work_dir)
          root_path = DeployGate::Xcode::Ios.project_root_path(work_dir)
          workspaces = DeployGate::Xcode::Ios.find_workspaces(root_path)
          analyze = DeployGate::Xcode::Analyze.new(workspaces)
          analyze.target_bundle_identifier
        end

        # @param [Array]
        # @return [Array]
        def select_devices(devices)
          return [] if devices.empty?

          select = []
          cli = HighLine.new
          cli.choose do |menu|
            menu.prompt = 'Please select add device: '
            devices.each do |device|
              menu.choice(device.to_s) { select.push(device) }
            end
            menu.choice('All select') { select = devices }
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
          exit
        end

        # @return [void]
        def ios_only_command
          DeployGate::Message::Warning.print('This command is iOS project only command')
          exit
        end
      end
    end
  end
end
