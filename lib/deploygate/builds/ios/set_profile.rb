module DeployGate
  module Builds
    module Ios
      class SetProfile
        attr_reader :method

        OUTPUT_PATH = '/tmp/dg/provisioning_profile/'
        CERTIFICATE_OUTPUT_PATH = '/tmp/dg/certificate/'

        # @param [String] username
        # @param [String] identifier
        # @return [DeployGate::Builds::Ios::SetProfile]
        def initialize(username, identifier)
          @username = username
          @identifier = identifier
          Spaceship.login(username)
          Spaceship.select_team
          if Spaceship.client.in_house?
            @method = Export::ENTERPRISE
          else
            @method = Export::AD_HOC
          end
        end

        # @return [Boolean]
        def app_id_create
          app_created = false
          Spaceship.app.all.collect do |app|
            if app.bundle_id == @identifier
              app_created = true
              break
            end
          end
          unless app_created
            Spaceship.app.create!(:bundle_id => @identifier, :name => "#{@identifier.split('.').join(' ')}")
            return true
          end

          false
        end

        # @return [Array]
        def create_provisioning
          if @method == Export::AD_HOC
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

          FileUtils.mkdir_p(OUTPUT_PATH)
          provisionings = []
          distribution_cert_ids.each do |cert_id|
            values = {
                :adhoc => @method == Export::AD_HOC ? true : false,
                :app_identifier => @identifier,
                :username => @username,
                :output_path => OUTPUT_PATH,
                :cert_id => cert_id,
                :team_id => Spaceship.client.team_id
            }
            v = FastlaneCore::Configuration.create(Sigh::Options.available_options, values)
            Sigh.config = v
            provisionings.push(Sigh::Manager.start)
          end

          provisionings
        end
      end
    end
  end
end
