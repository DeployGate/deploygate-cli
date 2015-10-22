module DeployGate
  module Builds
    module Ios
      class Export
        AD_HOC = 'ad-hoc'
        ENTERPRISE = 'enterprise'
        SUPPORT_EXPORT_METHOD = [AD_HOC, ENTERPRISE]

        class << self
          def method
            AD_HOC
          end
        end
      end
    end
  end
end
