module DeployGate
  class Config
    class << self

      # @return [String]
      def file_path
        ENV["HOME"] + "/.dg"
      end

      # @param [Hash] config
      # @return [void]
      def write(config)
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