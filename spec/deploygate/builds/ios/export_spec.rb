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
end
