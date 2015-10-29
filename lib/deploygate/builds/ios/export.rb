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
          # @param [String] uuid
          # @return [Hash]
          def find_local_data(bundle_identifier, uuid = nil)
            result_profiles = {}
            teams = {}
            profile_paths = load_profile_paths
            profiles = profile_paths.map{|p| profile_to_plist(p)}
            profiles.reject! {|profile| profile['UUID'] != uuid} unless uuid.nil?

            profiles.each do |profile|
              entities = profile['Entitlements']
              unless entities['get-task-allow']
                team = entities['com.apple.developer.team-identifier']
                application_id = entities['application-identifier']
                application_id.slice!(/^#{team}\./)
                application_id = '.' + application_id if application_id == '*'
                if bundle_identifier.match(application_id) &&
                    DateTime.now < profile['ExpirationDate'] &&
                    installed_certificate?(profile['Path'])

                  teams[team] = profile['TeamName'] if teams[team].nil?
                  result_profiles[team] = [] if result_profiles[team].nil?
                  result_profiles[team].push(profile['Path'])
                end
              end
            end

            {
                :teams => teams,
                :profiles => result_profiles
            }
          end

          # @param [String] profile_path
          # @return [Boolean]
          def installed_certificate?(profile_path)
            profile = profile_to_plist(profile_path)
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

          # @param [Array] profile_paths
          # @return [String]
          def select_profile(profile_paths)
            select = nil

            profile_paths.each do |path|
              select = path if adhoc?(path) && select.nil?
              select = path if inhouse?(path)
            end
            select
          end

          # @param [String] profile_path
          # @return [String]
          def codesigning_identity(profile_path)
            method = method(profile_path)
            profile = profile_to_plist(profile_path)
            identity = "iPhone Distribution: #{profile['TeamName']}"
            identity += " (#{profile['Entitlements']['com.apple.developer.team-identifier']})" if method == AD_HOC

            identity
          end

          # @param [String] profile_path
          # @return [String]
          def method(profile_path)
            adhoc?(profile_path) ? AD_HOC : ENTERPRISE
          end

          # @param [String] profile_path
          # @return [Boolean]
          def adhoc?(profile_path)
            profile = profile_to_plist(profile_path)
            !profile['Entitlements']['get-task-allow'] && profile['ProvisionsAllDevices'].nil?
          end

          # @param [String] profile_path
          # @return [Boolean]
          def inhouse?(profile_path)
            profile = profile_to_plist(profile_path)
            !profile['Entitlements']['get-task-allow'] && !profile['ProvisionsAllDevices'].nil?
          end

          def load_profile_paths
            profiles_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/*.mobileprovision"
            Dir[profiles_path]
          end

          # @param [String] profile_path
          # @return [Hash]
          def profile_to_plist(profile_path)
            File.open(profile_path) do |profile|
              asn1 = OpenSSL::ASN1.decode(profile.read)
              plist_str = asn1.value[1].value[0].value[2].value[1].value[0].value
              plist = Plist.parse_xml plist_str.force_encoding('UTF-8')
              plist['Path'] = profile_path
              return plist
            end
          end
        end
      end
    end
  end
end
