# frozen_string_literal: true

module KylasEngine
  # TODO: Make customizable user class in application

  class Engine < ::Rails::Engine
    isolate_namespace KylasEngine

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
