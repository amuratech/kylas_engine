# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KylasEngine::UserDetails, type: :feature do
  let(:tenant) { create(:tenant) }
  let(:tenant_user) { create(:user, :kylas_tokens, :make_tenant, tenant_id: tenant.id) }

  describe '#get_agent' do
    context 'when agent type is api_key' do
      it 'returns user agent with api key value' do
        service = KylasEngine::KylasUserAgent.new(tenant: tenant, agent_type: 'api_key')
        expect(service.get_agent).to eq(
          "marketplaceAppId: #{KylasEngine::KYLAS_AUTH_CONFIG[:app_id]}, tenantId: #{tenant.id}, apiKey: true"
        )
      end
    end

    context 'when agent type is user' do
      it 'returns user agent with user id' do
        service = KylasEngine::KylasUserAgent.new(tenant: tenant, agent_type: 'user', user: tenant_user)
        expect(service.get_agent).to eq(
          "marketplaceAppId: #{KylasEngine::KYLAS_AUTH_CONFIG[:app_id]}, tenantId: #{tenant.id}, userId: #{tenant_user.id}"
        )
      end
    end
  end
end
