module DeployGate
  module Builds
    module Ios
      class Export
        AD_HOC = 'ad-hoc'
        ENTERPRISE = 'enterprise'
        SUPPORT_EXPORT_METHOD = [AD_HOC, ENTERPRISE]
        PROFILE_EXTNAME = '.mobileprovision'

        class << self
          # @return [String]
          def target_provisioning_profile(bundle_identifier)
            result = nil
            profiles.each do |profile_path|
              plist = analyze_profile(profile_path)
              entities = plist['Entitlements']
              unless entities['get-task-allow']
                team = entities['com.apple.developer.team-identifier']
                application_id = entities['application-identifier']
                application_id.slice!(/^#{team}\./)
                if bundle_identifier.match(application_id)
                  if adhoc?(profile_path) && result.nil?
                    result = profile_path
                  elsif inhouse?(profile_path)
                    result = profile_path
                  end
                end
              end
            end

            result
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
