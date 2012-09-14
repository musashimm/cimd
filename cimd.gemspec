# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cimd/version"

Gem::Specification.new do |s|
  s.name        = "cimd"
  s.version     = CIMD::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Wojciech Todryk"]
  s.email       = ["wojciech@todryk.pl"]
  s.homepage    = "http://todryk.pl/cimd"
  s.summary     = %q{Utils for CIMD protocol}
  s.description = %q{Utils for CIMD protocol}

  s.rubyforge_project = "cimd"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency "eventmachine", [">= 0.12"]
  s.add_dependency "thor", [">= 0"]
  s.add_development_dependency "rspec", [">= 0"]
  s.add_development_dependency "rake", [">= 0"]
  s.add_development_dependency "guard", [">= 1.3"]
  s.add_development_dependency "guard-rspec", [">= 1.2"]
  s.add_development_dependency "rb-inotify", [">= 0.8.8"]

end
