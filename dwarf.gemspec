# -*- encoding: utf-8 -*-
require File.expand_path("../lib/dwarf/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "dwarf"
  s.version     = Dwarf::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alex Redington"]
  s.email       = ["aredington@gmail.com"]
  s.homepage    = "http://github.com/aredington/dwarf"
  s.summary     = "Decision tree learning for ActiveRecord objects"
  s.description = "Dwarf is an implementation of decision tree learning algorithms targeted for use in the Rails 3 console environment for classifying ActiveRecord objects."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "dwarf"

  s.add_dependency "rubytree", ">= 0.8.1"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">= 2.0.1"
  s.add_development_dependency "watchr", ">= 0.7"
  s.add_development_dependency "faker", ">= 0.3.1"
  s.add_development_dependency "fuubar", ">= 0.0.2"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
