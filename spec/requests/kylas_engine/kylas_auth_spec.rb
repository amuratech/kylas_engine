# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KylasEngine::KylasAuthController, type: :request do
  let(:user) { create(:user, kylas_access_token: 'fd4e1d45-ee00-449c-833a-a339acbeb2f7:123122:124122') }

  describe '#authenticate' do
    let(:oauth_stub_response) { file_fixture('kylas_oauth_token.json').read }
    let(:user_stub_response) { file_fixture('kylas_user_details.json').read }
    let(:tenant_stub_response) { file_fixture('kylas_tenant_details.json').read }

    let(:error_response) do
      {
        "code": '001002',
        'message': 'Uhoh! We are not able to recognize you. Please hit refresh and try again or contact support if you continue to encounter this error.',
        'fieldErrors': nil
      }.to_json
    end

    def authenticate_request(params: {}, headers: {})
      get '/kylas-engine/kylas-auth', params: params, headers: headers
    end

    context 'when user is not signed in' do
      it 'redirects to root path with appropriate alert message' do
        authenticate_request(headers: { 'ACCEPT' => 'application/json' })
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(
          { error: 'You need to sign in or sign up before continuing.' }.to_json
        )
      end
    end

    context 'when user is signed in' do
      before(:each) { sign_in_resource(user) }
      after(:each) { sign_out_resource(user) }

      context 'when authorization_code is not found in parameters' do
        context 'should not call Kylas Exchange code service' do
          before(:each) { expect(KylasEngine::ExchangeCode).not_to receive(:new) }

          it 'should redirect to root path with alert message' do
            authenticate_request
            expect(response).to redirect_to(Rails.application.routes.url_helpers.root_path)
            expect(flash[:alert]).to eq('Something went wrong!')
          end
        end
      end

      context 'when authorization_code is found in parameters' do
        def stub_oauth_token_request(status: 200, body: {}.to_json)
          stub_request(:post, %r{/oauth/token})
            .with(
              body: {},
              headers: {
                'Authorization' => "Basic #{encoded_credentials}",
                'Content-Type' => 'application/x-www-form-urlencoded'
              }
            )
            .to_return(status: status, body: body)
        end

        context 'calls Kylas Exchange code service' do
          context 'when response is not successfull' do
            before(:each) do
              expect(KylasEngine::ExchangeCode).to receive(:new).and_call_original
              stub_oauth_token_request(status: 404, body: error_response)
            end

            it 'redirects to root path with alert message' do
              authenticate_request(params: { code: 'ySzLAa' })
              expect(response).to redirect_to(Rails.application.routes.url_helpers.root_path)
              expect(flash[:alert]).to eq('We are facing problem while installing app! Please try again')
            end
          end

          context 'when response is successfull' do
            context 'calls Kylas ExchangeCode/UserDetails/TenantDetails service' do
              before(:each) do
                stub_oauth_token_request(body: oauth_stub_response)

                stub_request(:get, %r{/v1/users/me})
                  .with(
                    headers: {
                      'Content-Type' => 'application/json',
                      'Authorization' => "Bearer #{user.kylas_access_token}"
                    }
                  )
                  .to_return(status: 200, body: user_stub_response)

                stub_request(:get, %r{/v1/tenants})
                  .with(
                    headers: {
                      'Content-Type' => 'application/json',
                      'Authorization' => "Bearer #{user.kylas_access_token}"
                    }
                  )
                  .to_return(status: 200, body: tenant_stub_response)
              end

              it 'update the user with tokens' do
                authenticate_request(params: { code: 'ySzLAa' })
                expect(response).to redirect_to(Rails.application.routes.url_helpers.root_path)
                expect(flash[:success]).to eq('Application installed successfully.')

                parsed_oauth_response = JSON.parse(oauth_stub_response)

                expect(user.kylas_access_token).to eq(parsed_oauth_response['access_token'])
                expect(user.kylas_refresh_token).to eq(parsed_oauth_response['refresh_token'])
                expect(user.kylas_access_token_expires_at).to eq(Time.at(DateTime.now.to_i + parsed_oauth_response['expires_in']))
                expect(user.kylas_user_id).to eq(JSON.parse(user_stub_response)['id'])
                expect(user.tenant.kylas_tenant_id).to eq(JSON.parse(tenant_stub_response)['id'])
              end
            end
          end
        end
      end
    end
  end

  describe '#auth_request?' do
    context 'when request url contains kylas-auth' do
      it 'returns true' do
        expect(
          KylasEngine::KylasAuthController.new.send(:auth_request?, 'http://localhost:3000/kylas-engine/kylas-auth?code=abcdef')
        ).to eq(true)
      end
    end

    context 'when request url did not contains kylas-auth' do
      it 'returns false' do
        expect(
          KylasEngine::KylasAuthController.new.send(:auth_request?, 'http://localhost:3000/kylas-engine?code=abcdef')
        ).to eq(false)
      end
    end

    context 'when nil url is passed to method' do
      it 'returns nil' do
        expect(
          KylasEngine::KylasAuthController.new.send(:auth_request?, nil)
        ).to eq(nil)
      end
    end
  end
end
