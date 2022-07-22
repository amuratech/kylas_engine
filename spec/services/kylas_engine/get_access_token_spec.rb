# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KylasEngine::GetAccessToken, type: :feature do
  let(:service) { KylasEngine::GetAccessToken.new(kylas_refresh_token: 'a4fce1fb-4675-4d4a-8dfe-6dd9fccb8e51') }
  let(:access_token_response) { file_fixture('kylas_oauth_token.json').read }

  def stub_fetch_access_token_request(status: 200, request_body: {}.to_json, response_body: {}.to_json)
    stub_request(:post, %r{/oauth/token})
      .with(
        body: request_body,
        headers: {
          'Authorization' => "Basic #{encoded_credentials}",
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      )
      .to_return(status: status, body: response_body)
  end

  def payload
    { 'grant_type' => 'refresh_token', 'refresh_token' => 'a4fce1fb-4675-4d4a-8dfe-6dd9fccb8e51' }
  end

  describe '#call' do
    context 'when refresh code is blank' do
      it 'does returns empty response with correct message' do
        service = KylasEngine::GetAccessToken.new(kylas_refresh_token: nil)
        expect(service.call).to eq({ success: false })
      end
    end

    context 'when kylas service returns 200 success response' do
      it 'does respond access token and refresh token' do
        stub_fetch_access_token_request(request_body: payload, response_body: access_token_response)
        res = JSON.parse(access_token_response)
        expect(service.call).to eq({
                                     success: true,
                                     access_token: res['access_token'],
                                     refresh_token: res['refresh_token'],
                                     expires_in: res['expires_in'].to_i
                                   })
      end
    end

    context 'when kylas service returns 500 success response' do
      it 'returns empty response with correct logger messages' do
        expect(Rails.logger).to receive(:error).twice
        stub_fetch_access_token_request(status: 500, request_body: payload)
        expect(service.call).to eq({ success: false })
      end
    end
  end
end
