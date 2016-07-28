# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deploygate/version'

Gem::Specification.new do |spec|
  spec.name          = "deploygate"
  spec.version       = DeployGate::VERSION
  spec.authors       = ["deploygate"]
  spec.email         = ["contact@deploygate.com"]
  spec.description   = %q{You can control to DeployGate in your terminal}
  spec.summary       = %q{A command-line interface for DeployGate}
  spec.homepage      = "https://deploygate.com"
  spec.license       = "Apache-2.0"
  spec.post_install_message = <<"POST_INSTALL_MESSAGE"

dg installed! To get started fast:

  $ dg deploy

POST_INSTALL_MESSAGE

  spec.add_dependency 'json', '~> 1.8.2'
  spec.add_dependency 'httpclient', '~> 2.2.5'
  spec.add_dependency 'commander', '~> 4.3.5'
  spec.add_dependency 'plist', '~> 3.1.0'
  spec.add_dependency 'xcodeproj', '~> 0.28.2'
  spec.add_dependency 'github_issue_request', '~> 0.0.2'
  spec.add_dependency 'highline', '~> 1.7.8'
  spec.add_dependency 'uuid', '~> 2.3.8'
  spec.add_dependency 'gem_update_checker', '~> 0.2.0'
  spec.add_dependency 'activesupport', '~> 4.2.4'
  spec.add_dependency 'i18n'
  spec.add_dependency 'launchy'
  spec.add_dependency 'locale'
  spec.add_dependency 'net-ping'
  spec.add_dependency 'socket.io-client-simple'

  # ios build
  spec.add_dependency 'gym', '~> 1.7.0'
  spec.add_dependency 'spaceship', '~> 0.28.0'
  spec.add_dependency 'sigh', '~> 1.8.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.3.0"
  spec.add_development_dependency "webmock", "~> 1.21.0"
  spec.add_development_dependency "i18n-tasks"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

end
