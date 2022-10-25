# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KylasEngine::TenantDetails, type: :feature do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, :make_tenant, :kylas_tokens, tenant_id: tenant.id) }
  let(:service) { KylasEngine::TenantDetails.new(user: user) }
  let(:tenant_stub_response) { file_fixture('kylas_tenant_details.json').read }

  def stub_fetch_tenant_request(status: 200, response_body: {}.to_json)
    stub_request(:get, %r{/v1/tenants})
      .with(
        headers: {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{user.kylas_access_token}"
        }
      )
      .to_return(status: status, body: response_body)
  end

  describe '#call' do
    context 'when access token is nil' do
      it 'returns success false with empty response' do
        expect_any_instance_of(KylasEngine::User).to receive(:fetch_access_token).and_return(nil)
        expect(service.call).to eq({ success: false })
      end
    end

    context 'when kylas returns 200 success response' do
      it 'returns tenant details' do
        stub_fetch_tenant_request(response_body: tenant_stub_response)
        expect(service.call).to eq({ success: true, data: JSON.parse(tenant_stub_response) })
      end
    end

    context 'when kylas returns 500 success response' do
      it 'returns empty response with correct logger message' do
        stub_fetch_tenant_request(status: 500)
        expect(service.call).to eq({ success: false })
      end
    end
  end

  describe '#fetch_details_using_api_key' do
    def stub_fetch_tenant_details_request(status: 200, response: {}.to_json)
      headers = {
        'Content-Type' => 'application/json',
        'api-key' => tenant.kylas_api_key
      }
      stub_request(:get, "#{KylasEngine::KYLAS_AUTH_CONFIG[:kylas_host]}/v1/tenants")
        .with(headers: headers)
        .to_return(status: status, body: response)
    end

    context 'when api key is not present' do
      it 'returns success false message' do
        expect(service.fetch_details_using_api_key(new_kylas_api_key: nil)).to eq(
          { success: false, message: I18n.t('tenants.blank_api_key') }
        )
      end
    end

    context 'when api key is present' do
      context 'when API returns 200 response code' do
        it 'returns success true response with data' do
          stub_fetch_tenant_details_request(response: tenant_stub_response)
          expect(service.fetch_details_using_api_key(new_kylas_api_key: tenant.kylas_api_key)).to eq(
            { success: true, data: JSON.parse(tenant_stub_response) }
          )
        end
      end

      context 'when API returns 400 response code' do
        it 'returns success false response with correct error message' do
          response = { error_code: '101', message: 'Invalid API key' }.to_json
          stub_fetch_tenant_details_request(status: 400, response: response)
          expect(service.fetch_details_using_api_key(new_kylas_api_key: tenant.kylas_api_key)).to eq(
            { success: false, message: 'Invalid API key' }
          )
        end
      end

      context 'when API returns 500 response code' do
        it 'returns success false response with correct error message' do
          stub_fetch_tenant_details_request(status: 500)
          expect(service.fetch_details_using_api_key(new_kylas_api_key: tenant.kylas_api_key)).to eq(
            { success: false, message: I18n.t('something_went_wrong') }
          )
        end
      end
    end
  end
end
