require 'singleton'

module DeployGate
  module Xcode
    class MemberCenter
      include Singleton
      attr_reader :email, :method, :team

      def initialize
        @email = input_email
        Spaceship.login @email
        @team = Spaceship.select_team

        if Spaceship.client.in_house?
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
