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
          if Spaceship.client.in_house?
            @method = Export::ENTERPRISE
          else
            @method = Export::AD_HOC
          end
        end

        # @return [Boolean]
        def app_id_create
          app = DeployGate::Xcode::MemberCenters::App.new(@identifier)
          return false if app.created?

          app.create!
          true
        end

        # @param [String] uuid
        # @return [Array]
        def create_provisioning(uuid)
          FileUtils.mkdir_p(OUTPUT_PATH)

          if uuid.nil?
            return install_provisioning
          else
            return select_uuid_provisioning(uuid)
          end
        end

        private

        def select_uuid_provisioning(uuid)
          adhoc_profiles = Spaceship.provisioning_profile.ad_hoc.all
          inhouse_profiles = Spaceship.provisioning_profile.in_house.all

          adhoc_profiles.reject!{|p| p.uuid != uuid}
          inhouse_profiles.reject!{|p| p.uuid != uuid}
          select_profile = nil
          method = nil
          unless adhoc_profiles.empty?
            select_profile = adhoc_profiles.first
            method = Export::AD_HOC
          end
          unless inhouse_profiles.empty?
            select_profile = inhouse_profiles.first
            method = Export::ENTERPRISE
          end
          raise 'Not Xcode selected Provisioning Profile' if select_profile.nil?

          values = {
              :adhoc => method == Export::AD_HOC ? true : false,
              :app_identifier => @identifier,
              :username => @username,
              :output_path => OUTPUT_PATH,
              :provisioning_name => select_profile.name,
              :team_id => Spaceship.client.team_id
          }
          v = FastlaneCore::Configuration.create(Sigh::Options.available_options, values)
          Sigh.config = v
          download_profile_path = Sigh::Manager.start

          [download_profile_path]
        end

        def install_provisioning
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
            download_profile_path = Sigh::Manager.start
            provisionings.push(download_profile_path)
          end

          provisionings
        end
      end
    end
  end
end
