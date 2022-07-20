# frozen_string_literal: true

FactoryBot.define do
  factory :tenant, class: 'KylasEngine::Tenant' do
    kylas_api_key { SecureRandom.uuid }
    webhook_api_key { SecureRandom.uuid }
    kylas_tenant_id { rand(10**4) }
    timezone { 'Asia/Calcutta' }
  end
end
