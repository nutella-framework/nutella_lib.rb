# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: nutella_lib 0.4.8 ruby lib

Gem::Specification.new do |s|
  s.name = "nutella_lib"
  s.version = "0.4.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Alessandro Gnoli"]
  s.date = "2015-04-06"
  s.description = "Implements the nutella protocol and exposes it natively to ruby developers"
  s.email = "tebemis@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/nutella_lib.rb",
    "lib/nutella_lib/app_core.rb",
    "lib/nutella_lib/app_log.rb",
    "lib/nutella_lib/app_net.rb",
    "lib/nutella_lib/app_persist.rb",
    "lib/nutella_lib/core.rb",
    "lib/nutella_lib/ext/kernel.rb",
    "lib/nutella_lib/log.rb",
    "lib/nutella_lib/net.rb",
    "lib/nutella_lib/noext.rb",
    "lib/nutella_lib/persist.rb",
    "lib/simple_mqtt_client/simple_mqtt_client.rb",
    "lib/util/json_file_persisted_collection.rb",
    "lib/util/json_file_persisted_hash.rb",
    "lib/util/json_store.rb",
    "lib/util/mongo_persisted_collection.rb",
    "lib/util/mongo_persisted_hash.rb",
    "nutella_lib.gemspec",
    "test/helper.rb",
    "test/test_logger.rb",
    "test/test_nutella_net.rb",
    "test/test_nutella_net_app.rb",
    "test/test_peristence.rb",
    "test/test_simple_mqtt_client.rb"
  ]
  s.homepage = "https://github.com/nutella-framework/nutella_lib.rb"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.3"
  s.summary = "nutella protocol library for ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mqtt>, [">= 0.3", "~> 0.3"])
      s.add_runtime_dependency(%q<ansi>, [">= 1.4", "~> 1.5"])
      s.add_runtime_dependency(%q<mongo>, [">= 2.0.1", "~> 2.0.1"])
      s.add_development_dependency(%q<shoulda>, [">= 3", "~> 3"])
      s.add_development_dependency(%q<minitest>, [">= 5", "~> 5.4"])
      s.add_development_dependency(%q<yard>, [">= 0.8.7", "~> 0.8"])
      s.add_development_dependency(%q<rdoc>, [">= 4.0", "~> 4.0"])
      s.add_development_dependency(%q<bundler>, [">= 1.0", "~> 1.0"])
      s.add_development_dependency(%q<jeweler>, [">= 2.0.1", "~> 2.0.1"])
      s.add_development_dependency(%q<simplecov>, [">= 0", "~> 0"])
    else
      s.add_dependency(%q<mqtt>, [">= 0.3", "~> 0.3"])
      s.add_dependency(%q<ansi>, [">= 1.4", "~> 1.5"])
      s.add_dependency(%q<mongo>, [">= 2.0.1", "~> 2.0.1"])
      s.add_dependency(%q<shoulda>, [">= 3", "~> 3"])
      s.add_dependency(%q<minitest>, [">= 5", "~> 5.4"])
      s.add_dependency(%q<yard>, [">= 0.8.7", "~> 0.8"])
      s.add_dependency(%q<rdoc>, [">= 4.0", "~> 4.0"])
      s.add_dependency(%q<bundler>, [">= 1.0", "~> 1.0"])
      s.add_dependency(%q<jeweler>, [">= 2.0.1", "~> 2.0.1"])
      s.add_dependency(%q<simplecov>, [">= 0", "~> 0"])
    end
  else
    s.add_dependency(%q<mqtt>, [">= 0.3", "~> 0.3"])
    s.add_dependency(%q<ansi>, [">= 1.4", "~> 1.5"])
    s.add_dependency(%q<mongo>, [">= 2.0.1", "~> 2.0.1"])
    s.add_dependency(%q<shoulda>, [">= 3", "~> 3"])
    s.add_dependency(%q<minitest>, [">= 5", "~> 5.4"])
    s.add_dependency(%q<yard>, [">= 0.8.7", "~> 0.8"])
    s.add_dependency(%q<rdoc>, [">= 4.0", "~> 4.0"])
    s.add_dependency(%q<bundler>, [">= 1.0", "~> 1.0"])
    s.add_dependency(%q<jeweler>, [">= 2.0.1", "~> 2.0.1"])
    s.add_dependency(%q<simplecov>, [">= 0", "~> 0"])
  end
end

