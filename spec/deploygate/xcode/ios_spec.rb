class FakeGemManager
  def initialize(ipa_path:)
    @ipa_path = ipa_path
  end

  def work(*)
    @work = true
    @ipa_path
  end

  def has_called_work?
    @work
  end
end

describe DeployGate::Xcode::Ios do
  let(:xcodeproj_path) { test_file_path("xcodeProjects", "Projects", "SingleProject", "SingleProject.xcodeproj") }
  let(:workspace_path) { test_file_path("xcodeProjects", "Workspaces", "Single", "SingleWorkspace.xcworkspace") }

  describe "#build" do
    let(:gem_manager) { FakeGemManager.new(ipa_path: test_file_path("xcodeProjects", "fake.ipa")) }

    before do
      allow(Gym::Manager).to receive(:new).and_return(gem_manager)
    end

    it "should call Gym Manager and allow provisioning updates without an option" do
      DeployGate::Xcode::Ios.build(
        ios_analyze: DeployGate::Xcode::Analyze.new(
          xcodeproj_path: xcodeproj_path
        )
      )

      expect(gem_manager).to be_has_called_work
      expect(Gym.config.values).to include(
                                     xcargs: '-allowProvisioningUpdates',
                                     export_xcargs: '-allowProvisioningUpdates'
                                   )
    end

    it "should call Gym Manager and disallow provisioning updates if an option is provided" do
      DeployGate::Xcode::Ios.build(
        ios_analyze: DeployGate::Xcode::Analyze.new(
          xcodeproj_path: xcodeproj_path
        ),
        allow_provisioning_updates: false
      )

      expect(gem_manager).to be_has_called_work
      expect(Gym.config.values).not_to include(
                                     xcargs: include('-allowProvisioningUpdates'),
                                     export_xcargs: include('-allowProvisioningUpdates')
                                   )
    end
  end

  describe "#workspace?" do
    it "returns true if it's a workspace file" do
      expect(DeployGate::Xcode::Ios.workspace?(workspace_path)).to be_truthy
    end

    it "returns false if it's a xcode project file" do
      expect(DeployGate::Xcode::Ios.workspace?(xcodeproj_path)).to be_falsey
    end
  end

  describe "#project?" do
    it "returns false if it's a workspace file" do
      expect(DeployGate::Xcode::Ios.project?(workspace_path)).to be_falsey
    end

    it "returns true if it's a xcode project file" do
      expect(DeployGate::Xcode::Ios.project?(xcodeproj_path)).to be_truthy
    end
  end

  describe "#project_root_path" do
    let(:root_path) {'test'}
    it "when test/test.xcodeproj/project.xcworkspace" do
      expect(DeployGate::Xcode::Ios.project_root_path('test/test.xcodeproj/project.xcworkspace')).to eq root_path
    end

    it "when test/test.xcodeproj" do
      expect(DeployGate::Xcode::Ios.project_root_path('test/test.xcodeproj')).to eq root_path
    end

    it "when test/test.xcworkspace" do
      expect(DeployGate::Xcode::Ios.project_root_path('test/test.xcworkspace')).to eq root_path
    end

    it "when test/" do
      expect(DeployGate::Xcode::Ios.project_root_path('test/')).to eq root_path + '/'
    end
  end
end
