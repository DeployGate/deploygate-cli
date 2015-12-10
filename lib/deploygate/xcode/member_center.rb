require 'singleton'

module DeployGate
  module Xcode
    class MemberCenter
      include Singleton
      attr_reader :email, :method

      def initialize
        @email = input_email
        Spaceship.login @email
        Spaceship.select_team

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
        puts <<EOF

No suitable provisioning profile found to export the app.

Please enter your email and password for Apple Developer Center
to set up/download provisioning profile automatically so you can
export the app without any extra steps.

Note: Your password will be stored to Keychain and never be sent to DeployGate.

EOF
        print 'Email: '
        STDIN.gets.chop
      end

    end
  end
end
