# frozen_string_literal: true

require 'rails_helper'

module KylasEngine
  RSpec.describe Tenant, type: :model do
    let(:tenant) { create(:tenant) }

    describe '#associations' do
      it 'has many users' do
        tenant_users = Tenant.reflect_on_association(:users)
        expect(tenant_users.macro).to eq(:has_many)
      end
    end

    describe '#callbacks' do
      describe '#generate_webhook_api_key' do
        it 'should call the callback action' do
          expect_any_instance_of(Tenant).to receive(:generate_webhook_api_key).and_call_original
          expect(tenant.webhook_api_key).to be_present
        end

        it 'when webhook api key is blank' do
          tenant.update(webhook_api_key: nil)
          expect(tenant.webhook_api_key).not_to be_nil
        end
      end
    end
  end
end
