describe DeployGate::Builds::Ios::Export do
  describe "#adhoc?" do
    it "when adhoc plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Builds::Ios::Export.adhoc?('path')).to be_truthy
    end

    it "when inhouse plist" do
      profile = {
          'ProvisionsAllDevices' => true,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Builds::Ios::Export.adhoc?('path')).to be_falsey
    end

    it "when not distribution plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => true}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Builds::Ios::Export.adhoc?('path')).to be_falsey
    end
  end

  describe "#inhouse?" do
    it "when adhoc plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Builds::Ios::Export.inhouse?('path')).to be_falsey
    end

    it "when inhouse plist" do
      profile = {
          'ProvisionsAllDevices' => true,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Builds::Ios::Export.inhouse?('path')).to be_truthy
    end

    it "when not distribution plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => true}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:profile_to_plist).and_return(profile)
      expect(DeployGate::Builds::Ios::Export.inhouse?('path')).to be_falsey
    end
  end

  describe "#installed_distribution_certificate_ids" do
    before do
      @distribution_certificate_id = 'distribution_certificate_id'
      @distribution_certificate = "  1) #{@distribution_certificate_id} \"iPhone Distribution: DeployGate Inc.\""
      @not_distribution_certificate = "  1) xxxxxxxxxxxxxx \"iPhone Developer: DeployGate Inc.\""
    end
    it "not installed distribution certificate" do
      allow(DeployGate::Builds::Ios::Export).to receive(:installed_certificates).and_return([@not_distribution_certificate])
      expect(DeployGate::Builds::Ios::Export.installed_distribution_certificate_ids.count).to eql 0
    end

    it "installed distribution certificate" do
      allow(DeployGate::Builds::Ios::Export).to receive(:installed_certificates).and_return([@distribution_certificate, @not_distribution_certificate])

      ids = DeployGate::Builds::Ios::Export.installed_distribution_certificate_ids
      expect(ids).to eql([@distribution_certificate_id])
    end
  end

  describe "#installed_distribution_conflicting_certificates" do
    before do
      @distribution_certificate = "  1) xxxxxxxxxx \"iPhone Distribution: DeployGate Inc.\""
      @distribution_certificate2 = "  2) yyyyyyyyyyyy \"iPhone Distribution: DeployGate Inc.\""
      @distribution_certificate3 = "  2) yyyyyyyyyyyy \"iPhone Distribution: DeployGate Inc2.\""
    end

    it "conflicting" do
      allow(DeployGate::Builds::Ios::Export).to receive(:installed_certificates).and_return([@distribution_certificate, @distribution_certificate2])
      expect(DeployGate::Builds::Ios::Export.installed_distribution_conflicting_certificates.count).to eql 2
    end

    it "not conflicting" do
      allow(DeployGate::Builds::Ios::Export).to receive(:installed_certificates).and_return([@distribution_certificate, @distribution_certificate3])
      expect(DeployGate::Builds::Ios::Export.installed_distribution_conflicting_certificates.count).to eql 0
    end
  end
end
