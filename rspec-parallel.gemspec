Gem::Specification.new do |s|
  s.name        = 'prspec'
  s.version     = '0.2.5'
  s.date        = '2014-03-15'
  s.summary     = "Parallel rspec execution"
  s.description = "Allows for simple parallel execution of rspec tests."
  s.authors     = ["Jason Holt Smith"]
  s.email       = 'bicarbon8@gmail.com'
  s.homepage    = 'https://github.com/bicarbon8/prspec.git'
  s.license     = 'MIT'
  s.add_runtime_dependency "log4r", "~> 1.1", ">=1.1.10"
  s.add_runtime_dependency "parallel", "~> 1.0", ">=1.0.0"
  s.add_runtime_dependency "rspec", "~> 2.14", ">=2.14.1"
  s.files        = ['bin/prspec', 'lib/prspec.rb']
  s.bindir       = 'bin'   
  s.executables  = ['prspec']
end