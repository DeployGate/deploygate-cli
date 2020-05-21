describe DeployGate::Xcode::Export do
  describe "#adhoc?" do
    it "when adhoc plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Xcode::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Xcode::Export.adhoc?('path')).to be_truthy
    end

    it "when inhouse plist" do
      profile = {
          'ProvisionsAllDevices' => true,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Xcode::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Xcode::Export.adhoc?('path')).to be_falsey
    end

    it "when not distribution plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => true}
      }
      allow(DeployGate::Xcode::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Xcode::Export.adhoc?('path')).to be_falsey
    end
  end

  describe "#inhouse?" do
    it "when adhoc plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Xcode::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Xcode::Export.inhouse?('path')).to be_falsey
    end

    it "when inhouse plist" do
      profile = {
          'ProvisionsAllDevices' => true,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Xcode::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Xcode::Export.inhouse?('path')).to be_truthy
    end

    it "when not distribution plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => true}
      }
      allow(DeployGate::Xcode::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Xcode::Export.inhouse?('path')).to be_falsey
    end
  end

  describe "#installed_distribution_certificate_ids" do
    before do
      @distribution_certificate_id = 'distribution_certificate_id'
      @distribution_certificate = "  1) #{@distribution_certificate_id} \"iPhone Distribution: DeployGate Inc.\""
      @apple_distribution_certificate = "  1) #{@distribution_certificate_id} \"Apple Distribution: DeployGate Inc.\""
      @not_distribution_certificate = "  1) xxxxxxxxxxxxxx \"iPhone Developer: DeployGate Inc.\""
    end
    it "not installed distribution certificate" do
      allow(DeployGate::Xcode::Export).to receive(:installed_certificates).and_return([@not_distribution_certificate])
      expect(DeployGate::Xcode::Export.installed_distribution_certificate_ids.count).to eql 0
    end

    it "installed distribution certificate" do
      allow(DeployGate::Xcode::Export).to receive(:installed_certificates).and_return([@distribution_certificate, @not_distribution_certificate])

      ids = DeployGate::Xcode::Export.installed_distribution_certificate_ids
      expect(ids).to eql([@distribution_certificate_id])
    end

    it "installed apple distribution certificate" do
      allow(DeployGate::Xcode::Export).to receive(:installed_certificates).and_return([@apple_distribution_certificate, @not_distribution_certificate])

      ids = DeployGate::Xcode::Export.installed_distribution_certificate_ids
      expect(ids).to eql([@distribution_certificate_id])
    end
  end

  describe "#installed_distribution_conflicting_certificates_by" do
    before do
      @distribution_certificate = "  1) xxxxxxxxxx \"iPhone Distribution: DeployGate Inc.\""
      @distribution_certificate2 = "  2) yyyyyyyyyyyy \"iPhone Distribution: DeployGate Inc.\""
      @distribution_certificate3 = "  2) yyyyyyyyyyyy \"iPhone Distribution: DeployGate Inc2.\""

      @apple_distribution_certificate = "  1) xxxxxxxxxxx \"Apple Distribution: DeployGate Inc.\""
      @apple_distribution_certificate2 = "  2) yyyyyyyyyyyy \"Apple Distribution: DeployGate Inc.\""
      @apple_distribution_certificate3 = "  2) yyyyyyyyyyyy \"Apple Distribution: DeployGate Inc2.\""
    end

    it "conflicting" do
      allow(DeployGate::Xcode::Export).to receive(:installed_certificates).and_return([@distribution_certificate, @distribution_certificate2])
      expect(DeployGate::Xcode::Export.installed_distribution_conflicting_certificates_by('iPhone Distribution').count).to eql 2
    end

    it "conflicting by apple" do
      allow(DeployGate::Xcode::Export).to receive(:installed_certificates).and_return([@apple_distribution_certificate, @apple_distribution_certificate2])
      expect(DeployGate::Xcode::Export.installed_distribution_conflicting_certificates_by('Apple Distribution').count).to eql 2
    end

    it "not conflicting" do
      allow(DeployGate::Xcode::Export).to receive(:installed_certificates).and_return([@distribution_certificate, @distribution_certificate3])
      expect(DeployGate::Xcode::Export.installed_distribution_conflicting_certificates_by('iPhone Distribution').count).to eql 0
    end

    it "not conflicting by apple" do
      allow(DeployGate::Xcode::Export).to receive(:installed_certificates).and_return([@apple_distribution_certificate, @apple_distribution_certificate3])
      expect(DeployGate::Xcode::Export.installed_distribution_conflicting_certificates_by('Apple Distribution').count).to eql 0
    end
  end
end
