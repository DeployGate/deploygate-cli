module DeployGate
  module Xcode
    class Export
      AD_HOC = 'ad-hoc'
      ENTERPRISE = 'enterprise'
      SUPPORT_EXPORT_METHOD = [AD_HOC, ENTERPRISE]
      PROFILE_EXTNAME = '.mobileprovision'

      class << self

        # @param [String] bundle_identifier
        # @param [String] uuid
        # @return [String]
        def provisioning_profile(bundle_identifier, uuid = nil)
          data = DeployGate::Xcode::Export.find_local_data(bundle_identifier, uuid)
          profiles = data[:profiles]
          teams = data[:teams]

          target_provisioning_profile = nil
          if teams.empty?
            target_provisioning_profile = create_provisioning(bundle_identifier, uuid)
          elsif teams.count == 1
            target_provisioning_profile = select_profile(profiles[teams.keys.first])
          elsif teams.count >= 2
            target_provisioning_profile = select_teams(teams, profiles)
          end

          target_provisioning_profile
        end

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
            installed_distribution_certificate_ids.include?(id)
          end
          certs.include?(true)
        end

        # @return [Array]
        def installed_distribution_certificate_ids
          certificates = installed_certificates()
          ids = []
          certificates.each do |current|
            next unless current.match(/iPhone Distribution:/)
            begin
              (ids << current.match(/.*\) (.*) \".*/)[1])
            rescue
              # the last line does not match
            end
          end

          ids
        end

        # @return [Array]
        def installed_distribution_conflicting_certificates
          certificates = installed_certificates()
          names = []
          certificates.each do |current|
            begin
              names << current.match(/(iPhone Distribution:.*)/)[1]
            rescue
            end
          end

          conflicting_names = names.select{|e| names.index(e) != names.rindex(e)}.uniq
          conflicting_certificates = []
          certificates.each do |current|
            begin
              name = current.match(/(iPhone Distribution:.*)/)[1]
              next unless conflicting_names.include?(name)
              conflicting_certificates << current
            rescue
            end
          end

          conflicting_certificates
        end

        # @return [Array]
        def installed_certificates
          available = `security find-identity -v -p codesigning`
          certificates = []
          available.split("\n").each do |current|
            next if current.include? "REVOKED"
            certificates << current
          end

          certificates
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
          profile = profile_to_plist(profile_path)
          identity = nil

          profile['DeveloperCertificates'].each do |cert|
            certificate_str = cert.read
            certificate =  OpenSSL::X509::Certificate.new certificate_str
            id = OpenSSL::Digest::SHA1.new(certificate.to_der).to_s.upcase!

            available = `security find-identity -v -p codesigning`
            available.split("\n").each do |current|
              next if current.include? "REVOKED"
              begin
                search = current.match(/.*\) (.*) \"(.*)\"/)
                identity = search[2] if id == search[1]
              rescue
              end
            end
          end

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

        def create_provisioning(identifier, uuid)
          app = MemberCenters::App.new(identifier)
          provisioning_prifile = MemberCenters::ProvisioningProfile.new(identifier)

          begin
            unless app.created?
              app.create!
              puts "App ID #{identifier} was created"
            end
          rescue => e
            DeployGate::Message::Error.print("Error: Failed to create App ID")
            raise e
          end

          begin
            provisioning_profiles = provisioning_prifile.create!(uuid)
          rescue => e
            DeployGate::Message::Error.print("Error: Failed to create provisioning profile")
            raise e
          end

          select_profile(provisioning_profiles)
        end

        # @param [Hash] teams
        # @param [Hash] profiles
        # @return [String]
        def select_teams(teams, profiles)
          result = nil
          cli = HighLine.new
          cli.choose do |menu|
            menu.prompt = 'Please select team'
            teams.each_with_index do |team, index|
              menu.choice("#{team[1]} #{team[0]}") {
                result = DeployGate::Xcode::Export.select_profile(profiles[team])
              }
            end
          end

          result
        end

        def check_local_certificates
          if installed_distribution_certificate_ids.count == 0
            # not local install certificate
            DeployGate::Message::Error.print("Error: Not local install distribution certificate")
            puts <<EOF

Not local install iPhone Distribution certificates.
Please install certificate.

Docs: https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingCertificates/MaintainingCertificates.html

EOF
            exit
          end

          conflicting_certificates = installed_distribution_conflicting_certificates
          if conflicting_certificates.count > 0
            DeployGate::Message::Error.print("Error: Conflicting local install certificates")
            puts <<EOF

Conflicting local install certificates.
Please uninstall certificates.
EOF
            conflicting_certificates.each do |certificate|
              puts certificate
            end
            puts ""

            exit
          end
        end

        # @param [String] bundle_identifier
        # @return [void]
        def clean_provisioning_profiles(bundle_identifier, team)
          puts "Clean local Provisioning Profiles..."
          puts ''

          profile_paths = []
          profile_paths = load_profile_paths
          profiles = profile_paths.map{|p| profile_to_plist(p)}

          profiles.each do |profile|
            entities = profile['Entitlements']
            unless entities['get-task-allow']
              team = entities['com.apple.developer.team-identifier']
              application_id = entities['application-identifier']
              if "#{team}.#{bundle_identifier}" == application_id &&
                  DateTime.now < profile['ExpirationDate'] &&
                  installed_certificate?(profile['Path'])

                profile_paths.push(profile['Path'])
              end
            end
          end

          most_new_profile_path = profile_paths.first
          profile_paths.each do |path|
            most_new_profile_path = path if File.ctime(path) > File.ctime(most_new_profile_path)
          end

          profile_paths.delete(most_new_profile_path)
          profile_paths.each do |path|
            next unless File.exist?(path)
            File.delete(path)
            puts "Delete #{path}"
          end

          puts ''
          puts "Finish clean local Provisionig Profiles"
        end
      end
    end
  end
end
