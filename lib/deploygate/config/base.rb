module DeployGate
  module Config
    class Base
      class << self
        def file_path
          # Please override this method
          raise NotImplementedError.new("You must implement #{self.class}##{__method__}")
        end

        # @param [Hash] config
        # @return [void]
        def write(config)
          FileUtils.mkdir_p(File.dirname(file_path))

          data = JSON.generate(config)
          file = File.open(file_path, "w+")
          file.print data
          file.close
        end

        # @return [Hash]
        def read
          file = File.open(file_path)
          data = file.read
          file.close
          JSON.parse(data)
        end

        # @return [Boolean]
        def exist?
          File.exist?(file_path)
        end
      end
    end
  end
end
