module DeployGate
  class AddDevicesServer

    ACTION = 'add_devices'

    def start(token, owner_name, bundle_id, args, options)
      DeployGate::Xcode::MemberCenter.instance
      res = DeployGate::API::V1::Users::Apps::AddDevices.create(token, owner_name, bundle_id)

      server = res[:webpush_server]
      push_token  = res[:push_token]

      if server.blank? || push_token.blank?
        p 'ERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR' # TODO: fix
        exit
      end

      socket = SocketIO::Client::Simple.connect server
      socket.on :connect do
        p 'connect'
        socket.emit :subscribe, push_token
      end
      socket.on :disconnect do
        p 'disconnect'
      end
      socket.on :error do |err|
        p 'error'
        p err
      end

      socket.on push_token do |push_data|
        return if push_data['action'] != ACTION
        data = JSON.parse(push_data['data'])

        iphones = data['iphones']
        DeployGate::AddDevicesServer.build(bundle_id, iphones, args, options)
      end

      loop do
        DeployGate::API::V1::Users::Apps::AddDevices.heartbeat(token, owner_name, bundle_id, push_token)
        sleep 10
      end
    end

    def self.build(bunlde_id, iphones, args, options)
      options.server = false
      devices = iphones.map do |iphone|
        # TODO: reject iphone['is_registered'] = true
        udid = iphone['udid']
        device_name= iphone['device_name']
        DeployGate::Xcode::MemberCenters::Device.new(udid, '', device_name)
      end

      # TODO: Check running build
      Parallel.each([1], in_threads: 1) do |v|
        DeployGate::Commands::AddDevices.register!(devices)
        DeployGate::Commands::AddDevices.build!(bunlde_id, args, options)
      end
    end
  end
end
