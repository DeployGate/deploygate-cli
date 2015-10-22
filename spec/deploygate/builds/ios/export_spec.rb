describe DeployGate::Builds::Ios::Export do
  describe "#method" do
    it "only ad-hoc user" do
      allow(DeployGate::Builds::Ios::Export).to receive(:profiles).and_return(['adhoc'])
      allow(DeployGate::Builds::Ios::Export).to receive(:inhouse?).and_return(false)
      allow(DeployGate::Builds::Ios::Export).to receive(:adhoc?).and_return(true)
      expect(DeployGate::Builds::Ios::Export.method).to eq DeployGate::Builds::Ios::Export::AD_HOC
    end

    it "inhouse user" do
      allow(DeployGate::Builds::Ios::Export).to receive(:profiles).and_return(['inhouse'])
      allow(DeployGate::Builds::Ios::Export).to receive(:inhouse?).and_return(true)
      allow(DeployGate::Builds::Ios::Export).to receive(:adhoc?).and_return(true)
      expect(DeployGate::Builds::Ios::Export.method).to eq DeployGate::Builds::Ios::Export::ENTERPRISE
    end
  end

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
