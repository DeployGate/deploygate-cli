module Dgate
  class CommandBuilder
    include Commander::Methods
    attr_reader :arguments

    def run
      program :name, 'Dgate'
      program :version,  VERSION
      program :description, 'You can push or update apps to DeployGate in your terminal.'

      command :init do |c|
        c.syntax = 'dgate init'
        c.description = 'dgate init command'
        c.action do |args, options|
          Commands::Init.run
        end
      end

      command :deploy do |c|
        c.syntax = 'dgate deploy /path/to/app'
        c.description = 'deploy command'
        c.option '--message STRING', String, 'release message'
        c.option '--user STRING', String, 'owner name or group name'
        c.option '--open', 'open browser'
        c.option '--disable_notify', 'disable notify via email (iOS app only)'
        c.action do |args, options|
          options.default :message => '', :user => nil, :open => false, 'disable_notify' => false
          Commands::Deploy.run(args, options)
        end
      end
      alias_command :'push', :deploy

      command :logout do |c|
        c.syntax = 'dgate logout'
        c.description = 'dgate logout command'
        c.action do |args, options|
          Commands::Logout.run
        end
      end

      run!
    end
  end
end
