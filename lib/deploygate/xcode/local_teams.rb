module DeployGate
  module Xcode
    class LocalTeams

      def initialize
        @team_ids = []
        @team_names = []
        @team_profile_paths = {}
      end

      # @param [String] id
      # @param [String] name
      # @param [String] profile_path
      # @return [void]
      def add(id, name, profile_path)
        unless @team_ids.include?(id)
          @team_ids.push(id)
          @team_names.push(name)

          @team_profile_paths[id] = []
        end

        @team_profile_paths[id].push(profile_path) unless @team_profile_paths.include?(profile_path)
      end

      # @return [Fixnum]
      def teams_count
        @team_ids.count
      end

      # @return [Array<String>]
      def first_team_profile_paths
        return [] if @team_ids.empty?
        profile_paths(@team_ids.first)
      end

      # @return [Array<Hash>]
      #
      # [
      #   {id: xxxx, name: xxxxx},
      #   {id: xxxx, name: xxxxx}
      # ]
      #
      def teams
        teams = []
        @team_ids.each_with_index{|id, index| teams.push({id: id, name: @team_names[index]})}

        teams
      end

      # @param [String] id
      # @return [Array<String>]
      def profile_paths(id)
        return [] unless @team_ids.include?(id)

        @team_profile_paths[id]
      end
    end
  end
end
