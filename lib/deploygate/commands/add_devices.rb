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
            Login.start_login()
            session = DeployGate::Session.new()
          end

          owner            = options.user || session.name
          udid             = options.udid
          device_name      = options.device_name
          distribution_key = options.distribution_key
          server           = options.server

          build_configuration = options.configuration
          xcodeproj_path = options.xcodeproj

          root_path = DeployGate::Xcode::Ios.project_root_path(work_dir)
          workspaces = DeployGate::Xcode::Ios.find_workspaces(root_path)
          analyze = DeployGate::Xcode::Analyze.new(workspaces, build_configuration, nil, xcodeproj_path)
          bundle_id = analyze.target_bundle_identifier
          developer_team = analyze.developer_team
          member_center = DeployGate::Xcode::MemberCenter.new(developer_team)

          if server
            run_server(session, owner, bundle_id, distribution_key, member_center, args, options)
          else
            device_register(session, owner, udid, device_name, bundle_id, member_center, args, options)
          end
        end

        def run_server(session, owner, bundle_id, distribution_key, member_center, args, options)
          DeployGate::AddDevicesServer.new().start(session.token, owner, bundle_id, distribution_key, member_center, args, options)
        end

        def device_register(session, owner, udid, device_name, bundle_id, member_center, args, options)
          if udid.nil? && device_name.nil?
            devices = fetch_devices(session.token, owner, bundle_id, member_center)
            select_devices = select_devices(devices)
            not_device if select_devices.empty?

            register!(select_devices)
          else
            register_udid = udid || HighLine.ask(I18n.t('commands.add_devices.input_udid'))
            register_device_name = device_name || HighLine.ask(I18n.t('commands.add_devices.input_device_name'))
            device = DeployGate::Xcode::MemberCenters::Device.new(register_udid, '', register_device_name, member_center)

            puts device.to_s
            if HighLine.agree(I18n.t('commands.add_devices.device_register_confirm')) {|q| q.default = "y"}
              register!([device])
            else
              not_device
            end
          end

          build!(bundle_id, member_center, args, options)
        end

        def register!(devices)
          devices.each do |device|
            device.register!
            success_registered_device(device)
          end
        end

        def build!(bundle_id, member_center, args, options)
          app = DeployGate::Xcode::MemberCenters::App.new(bundle_id, member_center)
          app.create! unless app.created?

          DeployGate::Xcode::MemberCenters::ProvisioningProfile.new(bundle_id, member_center).create!
          team = member_center.team
          DeployGate::Xcode::Export.clean_provisioning_profiles(bundle_id, team)

          DeployGate::Commands::Deploy::Build.run(args, options)
        end

        def fetch_devices(token, owner, bundle_id, member_center)
          res = DeployGate::API::V1::Users::App.not_provisioned_udids(token, owner, bundle_id)
          if res[:error]
            case res[:message]
              when 'unknown app'
                not_application(owner, bundle_id)
              when 'unknown user'
                unknown_user
              else
                raise res[:message]
            end
          end

          results = res[:results]
          devices = results.map{|r| DeployGate::Xcode::MemberCenters::Device.new(r[:udid], r[:user_name], r[:device_name], member_center)}

          devices
        end

        # @param [Array]
        # @return [Array]
        def select_devices(devices)
          return [] if devices.empty?

          select = []
          cli = HighLine.new
          devices.each do |device|
            puts ''
            puts I18n.t('commands.add_devices.select_devices.device_info', device: device.to_s)
            select.push(device) if cli.agree(I18n.t('commands.add_devices.select_devices.agree')) {|q| q.default = "y"}
          end

          select
        end

        # @param [Device] device
        # @return [void]
        def success_registered_device(device)
          puts HighLine.color(I18n.t('commands.add_devices.success_registered_device', device: device.to_s), HighLine::GREEN)
        end

        # @return [void]
        def not_device
          puts HighLine.color(I18n.t('commands.add_devices.not_device'), HighLine::YELLOW)
          exit
        end

        # @return [void]
        def ios_only_command
          puts HighLine.color(I18n.t('commands.add_devices.ios_only_command'), HighLine::YELLOW)
          exit
        end

        # @param [String] owner
        # @param [String] bundle_id
        # @return [void]
        def not_application(owner, bundle_id)
          puts ''
          puts I18n.t('commands.add_devices.unknown_application.data', owner: owner, bundle_id: bundle_id)
          puts HighLine.color(I18n.t('commands.add_devices.unknown_application.message'), HighLine::YELLOW)
          exit
        end

        def unknown_user
          puts ''
          puts HighLine.color(I18n.t('commands.add_devices.unknown_user'), HighLine::RED)
          exit
        end
      end
    end
  end
end
