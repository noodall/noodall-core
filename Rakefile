require "bundler"
Bundler.setup(:default, :development)
require "rspec/core/rake_task"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "noodall-core"
    gem.summary = %Q{Core data objects for Noodall}
    gem.description = %Q{Core data objects for Noodall}
    gem.email = "steve@wearebeef.co.uk"
    gem.homepage = "http://github.com/beef/noodall-core"
    gem.authors = ["Steve England"]
    gem.add_dependency('mongo_mapper', '~> 0.8.6')
    gem.add_dependency('ramdiv-mongo_mapper_acts_as_tree', '~> 0.1.1')
    gem.add_dependency('mm-multi-parameter-attributes', '~> 0.1.1')
    gem.add_dependency('canable', '0.1.1')
    gem.add_dependency('ruby-stemmer')

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec


