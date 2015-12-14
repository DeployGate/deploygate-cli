module DeployGate
  module Android
    class GradleDeploy
      def initialize (dir = nil)
        @dir = dir || Dir.pwd
        @cli = HighLine.new

        GradleProject.root_dir?(@dir)     or raise "#{@dir} is not the root directory of Android project"
        Dir.chdir(@dir)                   or raise "Cannot chdir to #{@dir}"
        @gradle = find_gradle_executable  or raise 'Gradle executable not found.'
      end

      def deploy
        print 'Looking for DeployGate tasks...'
        tasks = get_deploygate_tasks
        puts

        task  = case tasks.size
                  when 0
                    install_plugin and return deploy
                  when 1
                    tasks[0]
                  else
                    choose(tasks)
                end

        run_task task unless task.nil?
      end

      private

      def find_gradle_executable
        if File.exist?('gradlew')
          './gradlew'
        else
          cmd = %x(which gradle)
          !cmd.empty? and cmd
        end
      end

      def install_plugin
        if @cli.agree("<%= color('Looks like Gradle DeployGate plugin isn\\'t available on your project.', BOLD) %> Install? ") {|q| q.default = 'y'}
          GradlePluginInstaller.new.install
        end
      end

      def choose(tasks)
        @cli.choose do |menu|
          menu.prompt = 'Please choose a task to run: '
          menu.choices(*tasks) do |task|
            return task
          end
        end
      end

      def run_task(task)
        command = "#{@gradle} #{task}"
        @cli.say "Running <%= color(\"#{command}\", BOLD) %>"
        system command
      end

      def get_deploygate_tasks
        %x(#{@gradle} -q --configure-on-demand tasks --all).
            split(/\n/).
            grep(/uploadDeployGate(?!.*signingConfig).+$/).
            map { |line| line.split(/\s/, 2).first }.
            sort
      end
    end
  end
end
