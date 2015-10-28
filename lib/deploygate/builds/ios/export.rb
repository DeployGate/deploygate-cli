module DeployGate
  module Builds
    module Ios
      class Export
        AD_HOC = 'ad-hoc'
        ENTERPRISE = 'enterprise'
        SUPPORT_EXPORT_METHOD = [AD_HOC, ENTERPRISE]
        PROFILE_EXTNAME = '.mobileprovision'

        class << self
          # @param [String] bundle_identifier
          # @return [Hash]
          def find_local_data(bundle_identifier)
            result_profiles = {}
            teams = {}
            profiles = load_profiles

            profiles.each do |profile|
              entities = profile['Entitlements']
              unless entities['get-task-allow']
                team = entities['com.apple.developer.team-identifier']
                application_id = entities['application-identifier']
                application_id.slice!(/^#{team}\./)
                application_id = '.' + application_id if application_id == '*'
                if bundle_identifier.match(application_id) &&
                    DateTime.now < profile['ExpirationDate'] &&
                    installed_certificate?(profile)

                  teams[team] = profile['TeamName'] if teams[team].nil?
                  result_profiles[team] = [] if result_profiles[team].nil?
                  result_profiles[team].push(profile)
                end
              end
            end

            {
                :teams => teams,
                :profiles => result_profiles
            }
          end

          # @param [Hash] profile
          # @return [Boolean]
          def installed_certificate?(profile)
            certs = profile['DeveloperCertificates'].map do |cert|
              certificate_str = cert.read
              certificate =  OpenSSL::X509::Certificate.new certificate_str
              id = OpenSSL::Digest::SHA1.new(certificate.to_der).to_s.upcase!
              installed_identies.include?(id)
            end
            certs.include?(true)
          end

          # @return [Array]
          def installed_identies
            available = `security find-identity -v -p codesigning`
            ids = []
            available.split("\n").each do |current|
              next if current.include? "REVOKED"
              begin
                (ids << current.match(/.*\) (.*) \".*/)[1])
              rescue
                # the last line does not match
              end
            end

            ids
          end

          # @param [Array] profiles
          # @return [String]
          def select_profile(profiles)
            select = nil

            profiles.each do |profile|
              select = profile if adhoc?(profile) && select.nil?
              select = profile if inhouse?(profile)
            end
            select
          end

          # @param [Hash] profile
          # @return [String]
          def codesigning_identity(profile)
            method = method(profile)
            identity = "iPhone Distribution: #{profile['TeamName']}"
            identity += " (#{profile['Entitlements']['com.apple.developer.team-identifier']})" if method == AD_HOC

            identity
          end

          # @param [Hash] profile
          # @return [String]
          def method(profile)
            adhoc?(profile) ? AD_HOC : ENTERPRISE
          end

          # @param [Hash] profile
          # @return [Boolean]
          def adhoc?(profile)
            !profile['Entitlements']['get-task-allow'] && profile['ProvisionsAllDevices'].nil?
          end

          # @param [Hash] profile
          # @return [Boolean]
          def inhouse?(profile)
            !profile['Entitlements']['get-task-allow'] && !profile['ProvisionsAllDevices'].nil?
          end

          def load_profiles
            profiles_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/*.mobileprovision"
            profile_paths = Dir[profiles_path]

            profiles = []
            profile_paths.each do |profile_path|
              File.open(profile_path) do |profile|
                asn1 = OpenSSL::ASN1.decode(profile.read)
                plist_str = asn1.value[1].value[0].value[2].value[1].value[0].value
                plist = Plist.parse_xml plist_str.force_encoding('UTF-8')
                plist['Path'] = profile_path
                profiles << plist
              end
            end
            profiles = profiles.sort_by { |profile| profile["Name"].downcase }

            profiles
          end
        end
      end
    end
  end
end
