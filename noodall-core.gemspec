# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{noodall-core}
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steve England"]
  s.date = %q{2011-02-09}
  s.description = %q{Core data objects for Noodall}
  s.email = %q{steve@wearebeef.co.uk}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/noodall-core.rb",
     "lib/noodall/component.rb",
     "lib/noodall/global_update_time.rb",
     "lib/noodall/indexer.rb",
     "lib/noodall/node.rb",
     "lib/noodall/permalink.rb",
     "lib/noodall/search.rb",
     "lib/noodall/site.rb",
     "lib/noodall/tagging.rb",
     "noodall-core.gemspec",
     "spec/component_spec.rb",
     "spec/factories/component.rb",
     "spec/factories/node.rb",
     "spec/node_spec.rb",
     "spec/site_map_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/beef/noodall-core}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Core data objects for Noodall}
  s.test_files = [
    "spec/node_spec.rb",
     "spec/component_spec.rb",
     "spec/spec_helper.rb",
     "spec/factories/node.rb",
     "spec/factories/component.rb",
     "spec/site_map_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongo_mapper>, ["~> 0.8.6"])
      s.add_runtime_dependency(%q<ramdiv-mongo_mapper_acts_as_tree>, ["~> 0.1.1"])
      s.add_runtime_dependency(%q<mm-multi-parameter-attributes>, ["~> 0.1.1"])
      s.add_runtime_dependency(%q<canable>, ["= 0.1.1"])
      s.add_runtime_dependency(%q<ruby-stemmer>, [">= 0"])
    else
      s.add_dependency(%q<mongo_mapper>, ["~> 0.8.6"])
      s.add_dependency(%q<ramdiv-mongo_mapper_acts_as_tree>, ["~> 0.1.1"])
      s.add_dependency(%q<mm-multi-parameter-attributes>, ["~> 0.1.1"])
      s.add_dependency(%q<canable>, ["= 0.1.1"])
      s.add_dependency(%q<ruby-stemmer>, [">= 0"])
    end
  else
    s.add_dependency(%q<mongo_mapper>, ["~> 0.8.6"])
    s.add_dependency(%q<ramdiv-mongo_mapper_acts_as_tree>, ["~> 0.1.1"])
    s.add_dependency(%q<mm-multi-parameter-attributes>, ["~> 0.1.1"])
    s.add_dependency(%q<canable>, ["= 0.1.1"])
    s.add_dependency(%q<ruby-stemmer>, [">= 0"])
  end
end

