module DeployGate
  class AddDevicesServer

    ACTION = 'add_devices'

    def start(token, owner_name, bundle_id, args, options)
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
        p data

        build(data['udid'], data['device_name'], args, options) unless data['registered']
      end

      socket.on :info do |data|
        p 'info'
        p data
      end

      loop do
        p DeployGate::API::V1::Users::Apps::AddDevices.heartbeat(token, owner_name, bundle_id, push_token)
        sleep 10
      end
    end

    def build(udid, device_name, args, options)
      options.server = false
      options.udid = udid
      options.device_name= device_name
      DeployGate::Commands::AddDevices.run(args, options)
    end
  end
end
