# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "couchdb-utils/version"

Gem::Specification.new do |s|
  s.name        = "couchdb-utils"
  s.version     = Couchdb::Utils::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Aaron Hamid & Michal Kuklis"]
  s.email       = ["aaron@incandescentsoftware.com, michal@incandescentsoftware.com"]
  s.homepage    = "https://rubygems.org/gems/couchdb-utils"
  s.summary     = %q{couchdb utils}
  s.description = %q{couchdb utils for new database provisioning}

  s.add_dependency('json')
  s.add_dependency('uuid')
  s.add_dependency('rest-client')

  s.rubyforge_project = "couchdb-utils"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
