module DeployGate
  class CommandBuilder
    include Commander::Methods
    attr_reader :arguments

    class NotInternetConnectionError < DeployGate::RavenIgnoreException
    end

    PING_URL = 'https://deploygate.com'

    LOGIN       = 'login'
    LOGOUT      = 'logout'
    DEPLOY      = 'deploy'
    ADD_DEVICES = 'add-devices'
    CONFIG      = 'config'

    def setup
      # sentry config
      Raven.configure do |config|
        config.dsn = 'https://e0b4dda8fe2049a7b0d98c6d2759e067@sentry.io/1371610'
        config.logger = Raven::Logger.new('/dev/null') # hide sentry log
        config.excluded_exceptions = Raven::Configuration::IGNORE_DEFAULT + [DeployGate::RavenIgnoreException.name]
      end

      # set Ctrl-C trap
      Signal.trap(:INT){
        puts ''
        exit 0
      }

      # check internet connection
      unless internet_connection?
        STDERR.puts HighLine.color(I18n.t('command_builder.not_internet_connection_error'), HighLine::RED)
        exit
      end

      check_update()
    end

    def run
      setup()

      program :help_paging, false
      program :name, I18n.t('command_builder.name')
      program :version,  VERSION
      program :description, I18n.t('command_builder.description')

      command LOGIN do |c|
        c.syntax = 'dg login'
        c.description = I18n.t('command_builder.login.description')
        c.option '--terminal', I18n.t('command_builder.login.terminal')
        c.action do |args, options|
          options.default :terminal => false
          begin
            Commands::Login.run(args, options)
          rescue => e
            error_handling(LOGIN, e)
            exit 1
          end
        end
      end

      command DEPLOY do |c|
        c.syntax = 'dg deploy /path/to/app'
        c.description = I18n.t('command_builder.deploy.description')
        c.option '--message STRING', String, I18n.t('command_builder.deploy.message')
        c.option '--user STRING', String, I18n.t('command_builder.deploy.user')
        c.option '--distribution-key STRING', String, I18n.t('command_builder.deploy.distribution_key')
        c.option '--configuration STRING', String, I18n.t('command_builder.deploy.configuration')
        c.option '--scheme STRING', String, I18n.t('command_builder.deploy.scheme')
        c.option '--open', I18n.t('command_builder.deploy.open')
        c.option '--disable_notify', I18n.t('command_builder.deploy.disable_notify')
        c.action do |args, options|
          options.default :message => '', :user => nil, :open => false, 'disable_notify' => false, :command => nil
          begin
            Commands::Deploy.run(args, options)
          rescue => e
            error_handling(DEPLOY, e)
            exit 1
          end
        end
      end
      alias_command :'push', :deploy

      command ADD_DEVICES do |c|
        c.syntax = 'dg add-devices'
        c.description = I18n.t('command_builder.add_devices.description')
        c.option '--user STRING', String, I18n.t('command_builder.add_devices.user')
        c.option '--udid STRING', String, I18n.t('command_builder.add_devices.udid')
        c.option '--device-name STRING', String, I18n.t('command_builder.add_devices.device_name')
        c.option '--distribution-key STRING', String, I18n.t('command_builder.add_devices.distribution_key')
        c.option '--configuration STRING', String, I18n.t('command_builder.deploy.configuration')
        c.option '--server', I18n.t('command_builder.add_devices.server.description')
        c.action do |args, options|
          options.default :user => nil, :server => false, :command => 'add_devices'
          begin
            Commands::AddDevices.run(args, options)
          rescue => e
            error_handling(ADD_DEVICES, e)
            exit 1
          end
        end
      end

      command LOGOUT do |c|
        c.syntax = 'dg logout'
        c.description = I18n.t('command_builder.logout.description')
        c.action do |args, options|
          begin
            Commands::Logout.run
          rescue => e
            error_handling(LOGOUT, e)
            exit 1
          end
        end
      end

      command CONFIG do |c|
        c.syntax = 'dg config'
        c.description = I18n.t('command_builder.config.description')
        c.option '--json', I18n.t('command_builder.config.json')
        c.option '--name STRING', String, I18n.t('command_builder.config.name')
        c.option '--token STRING', String, I18n.t('command_builder.config.token')
        c.action do |args, options|
          begin
            Commands::Config.run(args, options)
          rescue => e
            error_handling(CONFIG, e)
            exit 1
          end
        end
      end

      run!
    end

    # @param [String] command
    # @param [Exception] error
    def error_handling(command, error)
      STDERR.puts HighLine.color(I18n.t('command_builder.error_handling.message', message: error.message), HighLine::RED)
      return if ENV['CI'] # When run ci server
      return if error.kind_of?(DeployGate::RavenIgnoreException)

      dg_version = DeployGate::VERSION
      tags = {
          command: command,
          dg_version: dg_version
      }
      version = Gym::Xcode.xcode_version
      tags[:xcode_version] = version if version.present?

      puts ''
      puts error_report(error, dg_version, version)
      if HighLine.agree(I18n.t('command_builder.error_handling.agree')) {|q| q.default = "y"}
        tags = {
            command: command,
            dg_version: DeployGate::VERSION
        }
        version = Gym::Xcode.xcode_version
        tags[:xcode_version] = version if version.present?

        Raven.capture_exception(error, tags: tags)
        puts HighLine.color(I18n.t('command_builder.error_handling.thanks'), HighLine::GREEN)
      end
    end

    def error_report(error, dg_version, xcode_version)
      meta_info = "dg version: #{dg_version}"
      meta_info += "\nXcode version: #{xcode_version}" if xcode_version.present?

      backtrace = error.backtrace.take(5).join("\n")
      backtrace += "\nand more ..." if error.backtrace.count > 5

      <<EOF
------------------------
DeployGate Error Report 

Title: #{error}
#{meta_info}

Stack trace:
#{backtrace}
------------------------
EOF
    end

    # @return [void]
    def check_update
      current_version = DeployGate::VERSION

      # check cache
      if DeployGate::Config::CacheVersion.exist?
        data = DeployGate::Config::CacheVersion.read
        if Time.parse(data['check_date']) > 1.day.ago
          # cache available
          latest_version = data['latest_version']
          if Gem::Version.new(latest_version) > Gem::Version.new(current_version)
            show_update_message(latest_version)
          end
        else
          request_gem_update_checker
        end
      else
        request_gem_update_checker
      end
    rescue => e
      STDERR.puts I18n.t('errors.check_update_failure')
    end

    # @return [void]
    def request_gem_update_checker
      gem_name = DeployGate.name.downcase
      current_version = DeployGate::VERSION

      checker = GemUpdateChecker::Client.new(gem_name, current_version)
      if checker.update_available
        show_update_message(checker.latest_version)
      end
      cache_data = {
          :latest_version => checker.latest_version,
          :check_date => Time.now
      }
      DeployGate::Config::CacheVersion.write(cache_data)
    end

    # @param [String] latest_version
    # @return [void]
    def show_update_message(latest_version)
      gem_name = DeployGate.name.downcase
      current_version = DeployGate::VERSION
      STDERR.puts ''
      STDERR.puts HighLine.color(I18n.t('command_builder.show_update_message', gem_name: gem_name, latest_version: latest_version, current_version: current_version), HighLine::YELLOW)
      STDERR.puts ''
    end

    # @return [Boolean]
    def internet_connection?
      Net::Ping::HTTP.new(PING_URL).ping?
    end
  end
end
