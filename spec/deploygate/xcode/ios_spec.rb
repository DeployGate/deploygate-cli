describe DeployGate::Xcode::Ios do
  before do
    class ProjectMock
      def schemes
        []
      end
    end
    class AnalyzeMock
      def build_workspace
        ''
      end
      def xcodeproj
        ''
      end
    end
  end

  describe "#build" do
    it "should call Gym Manager" do
      call_gym_manager = false
      allow(FastlaneCore::Configuration).to receive(:create) {}
      allow_any_instance_of(Gym::Manager).to receive(:work) { call_gym_manager = true }
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:expand_path).and_return('path')
      allow(FastlaneCore::Project).to receive(:new).and_return(ProjectMock.new)

      DeployGate::Xcode::Ios.build(AnalyzeMock.new, '', '')
      expect(call_gym_manager).to be_truthy
    end

    it "raise not support export" do
      allow(FastlaneCore::Configuration).to receive(:create) {}
      allow_any_instance_of(Gym::Manager).to receive(:work) {}
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:expand_path).and_return('path')
      allow(FastlaneCore::Project).to receive(:new).and_return(ProjectMock.new)

      expect {
        DeployGate::Xcode::Ios.build(AnalyzeMock.new, '', '', nil, '',  'not support export method')
      }.to raise_error DeployGate::Xcode::Analyze::NotSupportExportMethodError
    end
  end

  describe "#workspace?" do
    it "pod workspace" do
      allow(File).to receive(:extname).and_return('.xcworkspace')

      result = DeployGate::Xcode::Ios.workspace?('path')
      expect(result).to be_truthy
    end

    it "xcode project" do
      allow(File).to receive(:extname).and_return('.xcodeproj')

      result = DeployGate::Xcode::Ios.workspace?('path')
      expect(result).to be_falsey
    end
  end

  describe "#project?" do
    it "pod workspace" do
      allow(File).to receive(:extname).and_return('.xcworkspace')

      result = DeployGate::Xcode::Ios.project?('path')
      expect(result).to be_falsey
    end

    it "xcode project" do
      allow(File).to receive(:extname).and_return('.xcodeproj')

      result = DeployGate::Xcode::Ios.project?('path')
      expect(result).to be_truthy
    end
  end

  describe "#find_workspaces" do
    # TODO: add test
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
