require 'singleton'

module DeployGate
  class AppleDeveloper
    include Singleton

    attr_reader :email

    OUTPUT_PATH = '/tmp/dg/provisioning_profile/'
    CERTIFICATE_OUTPUT_PATH = '/tmp/dg/certificate/'

    def initialize
      @email = input_email
      Spaceship.login(@email)
      Spaceship.select_team
    end

    # @param [DeployGate::Devices::Ios] device
    def device_register!(device)
      Spaceship::Device.create!(name: device.register_name, udid: device.udid)
    end

    # @param [DeployGate::Devices::Ios] device
    # @return [Boolean]
    def device_registered?(device)
      !Spaceship::Device.find_by_udid(device.udid).nil?
    end

    # @param [String] uuid
    # @return [Boolean]
    def created_app_id?(uuid)
      Spaceship.app.all.collect do |app|
        return true if app.bundle_id == uuid
      end

      false
    end

    # @param [String] uuid
    def app_id_create!(uuid)
      Spaceship.app.create!(:bundle_id => uuid, :name => "#{uuid.split('.').join(' ')}")
    end

    # @param [String] uuid
    # @param [String] method
    def create_provisioning_profile!(uuid, method = DeployGate::Builds::Ios::Export::AD_HOC)
      app_id_create!(uuid) unless created_app_id?(uuid)

      if method == DeployGate::Builds::Ios::Export::AD_HOC
        prod_certs = Spaceship.certificate.production.all
      else
        prod_certs = Spaceship.certificate.all.reject{|cert| cert.class != Spaceship::Portal::Certificate::InHouse}
      end

      # check local install certificate
      FileUtils.mkdir_p(CERTIFICATE_OUTPUT_PATH)
      distribution_cert_ids = []
      prod_certs.each do |cert|
        path = File.join(CERTIFICATE_OUTPUT_PATH, "#{cert.id}.cer")
        raw_data = cert.download_raw
        File.write(path, raw_data)
        distribution_cert_ids.push(cert.id) if FastlaneCore::CertChecker.installed?(path)
      end
      raise 'Not local install certificate' if distribution_cert_ids.empty?

      distribution_cert_ids.each do |cert_id|
        values = {
            :adhoc => method == DeployGate::Builds::Ios::Export::AD_HOC ? true : false,
            :app_identifier => uuid,
            :username => self.email,
            :output_path => OUTPUT_PATH,
            :cert_id => cert_id,
            :team_id => Spaceship.client.team_id,
            :force => true
        }
        v = FastlaneCore::Configuration.create(Sigh::Options.available_options, values)
        Sigh.config = v
        Sigh::Manager.start
      end
    end

    private

    def input_email
      puts <<EOF

No suitable provisioning profile found to export the app.

Please enter your email and password for Apple Developer Center
to set up/download provisioning profile automatically so you can
export the app without any extra steps.

Note: Your password will be stored to Keychain and never be sent to DeployGate.

EOF
      print 'Email: '
      STDIN.gets.chop
    end
  end
end
