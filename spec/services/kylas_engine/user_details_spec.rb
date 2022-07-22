# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KylasEngine::UserDetails, type: :feature do
  let(:user) { create(:user, :kylas_tokens, :make_tenant) }
  let(:service) { KylasEngine::UserDetails.new(user: user) }
  let(:user_stub_response) { file_fixture('kylas_user_details.json').read }

  describe '#call' do
    def stub_user_details_request(status: 200, response_body: {}.to_json)
      stub_request(:get, %r{/v1/users/me})
        .with(
          headers: {
            'Authorization' => "Bearer #{user.kylas_access_token}",
            'Content-Type' => 'application/json'
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
          stub_user_details_request(response_body: user_stub_response)
          expect(service.call).to eq({ success: true, data: JSON.parse(user_stub_response) })
        end
      end

      context 'when kylas returns 500 success response' do
        it 'returns empty response with correct logger message' do
          stub_user_details_request(status: 500)
          expect(service.call).to eq({ success: false })
        end
      end
    end
  end
end
