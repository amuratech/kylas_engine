# frozen string literal: true

Rails.application.routes.draw do
  mount KylasEngine::Engine, at: '/kylas-engine'
end
