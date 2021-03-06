module DeployGate
  module Xcode
    module MemberCenters
      class ProvisioningProfile
        attr_reader :member_center, :app_identifier

        class NotInstalledCertificateError < DeployGate::RavenIgnoreException
        end
        class NotExistUUIDProvisioningProfileError < DeployGate::RavenIgnoreException
        end

        OUTPUT_PATH = '/tmp/dg/provisioning_profile/'
        CERTIFICATE_OUTPUT_PATH = '/tmp/dg/certificate/'

        def initialize(app_identifier, member_center)
          @member_center = member_center
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
          prod_certs = if @member_center.adhoc?
                         @member_center.launcher.certificate.all.select{|cert|
                           cert.class == Spaceship::Portal::Certificate::Production ||
                               cert.class == Spaceship::Portal::Certificate::AppleDistribution
                         }
                       else
                         @member_center.launcher.certificate.all.select{|cert|
                           cert.class == Spaceship::Portal::Certificate::InHouse
                         }
                       end

          # check local install certificate
          FileUtils.mkdir_p(CERTIFICATE_OUTPUT_PATH)
          distribution_cert_ids = []
          prod_certs.each do |cert|
            next if cert.expires < Time.now
            path = File.join(CERTIFICATE_OUTPUT_PATH, "#{cert.id}.cer")
            raw_data = cert.download_raw
            File.write(path, raw_data)
            distribution_cert_ids.push(cert.id) if FastlaneCore::CertChecker.installed?(path)
          end
          raise NotInstalledCertificateError, I18n.t('xcode.member_center.provisioning_profile.not_installed_certificate_error') if distribution_cert_ids.empty?

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
          profiles = @member_center.launcher.provisioning_profile.all.reject!{|p| p.uuid != uuid}

          raise NotExistUUIDProvisioningProfileError, I18n.t('xcode.member_center.provisioning_profile.not_exist_uuid_provisioning_profile_error', uuid: uuid) if profiles.empty?
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
              team_id: @member_center.launcher.client.team_id,
              force: true
          }
          values.merge!({provisioning_name: provisioning_name}) unless provisioning_name.nil?
          values.merge!({cert_id: cert_id}) unless cert_id.nil?

          values
        end
      end
    end
  end
end
