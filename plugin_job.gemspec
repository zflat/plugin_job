# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plugin_job/version'

Gem::Specification.new do |spec|
  spec.name          = "plugin_job"
  spec.version       = PluginJob::VERSION
  spec.authors       = ["William Wedler"]
  spec.email         = ["wwedler@riseup.net"]
  spec.description   = %q{Framework for running scripts in a plugin fashion}
  spec.summary       = %q{PluginJob can be used to build an application that accepts job requests and processes those requests based on workers that are added to the application.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency(%q<rspec>, [">= 1.3.0"])
  spec.add_development_dependency(%q<eventmachine>, [">= 1.0.3"])
  spec.add_development_dependency(%q<childprocess>, [">= 0.3.9"])
  spec.add_development_dependency(%q<log4r>, ["~>1.1.10"])
  spec.add_development_dependency(%q<i18n>, ["~>0.6.4"])
  spec.add_development_dependency(%q<state_machine>, ["~>1.2.0"])
  spec.add_development_dependency("qtbindings")

  spec.add_dependency "bundler", "~> 1.3"
  spec.add_dependency(%q<eventmachine>, [">= 1.0.3"])
  spec.add_dependency(%q<log4r>, ["~>1.1.10"])
  spec.add_dependency(%q<i18n>, ["~>0.6.4"])
  spec.add_dependency(%q<state_machine>, ["~>1.2.0"])
  spec.add_dependency("qtbindings")
end
