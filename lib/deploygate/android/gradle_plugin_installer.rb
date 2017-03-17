module DeployGate
  module Android
    class GradlePluginInstaller
      MAVEN_METADATA_URL = 'https://jcenter.bintray.com/com/deploygate/gradle/maven-metadata.xml'

      def initialize
        @cli = HighLine.new
      end

      def install
        patch = create_patch
        print_diff patch
        if @cli.agree("<%= color('These lines will be added to activate the plugin.', BOLD) %> Apply changes? ") {|q| q.default = 'y'}
          apply patch
        end
      end

      def create_patch
        create_root_patch + create_projects_patch
      end

      def create_root_patch
        make_diff 'build.gradle',
                  /classpath\s*['"]com\.android\.tools\.build:gradle:/,
                  "classpath 'com.deploygate:gradle:#{recent_plugin_version}'"
      end

      def recent_plugin_version
        @plugin_version ||= fetch_recent_plugin_version
      end

      def fetch_recent_plugin_version
        open(MAVEN_METADATA_URL) do |io|
          REXML::Document.new(io).elements['metadata/versioning/release'].text
        end
      end

      def create_projects_patch
        files = find_project_scripts
        files.map do |file|
          make_diff file,
                    /apply plugin:\s*["'](android|com\.android\.application)["']/,
                    "apply plugin: 'deploygate'"
        end.join "\n"
      end

      def find_project_scripts
        %x(grep -REl --include build.gradle "apply plugin:[ ]*[\\"'](android|com.android.application)[\\"']" .).
            split(/\n/)
      end

      def make_diff(file, match, insert)
        tmpfile = Tempfile.open(%w(build .gradle))
        File.readlines(file).each do |line|
          tmpfile.print line
          if (md = line.match(match))
            tmpfile.puts "#{' '*md.begin(0)}#{insert}"
          end
        end
        tmpfile.close
        %x(diff -u "#{file}" "#{tmpfile.path}")
      end

      def print_diff(patch)
        puts
        patch.each_line do |line|
          line.chomp!
          if line.match(/^(\+\+\+|---) /)
            puts @cli.color(line, HighLine::BOLD)
          elsif line.match(/^@@.+@@$/)
            puts @cli.color(line, HighLine::CYAN)
          elsif line.match(/^\+/)
            puts @cli.color(line, HighLine::GREEN)
          elsif line.match(/^\-/)
            puts @cli.color(line, HighLine::RED)
          else
            puts line
          end
        end
        puts
      end

      def apply(patch)
        Open3.popen3('patch -p0') do |stdin, stdout, stderr, wait_thr|
          stdin.puts patch
          stdin.close_write
          out = stdout.read
          error = stderr.read
          if !error.empty?
            print out
            print @cli.color(error, HighLine::RED)
            false
          else
            print @cli.color(out, HighLine::GREEN)
            true
          end
        end
      end
    end
  end
end
