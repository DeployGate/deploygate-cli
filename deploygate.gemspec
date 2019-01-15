# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deploygate/version'

Gem::Specification.new do |spec|
  spec.name          = 'deploygate'
  spec.version       = DeployGate::VERSION
  spec.authors       = ['deploygate']
  spec.email         = ['contact@deploygate.com']
  spec.description   = %q{You can control to DeployGate in your terminal}
  spec.summary       = %q{A command-line interface for DeployGate}
  spec.homepage      = 'https://deploygate.com'
  spec.license       = 'Apache-2.0'
  spec.post_install_message = <<"POST_INSTALL_MESSAGE"

dg installed! To get started fast:

  $ dg deploy

POST_INSTALL_MESSAGE

  spec.add_runtime_dependency 'json', '~> 1.8'
  spec.add_runtime_dependency 'httpclient', '~> 2.8'
  spec.add_runtime_dependency 'commander', '~> 4.4'
  spec.add_runtime_dependency 'plist', '~> 3.1'
  spec.add_runtime_dependency 'xcodeproj', '~> 1.7'
  spec.add_runtime_dependency 'highline', '~> 1.7'
  spec.add_runtime_dependency 'uuid', '~> 2.3'
  spec.add_runtime_dependency 'gem_update_checker', '~> 0.2'
  spec.add_runtime_dependency 'activesupport', '~> 4.2'
  spec.add_runtime_dependency 'i18n', '~> 0.7'
  spec.add_runtime_dependency 'launchy', '~> 2.4'
  spec.add_runtime_dependency 'locale', '~> 2.1'
  spec.add_runtime_dependency 'net-ping', '~> 2.0'
  spec.add_runtime_dependency 'socket.io-client-simple', '~> 1.2'
  spec.add_runtime_dependency 'workers', '~> 0.6'
  spec.add_runtime_dependency 'sentry-raven', '~> 2.8'

  # ios build
  spec.add_runtime_dependency 'fastlane', '~> 2.57.2'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_development_dependency 'i18n-tasks', '~> 0.9'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

end
