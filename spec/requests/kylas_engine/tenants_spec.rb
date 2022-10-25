# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KylasEngine::TenantsController, type: :request do
  let(:tenant) { create(:tenant, kylas_tenant_id: 1) }
  let(:user) { create(:user, tenant_id: tenant.id) }
  let(:tenant_user) { create(:user, tenant_id: tenant.id, is_tenant: true) }
  let(:tenant_stub_response) { JSON.parse(file_fixture('kylas_tenant_details.json').read) }

  describe '#edit' do
    subject { get "/kylas-engine/tenants/#{tenant.id}/edit" }

    context 'when user is not signed in' do
      it 'redirects to root path with appropriate alert message' do
        expect(subject).to redirect_to(kylas_engine.new_user_session_path)
        expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
      end
    end

    context 'when user is signed in' do
      context 'when logged in user is not tenant user' do
        it 'redirects to the root path of the application' do
          execute_with_resource_sign_in(user) do
            subject
            expect(response).to redirect_to(Rails.application.routes.url_helpers.root_path)
          end
        end
      end

      context 'when logged in user is tenant user' do
        it 'renders correct template' do
          user.is_tenant = true
          execute_with_resource_sign_in(user) do
            subject
            expect(response).to have_http_status(200)
          end
        end
      end
    end
  end

  describe '#update' do
    def tenant_update_request(params: {})
      patch "/kylas-engine/tenants/#{tenant.id}", params: params
    end

    def stub_fetch_tenant_details_request(request_headers: nil, status: 200, response: {}.to_json)
      headers = {
        'Content-Type' => 'application/json',
        'api-key' => tenant.kylas_api_key
      }
      stub_request(:get, "#{KylasEngine::KYLAS_AUTH_CONFIG[:kylas_host]}/v1/tenants")
        .with(headers: request_headers || headers)
        .to_return(status: status, body: response)
    end

    context 'when user is not signed in' do
      it 'redirects to root path with appropriate alert message' do
        expect(tenant_update_request(params: {})).to redirect_to(kylas_engine.new_user_session_path)
        expect(flash[:alert]).to eq('You need to sign in or sign up before continuing.')
      end
    end

    context 'when user is signed in' do
      context 'when user is not authorized' do
        it 'redirects user to root path with correct message' do
          execute_with_resource_sign_in(user) do
            tenant_update_request(params: {})
          end
          expect(response).to redirect_to(Rails.application.routes.url_helpers.root_path)
          expect(flash[:alert]).to eq('You don\'t have permission to perform action.')
        end
      end

      context 'when user is authorized' do
        context 'when new api key belongs to the same tenant' do
          it 'does update the new api key to the tenant record' do
            api_key = SecureRandom.uuid
            headers = {
              'Content-Type' => 'application/json',
              'api-key' => api_key
            }
            tenant_stub_response['id'] = tenant.kylas_tenant_id.to_i
            stub_fetch_tenant_details_request(request_headers: headers, response: tenant_stub_response.to_json)
            execute_with_resource_sign_in(tenant_user) do
              tenant_update_request(params: { tenant: { kylas_api_key: api_key } })
            end
            expect(tenant.reload.kylas_api_key).to eq(api_key)
          end
        end

        context 'when new api key does not belongs to the same tenant' do
          it 'does not update the new api key to the tenant record' do
            api_key = SecureRandom.uuid
            headers = {
              'Content-Type' => 'application/json',
              'api-key' => api_key
            }
            stub_fetch_tenant_details_request(request_headers: headers, response: tenant_stub_response.to_json)
            execute_with_resource_sign_in(tenant_user) do
              tenant_update_request(params: { tenant: { kylas_api_key: api_key } })
            end
            expect(flash[:danger]).to eq(I18n.t('tenants.invalid_api_key'))
            expect(response.code).to eq('302')
            expect(response).to redirect_to(kylas_engine.edit_tenant_path(tenant))
            expect(tenant.kylas_api_key).to eq(tenant.reload.kylas_api_key)
          end
        end

        context 'when blank api key is passed' do
          it 'does store api key in tenant object' do
            tenant
            execute_with_resource_sign_in(tenant_user) do
              tenant_update_request(params: { tenant: { kylas_api_key: nil } })
            end
            expect(tenant.reload.kylas_api_key).to eq(nil)
          end
        end

        context 'when kylas api key is already present in other tenant' do
          it 'gives error message and redirects to edit tenant path' do
            api_key = SecureRandom.uuid
            create(:tenant, kylas_api_key: api_key)

            execute_with_resource_sign_in(tenant_user) do
              tenant_update_request(params: { tenant: { kylas_api_key: api_key } })
            end
            expect(flash[:danger]).to eq(I18n.t('tenants.invalid_api_key'))
            expect(response.status).to eq(302)
            expect(response).to redirect_to(kylas_engine.edit_tenant_path(tenant))
          end
        end

        context 'when update method returns false' do
          before do
            allow_any_instance_of(KylasEngine::Tenant).to receive(:update).and_return(false)
          end

          it 'does return correct flash message' do
            tenant_stub_response['id'] = tenant.kylas_tenant_id
            stub_fetch_tenant_details_request(response: tenant_stub_response.to_json)
            execute_with_resource_sign_in(tenant_user) do
              tenant_update_request(params: { tenant: { kylas_api_key: tenant.kylas_api_key } })
            end
            expect(flash[:danger]).to eq('Failed to update Kylas API key.')
            expect(response).to redirect_to(kylas_engine.edit_tenant_path(tenant))
          end
        end

        context 'when kylas user id field is nil' do
          it 'does call update_users_and_tenants_details method' do
            tenant_user.kylas_user_id = nil
            api_key = SecureRandom.uuid
            headers = {
              'Content-Type' => 'application/json',
              'api-key' => api_key
            }
            tenant_stub_response['id'] = tenant.kylas_tenant_id.to_i
            stub_fetch_tenant_details_request(request_headers: headers, response: tenant_stub_response.to_json)
            expect_any_instance_of(KylasEngine::User).to receive(:update_users_and_tenants_details).and_return(true)
            execute_with_resource_sign_in(tenant_user) do
              tenant_update_request(params: { tenant: { kylas_api_key: api_key } })
            end
          end
        end
      end
    end
  end
end
