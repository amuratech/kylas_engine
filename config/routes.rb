# frozen_string_literal: true

KylasEngine::Engine.routes.draw do
  devise_for :users, class_name: 'KylasEngine::User', module: :devise, controllers: {
    registrations: 'registrations',
    confirmations: 'confirmations'
  }

  devise_scope :user do
    root 'devise/sessions#new'
  end

  resources :tenants, only: %i[edit update]
end
