describe DeployGate::Xcode::Analyze do
  describe '#new' do
    subject { described_class.new(workspaces, build_configuration, target_scheme, xcodeproj) }

    let(:build_configuration) { nil }
    let(:target_scheme) { nil }
    let(:xcodeproj) { nil }

    describe 'detect scheme workspace and build workspace' do
      before do
        allow(FastlaneCore::Configuration).to receive(:create)
        project = instance_double(FastlaneCore::Project)
        allow(project).to receive(:select_scheme)
        allow(project).to receive(:schemes).and_return([])
        allow(project).to receive(:options).and_return({})
        allow(FastlaneCore::Project).to receive(:new).and_return(project)
        allow(Gym).to receive(:config=)
      end

      context 'exists single xcodeproj files' do
        let(:workspaces) do
          %w[
            /base_dir/Test/Test/Test.xcodeproj/project.xcworkspace
          ]
        end

        context 'without scheme workspace arg' do
          it 'build_workspace and xcodeproj is same' do
            is_expected.to have_attributes(
              build_workspace:  '/base_dir/Test/Test/Test.xcodeproj/project.xcworkspace',
              xcodeproj:  '/base_dir/Test/Test/Test.xcodeproj'
            )
          end
        end
      end

      context 'exists multiple xcodeproj files' do
        let(:workspaces) do
          %w[
            /base_dir/Test/ALib/ALib.xcodeproj/project.xcworkspace
            /base_dir/Test/Hoge/Hoge.xcodeproj/project.xcworkspace
            /base_dir/Test/Test/Test.xcodeproj/project.xcworkspace
            /base_dir/Test/Test.xcworkspace
            /base_dir/Test/ZLib/ZLib.xcodeproj/project.xcworkspace
          ]
        end

        context 'without scheme workspace arg' do
          it 'scheme workspace is last workspace has project.xcworkspace' do
            is_expected.to have_attributes(
              build_workspace:  '/base_dir/Test/Test.xcworkspace',
              xcodeproj: '/base_dir/Test/ZLib/ZLib.xcodeproj'
            )
          end
        end

        context 'with scheme workspace arg' do
          let(:xcodeproj) { './ZLib.xcodeproj' }

          it 'scheme workspace is last workspace has project.xcworkspace' do
            is_expected.to have_attributes(
              build_workspace:  '/base_dir/Test/Test.xcworkspace',
              xcodeproj: './ZLib.xcodeproj'
            )
          end
        end
      end
    end
  end
end
