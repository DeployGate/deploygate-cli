module DeployGate
  module Xcode
    module MemberCenters
      class ProvisioningProfile
        attr_reader :member_center, :app_identifier

        OUTPUT_PATH = '/tmp/dg/provisioning_profile/'
        CERTIFICATE_OUTPUT_PATH = '/tmp/dg/certificate/'

        def initialize(app_identifier)
          @member_center = DeployGate::Xcode::MemberCenter.instance
          @app_identifier = app_identifier

          FileUtils.mkdir_p(OUTPUT_PATH)
        end

        # @param [String] uuid
        # @return [Array]
        def create!(uuid = nil)
          profiles = if uuid.nil?
                       all_create()
                     else
                       [download(uuid)]
                     end

          profiles
        end

        private

        # @return [Array]
        def all_create
          if @member_center.adhoc?
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

          provisionings = []
          distribution_cert_ids.each do |cert_id|
            values = sigh_config_values(cert_id: cert_id)
            download_profile_path = download_profile(values)
            provisionings.push(download_profile_path)
          end

          provisionings
        end

        # @param [String] uuid
        # @return [String]
        def download(uuid)
          profiles = Spaceship.provisioning_profile.all.reject!{|p| p.uuid != uuid}

          raise 'Not Xcode selected Provisioning Profile' if profiles.empty?
          select_profile = profiles.first
          method = select_profile.kind_of?(Spaceship::Portal::ProvisioningProfile::AdHoc)

          values = sigh_config_values(adhoc: method, provisioning_name: select_profile.name)
          download_profile(values)
        end

        # @param [Hash] values
        # @return [String]
        def download_profile(values)
          config = FastlaneCore::Configuration.create(Sigh::Options.available_options, values)
          Sigh.config = config

          Sigh::Manager.start
        end

        # @return [Hash]
        def sigh_config_values(adhoc: @member_center.adhoc?, provisioning_name: nil, cert_id: nil)
          values = {
              adhoc: adhoc,
              app_identifier: @app_identifier,
              username: @member_center.email,
              output_path: OUTPUT_PATH,
              team_id: Spaceship.client.team_id
          }
          values.merge!({provisioning_name: provisioning_name}) unless provisioning_name.nil?
          values.merge!({cert_id: cert_id}) unless cert_id.nil?

          values
        end
      end
    end
  end
end
