require 'rake'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
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
    gem.add_dependency('mongo_mapper', '0.8.4')
    gem.add_dependency('ramdiv-mongo_mapper_acts_as_tree', '0.1.1')
    gem.add_dependency('canable', '0.1.1')
    gem.add_dependency('ruby-stemmer')
    gem.add_development_dependency "rspec", ">= 2.0.0.beta.22"
    gem.add_development_dependency "database_cleaner", ">= 0.5.2"
    gem.add_development_dependency "factory_girl", ">= 1.3.2"
    gem.add_development_dependency "faker", ">= 0.3.1"
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

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "noodall-core #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
