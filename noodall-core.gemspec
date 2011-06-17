# -*- encoding: utf-8 -*-
require File.expand_path("../lib/noodall/core/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "noodall-core"
  s.version = Noodall::Core::VERSION
  s.platform    = Gem::Platform::RUBY
  
  s.authors = ["Steve England"]
  s.email = ['steve@wearebeef.co.uk']
  s.homepage = "http://github.com/beef/noodall-core"
  s.summary = "Core data objects for Noodall"
  s.description = "Core data objects for Noodall"
  
  s.required_rubygems_version = ">= 1.3.6"
  
  s.add_dependency(%q<mongo_mapper>, ["~> 0.9.0"])
  s.add_dependency(%q<ramdiv-mongo_mapper_acts_as_tree>, ["~> 0.1.1"])
  s.add_dependency(%q<mm-multi-parameter-attributes>, ["~> 0.2.1"])
  s.add_dependency(%q<canable>, ["= 0.1.1"])
  s.add_dependency(%q<mm-versionable>, ["= 0.2.4"])
  s.add_dependency(%q<ruby-stemmer>, [">= 0"])
  
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

