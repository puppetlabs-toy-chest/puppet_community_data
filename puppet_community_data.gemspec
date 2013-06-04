# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puppet_community_data/version'

Gem::Specification.new do |spec|
  spec.name          = "puppet_community_data"
  spec.version       = PuppetCommunityData::VERSION
  spec.authors       = ["Hailee Kenney"]
  spec.email         = ["hailee@puppetlabs.com"]
  spec.description   = %q{Gather data and metrics from Puppet Labs open source repositories}
  spec.summary       = %q{Gather data and metrics from Puppet Labs open source repositories}
  spec.homepage      = "https://github.com/hkenney/puppet_community_data"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
