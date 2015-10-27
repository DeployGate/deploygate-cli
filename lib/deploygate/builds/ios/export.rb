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
            profiles.each do |profile_path|
              plist = analyze_profile(profile_path)
              entities = plist['Entitlements']
              unless entities['get-task-allow']
                team = entities['com.apple.developer.team-identifier']
                application_id = entities['application-identifier']
                application_id.slice!(/^#{team}\./)
                application_id = '.' + application_id if application_id == '*'
                if bundle_identifier.match(application_id)
                  # TODO: check provisioning expired
                  teams[team] = plist['TeamName'] if teams[team].nil?
                  result_profiles[team] = [] if result_profiles[team].nil?
                  result_profiles[team].push(profile_path)
                end
              end
            end

            {
                :teams => teams,
                :profiles => result_profiles
            }
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

          # @param [String] profile_path
          # @return [String]
          def codesigning_identity(profile_path)
            plist = analyze_profile(profile_path)
            method = method(profile_path)
            identity = "iPhone Distribution: #{plist['TeamName']}"
            identity += " (#{plist['Entitlements']['com.apple.developer.team-identifier']})" if method == AD_HOC

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
            plist = analyze_profile(profile_path)
            !plist['Entitlements']['get-task-allow'] && plist['ProvisionsAllDevices'].nil?
          end

          # @param [String] profile_path
          # @return [Boolean]
          def inhouse?(profile_path)
            plist = analyze_profile(profile_path)
            !plist['Entitlements']['get-task-allow'] && !plist['ProvisionsAllDevices'].nil?
          end

          # @param [String] profile_path
          # @return [Hash]
          def analyze_profile(profile_path)
            plist = nil
            File.open(profile_path) do |profile|
              asn1 = OpenSSL::ASN1.decode(profile.read)
              plist_str = asn1.value[1].value[0].value[2].value[1].value[0].value
              plist = Plist.parse_xml plist_str.force_encoding('UTF-8')
            end
            plist
          end

          # @return [Array]
          def profiles
            profiles = []
            Find.find(profile_dir_path) do |path|
              next if path == profile_dir_path
              Find.prune if FileTest.directory?(path)
              if File.extname(path) == PROFILE_EXTNAME
                profiles.push(path)
              end
            end

            profiles
          end

          # @return [String]
          def profile_dir_path
            File.join(ENV['HOME'], 'Library/MobileDevice/Provisioning Profiles')
          end
        end
      end
    end
  end
end
