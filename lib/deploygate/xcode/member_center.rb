require 'singleton'

module DeployGate
  module Xcode
    class MemberCenter
      include Singleton
      attr_reader :email, :method, :team, :launcher

      def initialize
        @email = input_email
        @launcher = Spaceship::Launcher.new @email
        @team = @launcher.select_team

        if @launcher.client.in_house?
          @method = Export::ENTERPRISE
        else
          @method = Export::AD_HOC
        end
      end

      # @return [Boolean]
      def adhoc?
        @method == Export::AD_HOC
      end

      # @return [Boolean]
      def in_house?
        @method == Export::ENTERPRISE
      end

      private

      # @return [String]
      def input_email
        puts ''
        puts I18n.t('xcode.member_center.input_email.prompt')
        puts ''
        print I18n.t('xcode.member_center.input_email.email')
        STDIN.gets.chop
      end

    end
  end
end
