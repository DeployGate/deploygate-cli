describe DeployGate::Build do
  describe "#ios?" do
    it "when select workspace" do
      allow(DeployGate::Xcode::Ios).to receive(:ios_root?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:workspace?).and_return(true)
      allow(DeployGate::Xcode::Ios).to receive(:project?).and_return(false)

      result = DeployGate::Build.ios?('path')
      expect(result).to be_truthy
    end

    it "when workspaces" do
      allow(DeployGate::Xcode::Ios).to receive(:ios_root?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:workspace?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:project?).and_return(true)

      result = DeployGate::Build.ios?('path')
      expect(result).to be_truthy
    end

    it "not ios" do
      allow(DeployGate::Xcode::Ios).to receive(:ios_root?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:workspace?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:project?).and_return(false)

      result = DeployGate::Build.ios?('path')
      expect(result).to be_falsey
    end
  end

  describe "#android?" do
    it "android not support" do
      result = DeployGate::Build.android?('path')
      expect(result).to be_falsey
    end
  end
end
