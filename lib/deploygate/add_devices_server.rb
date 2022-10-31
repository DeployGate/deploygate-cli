module DeployGate
  class AddDevicesServer

    def start(token, owner_name, bundle_id, distribution_key, member_center, args, options)
      options.server = false

      puts I18n.t('command_builder.add_devices.server.connecting')
      res = DeployGate::API::V1::Users::Apps::CliWebsockets.create(token, owner_name, bundle_id, distribution_key)

      server = res[:webpush_server]
      push_token  = res[:push_token]
      action  = res[:action]
      if res[:error] || server.blank? || push_token.blank? || action.blank?
        raise res[:message]
      end

      websocket_setup(server, bundle_id, push_token, action, member_center, args, options) do |socket|
        puts HighLine.color(I18n.t('command_builder.add_devices.server.start'), HighLine::GREEN)

        Workers::PeriodicTimer.new(60) do
          DeployGate::API::V1::Users::Apps::CliWebsockets.heartbeat(token, owner_name, bundle_id, distribution_key, push_token)
        end

        Signal.trap(:INT){
          socket.disconnect
          exit 0
        }
      end

      loop do
        sleep 60
      end
    end

    def self.build(pool, bunlde_id, iphones, member_center, args, options)
      iphones.reject! { |iphone| iphone['is_registered'] } # remove udids if already registered
      devices = iphones.map do |iphone|
        udid = iphone['udid']
        device_name= iphone['device_name']
        DeployGate::Xcode::MemberCenters::Device.new(udid, '', device_name, member_center)
      end
      return if devices.empty?

      puts HighLine.color(I18n.t('command_builder.add_devices.server.start_build'), HighLine::GREEN)
      pool.perform do
        DeployGate::Commands::AddDevices.register!(devices)
        DeployGate::Commands::AddDevices.build!(bunlde_id, member_center, args, options)
        puts HighLine.color(I18n.t('command_builder.add_devices.server.finish_build'), HighLine::GREEN)
        puts ''
      end
    end

    private

    def websocket_setup(server, bundle_id, push_token, target_action, member_center, args, options, &block)
      socket = SocketIO::Client::Simple.connect server
      socket.on :connect do
        socket.emit :subscribe, push_token
        block.call(socket)
      end

      socket.on :error do
        raise 'Socket Error'
      end

      pool = Workers::Pool.new(size: 1, on_exception: proc { |e|
        raise e
      })
      socket.on push_token do |push_data|
        return if push_data['action'] != target_action
        data = JSON.parse(push_data['data'])

        iphones = data['iphones']
        DeployGate::AddDevicesServer.build(pool, bundle_id, iphones, member_center, args, options)
      end
    end
  end
end
