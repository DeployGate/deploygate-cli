module DeployGate
  class AddDevicesServer

    ACTION = 'add_devices'

    def start(token, owner_name, bundle_id, distribution_key, args, options)
      DeployGate::Xcode::MemberCenter.instance

      puts I18n.t('command_builder.add_devices.server.wait')
      res = DeployGate::API::V1::Users::Apps::AddDevices.create(token, owner_name, bundle_id, distribution_key)

      server = res[:webpush_server]
      push_token  = res[:push_token]
      if res[:error] || server.blank? || push_token.blank?
        raise res[:message]
      end

      websocket_setup(server, bundle_id, push_token, args, options) do |socket|
        puts HighLine.color(I18n.t('command_builder.add_devices.server.start'), HighLine::GREEN)

        Workers::PeriodicTimer.new(60) do
          DeployGate::API::V1::Users::Apps::AddDevices.heartbeat(token, owner_name, bundle_id, distribution_key, push_token)
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

    def self.build(pool, bunlde_id, iphones, args, options)
      options.server = false
      devices = iphones.map do |iphone|
        # TODO: reject iphone['is_registered'] = true
        udid = iphone['udid']
        device_name= iphone['device_name']
        DeployGate::Xcode::MemberCenters::Device.new(udid, '', device_name)
      end

      pool.perform do
        DeployGate::Commands::AddDevices.register!(devices)
        DeployGate::Commands::AddDevices.build!(bunlde_id, args, options)
      end
    end

    private

    def websocket_setup(server, bundle_id, push_token, args, options, &block)
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
        return if push_data['action'] != ACTION
        data = JSON.parse(push_data['data'])

        iphones = data['iphones']
        DeployGate::AddDevicesServer.build(pool, bundle_id, iphones, args, options)
      end
    end
  end
end
