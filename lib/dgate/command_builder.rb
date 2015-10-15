module Dgate
  class CommandBuilder
    attr_reader :arguments

    def call
      program :name, 'Dgate'
      program :version,  VERSION
      program :description, 'You can push or update apps to DeployGate in your terminal.'

      command :init do |c|
        c.syntax = 'dgate init'
        c.description = 'dgate init command'
        c.action do |args, options|
          p 'init'
        end
      end
      command :deploy do |c|
        c.syntax = 'dgate deploy /path/to/app'
        c.description = 'deploy command'
        c.option '--message STRING', String, 'release message'
        c.option '--open', 'open browser'
        c.action do |args, options|
          options.default :message => '', :open => false
          p 'deploy'
        end
      end
    end
  end
end
