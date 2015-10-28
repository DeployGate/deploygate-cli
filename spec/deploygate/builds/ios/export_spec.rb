describe DeployGate::Builds::Ios::Export do
  describe "#adhoc?" do
    it "when adhoc plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => false}
      }
      expect(DeployGate::Builds::Ios::Export.adhoc?(profile)).to be_truthy
    end

    it "when inhouse plist" do
      profile = {
          'ProvisionsAllDevices' => true,
          'Entitlements' => {'get-task-allow' => false}
      }
      expect(DeployGate::Builds::Ios::Export.adhoc?(profile)).to be_falsey
    end

    it "when not distribution plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => true}
      }
      expect(DeployGate::Builds::Ios::Export.adhoc?(profile)).to be_falsey
    end
  end

  describe "#inhouse?" do
    it "when adhoc plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => false}
      }
      expect(DeployGate::Builds::Ios::Export.inhouse?(profile)).to be_falsey
    end

    it "when inhouse plist" do
      profile = {
          'ProvisionsAllDevices' => true,
          'Entitlements' => {'get-task-allow' => false}
      }
      expect(DeployGate::Builds::Ios::Export.inhouse?(profile)).to be_truthy
    end

    it "when not distribution plist" do
      profile = {
          'ProvisionsAllDevices' => nil,
          'Entitlements' => {'get-task-allow' => true}
      }
      expect(DeployGate::Builds::Ios::Export.inhouse?(profile)).to be_falsey
    end
  end
end
