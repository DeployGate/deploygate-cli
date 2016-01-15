describe DeployGate::Xcode::LocalTeams do

  let(:local_teams) { DeployGate::Xcode::LocalTeams.new }

  context '#add' do
    it 'not count up when add already team id' do
      local_teams.add('1', 'name', 'path')
      local_teams.add('1', 'name', 'path')

      expect(local_teams.teams_count).to eq 1
    end

    it 'count up when add team id' do
      local_teams.add('1', 'name', 'path')
      local_teams.add('2', 'name', 'path')

      expect(local_teams.teams_count).to eq 2
    end
  end

  context '#profile_paths' do
    before do
      local_teams.add('1', 'name', 'path')
    end

    it 'should empty not register team id profile_paths' do
      expect(local_teams.profile_paths('not_id').empty?).to be_truthy
    end

    it 'should not empty registered team id profile_paths' do
      expect(local_teams.profile_paths('1')).to eq ['path']
    end
  end

  context 'first_team_profile_paths' do
    it 'should return empty not register team' do
      expect(local_teams.first_team_profile_paths.empty?).to be_truthy
    end

    it 'should return first team profile paths' do
      local_teams.add('1', 'name', 'path')
      expect(local_teams.first_team_profile_paths).to eq ['path']
    end
  end
end
