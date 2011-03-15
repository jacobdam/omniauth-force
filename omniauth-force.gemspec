# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth_force/version"

Gem::Specification.new do |s|
  s.name        = "omniauth-force"
  s.version     = OmniauthForce::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jacob Dam"]
  s.email       = ["ngocphuc@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Force.com strategies for OmniAuth.}
  s.description = %q{Force.com strategies for OmniAuth.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency  'oa-oauth',   '~> 0.1.6'
  s.add_dependency  'multi_json', '~> 0.0.2'
  s.add_dependency  'oauth2',     '~> 0.1.1'
end
