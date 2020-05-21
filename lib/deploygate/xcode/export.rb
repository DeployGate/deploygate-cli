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
        # @param [String] provisioning_team
        # @return [String]
        def provisioning_profile(bundle_identifier, uuid = nil, provisioning_team = nil, specifier_name = nil)
          local_teams = DeployGate::Xcode::Export.find_local_data(bundle_identifier, uuid, provisioning_team, specifier_name)

          case local_teams.teams_count
            when 0
              target_provisioning_profile = create_provisioning(bundle_identifier, uuid, provisioning_team)
            when 1
              target_provisioning_profile = select_profile(local_teams.first_team_profile_paths)
            else
              # when many teams
              target_provisioning_profile = select_teams(local_teams)
          end

          target_provisioning_profile
        end

        # @param [String] bundle_identifier
        # @param [String] uuid
        # @param [String] provisioning_team
        # @return [LocalTeams]
        def find_local_data(bundle_identifier, uuid = nil, provisioning_team = nil, specifier_name = nil)
          local_teams = LocalTeams.new

          profile_paths = load_profile_paths
          profiles = profile_paths.map{|p| profile_to_plist(p)}
          profiles.reject! {|profile| profile['UUID'] != uuid} unless uuid.nil?
          profiles.reject! {|profile| profile['Name'] != specifier_name} unless specifier_name.nil?

          profiles.each do |profile|
            next if DateTime.now >= profile['ExpirationDate'] || !installed_certificate?(profile['Path'])

            entities = profile['Entitlements']
            unless entities['get-task-allow']
              team_id = entities['com.apple.developer.team-identifier']
              next if provisioning_team != nil && team_id != provisioning_team

              application_id = entities['application-identifier']
              application_id.slice!(/^#{team_id}\./)
              application_id = '.' + application_id if application_id == '*'
              if match = bundle_identifier.match(application_id)
                next if match[0] != bundle_identifier

                local_teams.add(team_id, profile['TeamName'], profile['Path'])
              end
            end
          end

          local_teams
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
            next unless current.match(/iPhone Distribution:/) || current.match(/Apple Distribution:/)
            begin
              (ids << current.match(/.*\) (.*) \".*/)[1])
            rescue
              # the last line does not match
            end
          end

          ids
        end

        # @return [Array]
        def installed_distribution_conflicting_certificates_by(distribution_name)
          certificates = installed_certificates()
          names = []
          certificates.each do |current|
            begin
              names << current.match(/(#{distribution_name}:.*)/)[1]
            rescue
            end
          end

          conflicting_names = names.select{|e| names.index(e) != names.rindex(e)}.uniq
          conflicting_certificates = []
          certificates.each do |current|
            begin
              name = current.match(/(#{distribution_name}:.*)/)[1]
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
            asn1 = OpenSSL::ASN1.decode_all(profile.read).first
            plist_str = asn1.value[1].value[0].value[2].value[1].value[0].value
            plist = Plist.parse_xml plist_str.force_encoding('UTF-8')
            plist['Path'] = profile_path
            return plist
          end
        end

        def create_provisioning(identifier, uuid, team_id)
          member_center = Xcode::MemberCenter.new(team_id)
          app = MemberCenters::App.new(identifier, member_center)
          provisioning_prifile = MemberCenters::ProvisioningProfile.new(identifier, member_center)

          begin
            unless app.created?
              app.create!
              puts I18n.t('xcode.export.create_provisioning.created', identifier: identifier)
            end
          rescue => e
            puts HighLine.color(I18n.t('xcode.export.create_provisioning.error.failed_to_create.app_id'), HighLine::RED)
            raise e
          end

          begin
            provisioning_profiles = provisioning_prifile.create!(uuid)
          rescue => e
            puts HighLine.color(I18n.t('xcode.export.create_provisioning.error.failed_to_create.provisioning_profile'), HighLine::RED)
            raise e
          end

          select_profile(provisioning_profiles)
        end

        # @param [LocalTeams] local_teams
        # @return [String]
        def select_teams(local_teams)
          result = nil
          cli = HighLine.new
          cli.choose do |menu|
            menu.prompt = I18n.t('xcode.export.select_teams.prompt')
            local_teams.teams.each do |team|
              menu.choice(I18n.t('xcode.export.select_teams.choice', team_name: team[:name], team_id: team[:id])) {
                profile_paths = local_teams.profile_paths(team[:id])
                result = DeployGate::Xcode::Export.select_profile(profile_paths)
              }
            end
          end

          result
        end

        def check_local_certificates
          if installed_distribution_certificate_ids.count == 0
            # not local install certificate
            puts HighLine.color(I18n.t('xcode.export.check_local_certificates.not_local_install_certificate.error_message'), HighLine::RED)
            puts ''
            puts I18n.t('xcode.export.check_local_certificates.not_local_install_certificate.note')
            puts ''
            exit
          end

          iphone_conflicting_certificates = installed_distribution_conflicting_certificates_by('iPhone Distribution')
          apple_conflicting_certificates = installed_distribution_conflicting_certificates_by('Apple Distribution')
          if iphone_conflicting_certificates.count > 0 || apple_conflicting_certificates.count > 0
            puts HighLine.color(I18n.t('xcode.export.check_local_certificates.conflict_certificate.error_message'), HighLine::RED)
            puts ''
            puts I18n.t('xcode.export.check_local_certificates.conflict_certificate.note')
            iphone_conflicting_certificates.each do |certificate|
              puts certificate
            end
            apple_conflicting_certificates.each do |certificate|
              puts certificate
            end
            puts ""

            exit
          end
        end

        # @param [String] bundle_identifier
        # @return [void]
        def clean_provisioning_profiles(bundle_identifier, team)
          puts I18n.t('xcode.export.clean_provisioning_profiles.start')
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
            puts I18n.t('xcode.export.clean_provisioning_profiles.delete', path: path)
          end

          puts ''
          puts I18n.t('xcode.export.clean_provisioning_profiles.finish')
        end
      end
    end
  end
end
