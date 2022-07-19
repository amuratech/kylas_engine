# frozen_string_literal: true

KylasEngine::Engine.routes.draw do
  devise_for :users, class_name: 'KylasEngine::User', module: :devise, controllers: {
    registrations: 'registrations',
    confirmations: 'confirmations'
  }

  resources :tenants, only: %i[edit update]

  get 'dashboard/help', to: 'dashboards#help'

  get 'kylas-auth', to: 'kylas_auth#authenticate'
end
