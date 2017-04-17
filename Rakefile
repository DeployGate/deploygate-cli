# For Bundler.with_clean_env
require 'bundler/setup'

PACKAGE_NAME = 'deploygate'
VERSION = '0.5.5'
TRAVELING_RUBY_VERSION = '20150210-2.2.0'

# native extensions
JSON_VERSION = '1.8.2'
UNF_EXT_VERSION = '0.0.6'

desc 'Package your app'
task package: %w(package:linux:x86 package:linux:x86_64 package:osx)

namespace :package do
  namespace :linux do
    desc 'Package your app for Linux x86_64 on Docker'
    task x86_64_docker: [] do
      create_package_on_docker('linux:x86_64')
    end

    desc 'Package your app for Linux x86_64'
    task x86_64: [:bundle_install,
                  "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz",
                  "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-json-#{JSON_VERSION}.tar.gz",
                  "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-unf_ext-#{UNF_EXT_VERSION}.tar.gz"
    ] do
      create_package('linux-x86_64')
    end
  end

  desc 'Package your app for OS X'
  task osx: [:bundle_install,
             "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz",
             "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-json-#{JSON_VERSION}.tar.gz",
             "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-unf_ext-#{UNF_EXT_VERSION}.tar.gz"
  ] do
    create_package('osx')
  end

  desc 'Install gems to local directory'
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.2\./
      abort "You can only 'bundle install' using Ruby 2.1, because that's what Traveling Ruby uses."
    end
    sh 'rm -rf packaging/tmp'
    sh 'mkdir packaging/tmp'
    sh 'mkdir -p packaging/tmp/lib/deploygate'
    sh 'cp -rf lib/deploygate/version.rb packaging/tmp/lib/deploygate/'
    sh 'cp Gemfile Gemfile.lock deploygate.gemspec packaging/tmp/'
    Bundler.with_clean_env do
      sh 'cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development'
    end
    sh 'rm -rf packaging/tmp'
    sh 'rm -f packaging/vendor/*/*/cache/*'
    sh 'rm -rf packaging/vendor/ruby/*/extensions'
    sh "find packaging/vendor/ruby/*/gems -name '*.so' | xargs rm -f"
    sh "find packaging/vendor/ruby/*/gems -name '*.bundle' | xargs rm -f"
    sh "find packaging/vendor/ruby/*/gems -name '*.o' | xargs rm -f"
  end
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  download_runtime('linux-x86_64')
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  download_runtime('osx')
end


file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-json-#{JSON_VERSION}.tar.gz" do
  download_native_extension('linux-x86_64', "json-#{JSON_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-json-#{JSON_VERSION}.tar.gz" do
  download_native_extension('osx', "json-#{JSON_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-unf_ext-#{UNF_EXT_VERSION}.tar.gz" do
  download_native_extension('linux-x86_64', "unf_ext-#{UNF_EXT_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-unf_ext-#{UNF_EXT_VERSION}.tar.gz" do
  download_native_extension('osx', "unf_ext-#{UNF_EXT_VERSION}")
end

def create_package_on_docker(target)
  sh 'docker pull henteko/ruby:2.2.0'
  sh "docker run -v `pwd`:/deploygate-cli --rm -ti henteko/ruby:2.2.0 /bin/bash -ci 'cd /deploygate-cli && bundle install && rake package:#{target}'"
end

def create_package(target)
  package_dir = "#{PACKAGE_NAME}-#{VERSION}-#{target}"
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"
  sh "cp -rf lib #{package_dir}/lib/app/"
  sh "cp -rf bin #{package_dir}/lib/app/"
  sh "cp -rf config #{package_dir}/lib/app/"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"
  sh "cp packaging/wrapper.sh #{package_dir}/dg"
  sh "cp packaging/install.sh #{package_dir}/"
  sh "cp packaging/bundle-env #{package_dir}/"
  sh "cp -pR packaging/vendor #{package_dir}/lib/"
  sh "cp Gemfile Gemfile.lock deploygate.gemspec #{package_dir}/lib/vendor/"
  sh "mkdir -p #{package_dir}/lib/vendor/lib/deploygate"
  sh "cp -rf lib/deploygate/version.rb #{package_dir}/lib/vendor/lib/deploygate/"
  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"

  # update bundler
  if target == 'osx'
    sh "mv #{package_dir}/lib/ruby/bin/bundler #{package_dir}/lib/ruby/bin/_bundler"
    sh "mv #{package_dir}/lib/ruby/bin/bundle #{package_dir}/lib/ruby/bin/_bundle"
    sh "#{package_dir}/lib/ruby/bin/gem install bundler --no-ri --no-rdoc"
    sh "mv #{package_dir}/lib/ruby/bin/_bundler #{package_dir}/lib/ruby/bin/bundler"
    sh "mv #{package_dir}/lib/ruby/bin/_bundle #{package_dir}/lib/ruby/bin/bundle"
  else
    sh "#{package_dir}/lib/ruby/bin/gem install bundler --no-ri --no-rdoc"
    sh "rm #{package_dir}/lib/ruby/bin/bundler"
    sh "rm #{package_dir}/lib/ruby/bin/bundle"
  end

  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-json-#{JSON_VERSION}.tar.gz " +
         "-C #{package_dir}/lib/vendor/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-unf_ext-#{UNF_EXT_VERSION}.tar.gz " +
         "-C #{package_dir}/lib/vendor/ruby"
  unless ENV['DIR_ONLY']
    sh "zip -r #{package_dir}.zip #{package_dir}"
    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(target)
  sh 'cd packaging && curl -L -O --fail ' +
         "https://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end

def download_native_extension(target, gem_name_and_version)
  sh "curl -L --fail -o packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz " +
         "https://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{target}/#{gem_name_and_version}.tar.gz"
end
