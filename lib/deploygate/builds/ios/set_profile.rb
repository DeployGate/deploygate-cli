module DeployGate
  module Builds
    module Ios
      class SetProfile
        attr_reader :method

        OUTPUT_PATH = '/tmp/dg/provisioning_profile/'

        # @param [String] username
        # @param [String] identifier
        # @return [DeployGate::Builds::Ios::SetProfile]
        def initialize(username, identifier)
          @username = username
          @identifier = identifier
          Spaceship.login(username)
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
          prod_certs = Spaceship.certificate.production.all
          distribution_cert_ids = prod_certs.map(&:id)

          FileUtils.mkdir_p(OUTPUT_PATH)
          provisionings = []
          distribution_cert_ids.each do |cert_id|
            values = {
                :adhoc => @method == Export::AD_HOC ? true : false,
                :app_identifier => @identifier,
                :username => @username,
                :output_path => OUTPUT_PATH,
                :cert_id => cert_id
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
