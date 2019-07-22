module DeployGate
  module Xcode
    module MemberCenters
      class App
        attr_reader :uuid, :member_center

        # @param [String] uuid
        # @param [Xcode::MemberCenter] member_center
        # @return [DeployGate::Xcode::MemberCenters::App]
        def initialize(uuid, member_center)
          @member_center = member_center
          @uuid = uuid
        end

        # @return [Boolean]
        def created?
          @member_center.launcher.app.all.collect do |app|
            return true if app.bundle_id == @uuid
          end

          false
        end

        # @return [void]
        def create!
          @member_center.launcher.app.create!(bundle_id: @uuid, name: name())
        end

        # @return [String]
        def name
          @uuid.split('.').join(' ')
        end
      end
    end
  end
end
