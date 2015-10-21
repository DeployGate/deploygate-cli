describe DeployGate::Builds::Ios do
  describe "#initialize" do
    it "raise not work dir" do
      allow(File).to receive(:exist?).and_return(false)

      expect {
        DeployGate::Builds::Ios.new('path')
      }.to raise_error DeployGate::Builds::Ios::NotWorkDirExistError
    end
  end

  describe "#build" do
    it "should call Gym Manager" do
      call_gym_manager = false
      allow(FastlaneCore::Configuration).to receive(:create) {}
      allow_any_instance_of(Gym::Manager).to receive(:work) { call_gym_manager = true }
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:expand_path).and_return('path')

      DeployGate::Builds::Ios.new('path').build
      expect(call_gym_manager).to be_truthy
    end

    it "raise not support export" do
      allow(FastlaneCore::Configuration).to receive(:create) {}
      allow_any_instance_of(Gym::Manager).to receive(:work) {}
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:expand_path).and_return('path')

      expect {
        DeployGate::Builds::Ios.new('path').build('not support export method')
      }.to raise_error DeployGate::Builds::Ios::NotSupportExportMethodError
    end
  end

  describe "#workspace?" do
    it "pod workspace" do
      allow(File).to receive(:basename).and_return('.xcworkspace')

      result = DeployGate::Builds::Ios.workspace?('path')
      expect(result).to be_truthy
    end

    it "default workspace" do
      allow(File).to receive(:basename).and_return('.xcodeproj')

      result = DeployGate::Builds::Ios.workspace?('path')
      expect(result).to be_truthy
    end
  end

  describe "#find_workspaces" do
    # TODO: add test
  end

  describe "#select_workspace" do
    it "should select pods workspace" do
      select_workspace = 'test.xcworkspace'
      workspeces = ['test.xcodeproj', select_workspace]
      expect(DeployGate::Builds::Ios.select_workspace(workspeces)).to eq select_workspace
    end

    it "default project" do
      select_workspace = 'test.xcodeproj'
      workspeces = [select_workspace]
      expect(DeployGate::Builds::Ios.select_workspace(workspeces)).to eq select_workspace
    end
  end
end
