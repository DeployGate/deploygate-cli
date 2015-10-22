module DeployGate
  module Builds
    module Ios
      class Export
        AD_HOC = 'ad-hoc'
        ENTERPRISE = 'enterprise'
        SUPPORT_EXPORT_METHOD = [AD_HOC, ENTERPRISE]
        PROFILE_EXTNAME = '.mobileprovision'

        class << self
          def method
            result = AD_HOC
            profiles.each do |profile_path|
              result = ENTERPRISE if inhouse?(profile_path)
            end

            result
          end

          # @param [String] profile_path
          # @return [Boolean]
          def adhoc?(profile_path)
            plist = analyze_profile(profile_path)
            plist['ProvisionsAllDevices'].nil?
          end

          # @param [String] profile_path
          # @return [Boolean]
          def inhouse?(profile_path)
            !adhoc?(profile_path)
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
            rule = File::Find.new(:pattern => "*#{PROFILE_EXTNAME}", :path => [profile_dir_path])
            rule.find {|f| profiles.push(f)}

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
