# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'KylasEngine::User' do
    sequence(:email) { |n| "user-email-#{n}@sample.com" }
    sequence(:name) { |n| "user-name-#{n}" }
    sequence(:password) { |n| "Password-#{n}" }
    active { true }
    kylas_user_id { rand(10**4) }
    tenant

    trait :make_tenant do
      is_tenant { true }
    end

    after(:create, &:confirm)

    trait :kylas_tokens do
      kylas_access_token { SecureRandom.uuid }
      kylas_refresh_token { SecureRandom.uuid }
      kylas_access_token_expires_at { 1.hour.from_now }
    end
  end
end
