# frozen string literal: true

Rails.application.routes.draw do
  root to: 'application#index'

  mount KylasEngine::Engine, at: '/kylas-engine'
end
