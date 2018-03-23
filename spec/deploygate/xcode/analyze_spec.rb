describe DeployGate::Xcode::Analyze do

  context '#convert_bundle_identifier' do

    class DummyProject
      SCHEME = 'dummy'
      def schemes
        [SCHEME, 'dummy2']
      end

      def options
        {}
      end
    end

    class DummyProjectSetting
      def name
        'TargetName'
      end
    end

    class DummyBuildConfigration
      def build_settings
        {
            'PRODUCT_NAME' => '$(TARGET_NAME)',
            'CUSTOM_KEY'   => 'CustomKey'
        }
      end
    end

    before do
      allow_any_instance_of(DeployGate::Xcode::Analyze).to receive(:find_scheme_workspace).and_return('')
      allow_any_instance_of(DeployGate::Xcode::Analyze).to receive(:find_build_workspace)
      allow_any_instance_of(DeployGate::Xcode::Analyze).to receive(:target_build_configration).and_return(DummyBuildConfigration.new)
      allow_any_instance_of(DeployGate::Xcode::Analyze).to receive(:target_project_setting).and_return(DummyProjectSetting.new)
      allow(FastlaneCore::Configuration).to receive(:create)
      allow(FastlaneCore::Project).to receive(:new).and_return(DummyProject.new)
    end

    it do
      analyze = DeployGate::Xcode::Analyze.new('', nil, DummyProject::SCHEME)
      expect(analyze.convert_bundle_identifier('com.deploygate.$(PRODUCT_NAME).${CUSTOM_KEY}')).to eq 'com.deploygate.TargetName.CustomKey'
    end
  end

end
