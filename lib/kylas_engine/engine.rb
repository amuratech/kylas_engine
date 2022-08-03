# frozen_string_literal: true

module KylasEngine
  # TODO: Make customizable user class in application

  class Engine < ::Rails::Engine
    isolate_namespace KylasEngine

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories/kylas_engine'
    end

    config.assets.precompile += %w[kylas_engine/application.css kylas_engine/application.js]
  end
end
