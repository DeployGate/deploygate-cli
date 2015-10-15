module Dgate
  class CommandBuilder
    attr_reader :arguments

    def initialize(arguments = ARGV)
      @arguments = arguments
    end

    def build
      Commands::Run.new(options)
    end

    private

    def options
      # arguments => options
      {}
    end
  end
end
