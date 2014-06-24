# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dgate/version'

Gem::Specification.new do |spec|
  spec.name          = "dgate"
  spec.version       = Dgate::VERSION
  spec.authors       = ["deploygate"]
  spec.email         = ["contact@deploygate.com"]
  spec.description   = "A command-line interface for Deploygate"
  spec.summary       = "Deploygate"
  spec.homepage      = "https://deploygate.com"
  spec.license       = "MIT"

  spec.add_dependency 'json', '1.7.4'
  spec.add_dependency 'httpclient', '2.2.5'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

end
