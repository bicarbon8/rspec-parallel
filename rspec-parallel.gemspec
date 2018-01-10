# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/parallel/version"

Gem::Specification.new do |s|
  s.name        = 'rspec-parallel'
  s.version     = RSpec::Parallel::Version::STRING
  s.date        = '2018-01-10'
  s.summary     = "Parallel rspec execution gem"
  s.description = "Bolt-on gem allowing for parallel execution of examples using rspec's framework"
  s.authors     = ["Jason Holt Smith"]
  s.email       = 'bicarbon8@gmail.com'
  s.homepage    = 'https://github.com/bicarbon8/rspec-parallel.git'
  s.license     = 'MIT'
  s.bindir       = 'bin'
  s.files        = `git ls-files -- lib/*`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_path = "lib"
  if RSpec::Parallel::Version::STRING =~ /[a-zA-Z]+/
    # rspec-support is locked to our version when running pre,rc etc
    s.add_runtime_dependency "rspec", "= #{RSpec::Parallel::Version::STRING}"
  else
    # rspec-support must otherwise match our major/minor version
    s.add_runtime_dependency "rspec", "~> #{RSpec::Parallel::Version::STRING.split('.')[0..1].concat(['0']).join('.')}"
  end
end
