# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sanjose'

Gem::Specification.new do |s|
  s.name          = "sanjose"
  s.version       = Sanjose::VERSION
  s.authors       = ["Min Kim"]
  s.email         = ["minsikzzang@gmail.com", "minsik.kim@livestation.com"]
  s.summary       = "Send Google Cloud Messages"
  s.description   = "Sanjose is a simple gem for sending Google Cloud Messages"
  s.homepage      = "http://github.com/minsikzzang/sanjose"

  s.add_dependency "commander", "~> 4.1.2"
  s.add_dependency "json", "~> 1.7.3"
  
  s.add_development_dependency "rspec", "~> 0.6.1"
  s.add_development_dependency "rake",  "~> 0.9.2"
  
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
end
