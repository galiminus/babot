Gem::Specification.new do |s|
  s.name        = 'babot'
  s.version     = '0.2.0'
  s.date        = '2013-09-08'
  s.summary     = "Babot"
  s.description = "A simple tool to manage Twitter bots"
  s.authors     = ["Victor Goya"]
  s.email       = 'goya.victor@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/phorque/babot'
  s.license     = 'MIT'

  s.require_path = 'lib'
  s.add_dependency "twitter"
  s.add_dependency "git"
  s.add_dependency "activesupport"
  s.add_dependency "whenever"
  s.add_dependency "rake"
  s.add_dependency "boson"
  s.add_dependency "capistrano"
  s.add_dependency "capistrano-af83"
  s.add_dependency "rvm-capistrano"

  s.executables  = ['babot']
end
