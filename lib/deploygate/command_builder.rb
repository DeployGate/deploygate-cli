module DeployGate
  class CommandBuilder
    include Commander::Methods
    attr_reader :arguments

    def run
      GithubIssueRequest::Url.config('deploygate', 'deploygate-cli')
      check_update()

      program :name, 'dg'
      program :version,  VERSION
      program :description, 'You can control to DeployGate in your terminal.'

      command :login do |c|
        c.syntax = 'dg login'
        c.description = 'DeployGate login command'
        c.action do |args, options|
          begin
            Commands::Login.run
          rescue => e
            error_handling("Commands::Login Error: #{e.class}", create_error_issue_body(e))
            raise e
          end
        end
      end

      command :deploy do |c|
        c.syntax = 'dg deploy /path/to/app'
        c.description = 'upload to deploygate'
        c.option '--message STRING', String, 'release message'
        c.option '--user STRING', String, 'owner name or group name'
        c.option '--distribution-key STRING', String, 'update distribution key'
        c.option '--open', 'open browser (OSX only)'
        c.option '--disable_notify', 'disable notify via email (iOS app only)'
        c.action do |args, options|
          options.default :message => '', :user => nil, :open => false, 'disable_notify' => false
          begin
            Commands::Deploy.run(args, options)
          rescue => e
            error_handling("Commands::Deploy Error: #{e.class}", create_error_issue_body(e))
            raise e
          end
        end
      end
      alias_command :'push', :deploy

      command 'add-devices' do |c|
        c.syntax = 'dg add-devices'
        c.description = 'add ios devices(iOS only)'
        c.option '--user STRING', String, 'owner name or group name'
        c.action do |args, options|
          options.default :user => nil
          begin
            Commands::AddDevices.run(args, options)
          rescue => e
            error_handling("Commands::AddDevices Error: #{e.class}", create_error_issue_body(e))
            raise e
          end
        end
      end

      command :logout do |c|
        c.syntax = 'dg logout'
        c.description = 'logout'
        c.action do |args, options|
          begin
            Commands::Logout.run
          rescue => e
            error_handling("Commands::Logout Error: #{e.class}", create_error_issue_body(e))
            raise e
          end
        end
      end

      command :config do |c|
        c.syntax = 'dg config'
        c.description = 'dg user login config'
        c.option '--json', 'output json format'
        c.option '--name STRING', String, 'your DeployGate user name'
        c.option '--token STRING', String, 'your DeployGate api token'
        c.action do |args, options|
          begin
            Commands::Config.run(args, options)
          rescue => e
            error_handling("Commands::Config Error: #{e.class}", create_error_issue_body(e))
            raise e
          end
        end
      end

      run!
    end

    # @param [Exception] error
    # @return [String]
    def create_error_issue_body(error)
      return <<EOF

# Status
deploygate-cli ver #{DeployGate::VERSION}

# Error message
#{error.message}

# Backtrace
```
#{error.backtrace.join("\n")}
```
EOF
    end

    # @param [String] title
    # @param [String] body
    # @param [Array] labels
    def error_handling(title, body, labels = [])
      options = {
          :title => title,
          :body  => body,
          :labels => labels
      }
      url = GithubIssueRequest::Url.new(options).to_s
      puts ''
      if HighLine.agree('Do you want to report this issue on GitHub? (y/n) ') {|q| q.default = "n"}
        puts "Please open github issue: #{url}"
        system('open', url) if Commands::Deploy::Push.openable?
      end
      puts ''
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
      update_message =<<EOF

#################################################################
# #{gem_name} #{latest_version} is available. You are on #{current_version}.
# It is recommended to use the latest version.
# Update using 'gem update #{gem_name}'.
#################################################################

EOF
      DeployGate::Message::Warning.print(update_message)
    end
  end
end
