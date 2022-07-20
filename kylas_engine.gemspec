# frozen_string_literal: true

require_relative 'lib/kylas_engine/version'

Gem::Specification.new do |spec|
  spec.name        = 'kylas_engine'
  spec.version     = KylasEngine::VERSION
  spec.authors     = ['Kylas']
  spec.email       = ['no-reply@kylas.io']
  # spec.homepage    = "https://www.testurl.com"
  spec.summary     = 'Summary of KylasEngine.'
  spec.description = 'Description of KylasEngine.'
  spec.license     = 'MIT'
  spec.required_ruby_version = '~> 3.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/amuratech/kylas_engine'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'devise'
  spec.add_dependency 'pg'
  spec.add_dependency 'rails', '>= 7.0.2.3'
  spec.add_dependency 'sassc-rails'
  spec.add_dependency 'sprockets-rails'

  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'rspec-rails', '~> 5.0.0'
end
