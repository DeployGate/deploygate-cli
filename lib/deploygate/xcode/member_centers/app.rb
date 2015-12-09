module DeployGate
  module Xcode
    module MemberCenters
      class App
        attr_reader :uuid, :member_center

        # @param [String] uuid
        # @return [DeployGate::Xcode::MemberCenters::App]
        def initialize(uuid)
          @member_center = DeployGate::Xcode::MemberCenter.instance
          @uuid = uuid
        end

        # @return [Boolean]
        def created?
          Spaceship.app.all.collect do |app|
            return true if app.bundle_id == @uuid
          end

          false
        end

        # @return [void]
        def create!
          Spaceship.app.create!(bundle_id: @uuid, name: name())
        end

        # @return [String]
        def name
          @uuid.split('.').join(' ')
        end
      end
    end
  end
end
