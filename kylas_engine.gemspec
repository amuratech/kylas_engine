$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kylas_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kylas_engine"
  s.version     = KylasEngine::VERSION
  s.authors     = ["shyam-selldo"]
  s.email       = ["shyam.pandav@sell.do"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of KylasEngine."
  s.description = "TODO: Description of KylasEngine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.10"

  s.add_development_dependency "pg"
end
