describe DeployGate::Project do
  describe "#ios?" do
    it "when select workspace" do
      allow(DeployGate::Xcode::Ios).to receive(:ios_root?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:workspace?).and_return(true)
      allow(DeployGate::Xcode::Ios).to receive(:project?).and_return(false)

      result = DeployGate::Project.ios?('path')
      expect(result).to be_truthy
    end

    it "when workspaces" do
      allow(DeployGate::Xcode::Ios).to receive(:ios_root?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:workspace?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:project?).and_return(true)

      result = DeployGate::Project.ios?('path')
      expect(result).to be_truthy
    end

    it "not ios" do
      allow(DeployGate::Xcode::Ios).to receive(:ios_root?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:workspace?).and_return(false)
      allow(DeployGate::Xcode::Ios).to receive(:project?).and_return(false)

      result = DeployGate::Project.ios?('path')
      expect(result).to be_falsey
    end
  end

  describe "#android?" do
    it "android project" do
      allow(DeployGate::Android::GradleProject).to receive(:root_dir?).and_return(true)

      result = DeployGate::Project.android?('path')
      expect(result).to be_truthy
    end
  end
end
