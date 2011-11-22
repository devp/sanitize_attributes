# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sanitize_attributes/version"

Gem::Specification.new do |s|
  s.name        = "sanitize_attributes"
  s.version     = SanitizeAttributes::VERSION
  s.authors     = ["Dev Purkayastha", "Paul McMahon"]
  s.email       = ["dev@forgreatjustice.net"]
  s.homepage    = "https://github.com/devp/sanitize_attributes"
  s.summary     = %q{This is a simple plugin for ActiveRecord models to define sanitizable attributes.}
  s.description = %q{This is a simple plugin for ActiveRecord models to define sanitizable attributes. When an object is saved, those attributes will be run through whatever filter you’ve defined. You can define a default filter for all sanitizations.}

  s.rubyforge_project = "sanitize_attributes"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rails', '>= 3.0.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'thoughtbot-shoulda'
  s.add_development_dependency 'mocha'
end
