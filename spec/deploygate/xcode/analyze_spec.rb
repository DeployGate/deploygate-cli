require 'spec_helper'

describe DeployGate::Xcode::Analyze do
  describe '#new' do
    subject(:analyze) do
      described_class.new(
        xcodeproj_path: xcodeproj_path,
        workspace_path: workspace_path,
        build_configuration: build_configuration,
        target_scheme: target_scheme
      )
    end

    let(:xcodeproj_path) { nil }
    let(:workspace_path) { nil }
    let(:build_configuration) { nil }
    let(:target_scheme) { nil }

    describe '#initialize' do
      context 'if the project is the single xcodeproject' do
        let(:expected_xcodeproj_path) { test_file_path("xcodeProjects", "Projects", "SingleProject", "SingleProject.xcodeproj") }

        around(:each) do |example|
          Dir.chdir(test_file_path("xcodeProjects", "Projects", "SingleProject")) do
            example.run
          end
        end

        it 'can find a project and get attributes' do
          analyze

          expect(Gym.project.project).not_to be_nil
          expect(Gym.config[:workspace]).to be_nil
          expect(analyze.xcodeproj_path).to eq(expected_xcodeproj_path)
          expect(analyze.scheme).to eq("SingleProject")
          expect(analyze.bundle_identifier).to eq("com.deploygate.example.SingleProject")
        end
      end

      context 'if the project is the single xcworkspace' do
        let(:expected_xcodeproj_path) { test_file_path("xcodeProjects", "Workspaces", "Single", "SingleWorkspace", "SingleWorkspace.xcodeproj") }

        around(:each) do |example|
          Dir.chdir(test_file_path("xcodeProjects", "Workspaces", "Single")) do
            example.run
          end
        end

        it 'can find a project and get attributes' do
          analyze

          expect(Gym.project.project).to be_nil
          expect(Gym.project.workspace).not_to be_nil
          expect(Gym.config[:workspace]).to eq("./SingleWorkspace.xcworkspace")
          expect(analyze.xcodeproj_path).to eq(expected_xcodeproj_path)
          expect(analyze.scheme).to eq("SingleWorkspace")
          expect(analyze.bundle_identifier).to eq("com.deploygate.example.SingleWorkspace")
        end
      end

      context 'if detection is nondeterministic' do
        around(:each) do |example|
          Dir.chdir(test_file_path("xcodeProjects")) do
            example.run
          end
        end

        it 'cannot choose any project' do
          expect { analyze }.to raise_error(FastlaneCore::Interface::FastlaneCrash)
        end

        context 'if the project is in multi-xcodeproject' do
          around(:each) do |example|
            Dir.chdir(test_file_path("xcodeProjects", "Projects", "Multi")) do
              example.run
            end
          end

          it 'cannot choose any project' do
            expect { analyze }.to raise_error(FastlaneCore::Interface::FastlaneCrash)
          end
        end
      end
    end
  end
end
