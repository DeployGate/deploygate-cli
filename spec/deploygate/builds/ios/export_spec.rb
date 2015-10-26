describe DeployGate::Builds::Ios::Export do
  describe "#adhoc?" do
    it "when adhoc plist" do
      plist = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:analyze_profile).and_return(plist)
      expect(DeployGate::Builds::Ios::Export.adhoc?('path')).to be_truthy
    end

    it "when inhouse plist" do
      plist = {
          'ProvisionsAllDevices' => true,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:analyze_profile).and_return(plist)
      expect(DeployGate::Builds::Ios::Export.adhoc?('path')).to be_falsey
    end

    it "when not distribution plist" do
      plist = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => true}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:analyze_profile).and_return(plist)
      expect(DeployGate::Builds::Ios::Export.adhoc?('path')).to be_falsey
    end
  end

  describe "#inhouse?" do
    it "when adhoc plist" do
      plist = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:analyze_profile).and_return(plist)
      expect(DeployGate::Builds::Ios::Export.inhouse?('path')).to be_falsey
    end

    it "when inhouse plist" do
      plist = {
          'ProvisionsAllDevices' => true,
          'Entitlements' => {'get-task-allow' => false}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:analyze_profile).and_return(plist)
      expect(DeployGate::Builds::Ios::Export.inhouse?('path')).to be_truthy
    end

    it "when not distribution plist" do
      plist = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => true}
      }
      allow(DeployGate::Builds::Ios::Export).to receive(:analyze_profile).and_return(plist)
      expect(DeployGate::Builds::Ios::Export.inhouse?('path')).to be_falsey
    end
  end
end
