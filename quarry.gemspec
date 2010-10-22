# -*- encoding: utf-8 -*-
require File.expand_path("../lib/quarry/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "quarry"
  s.version     = Quarry::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Redington"]
  s.email       = ["aredington@gmail.com"]
  s.homepage    = "http://github.com/aredington/quarry"
  s.summary     = "C4.5 for ActiveRecord objects"
  s.description = "Quarry is an implementation of the C4.5 algorithm targeted for use in the Rails 3 console environment for classifying ActiveRecord objects."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "quarry"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
