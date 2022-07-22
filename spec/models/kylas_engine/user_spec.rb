# frozen_string_literal: true

require 'rails_helper'

module KylasEngine
  RSpec.describe User, type: :model do
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, :make_tenant, :kylas_tokens, tenant_id: tenant.id) }
    let(:user_stub_response) { file_fixture('kylas_user_details.json').read }
    let(:tenant_stub_response) { file_fixture('kylas_tenant_details.json').read }

    def stub_user_details_request(status: 200, body: {}.to_json)
      stub_request(:get, %r{/v1/users/me})
        .with(
          headers: {
            'Authorization' => "Bearer #{user.kylas_access_token}",
            'Content-Type' => 'application/json'
          }
        )
        .to_return(status: status, body: body)
    end

    def stub_tenant_details_request(status: 200, body: {}.to_json)
      stub_request(:get, %r{/v1/tenants})
        .with(
          headers: {
            'Authorization' => "Bearer #{user.kylas_access_token}",
            'Content-Type' => 'application/json'
          }
        )
        .to_return(status: status, body: body)
    end

    describe 'validations' do
      it 'validates presence of email, name' do
        new_user = User.new
        new_user.validate
        expect(new_user.errors.messages).to eq(
          {
            email: ["can't be blank"], password: ["can't be blank"], tenant: ['must exist'],
            name: ["can't be blank"]
          }
        )
      end

      it 'validates uniqueness of email' do
        new_user = User.new(email: user.email)
        new_user.validate
        expect(new_user.errors.messages[:email]).to eq(['has already been taken'])
      end

      it 'validates kylas_user_id uniqueness' do
        new_user = User.new(kylas_user_id: user.kylas_user_id)
        new_user.validate
        expect(new_user.errors.messages[:kylas_user_id]).to eq(['has already been taken'])
      end

      it 'allows blank value in kylas user id' do
        user = create(:user, kylas_user_id: nil)
        expect(user.valid?).to eq(true)
      end
    end

    describe 'associations' do
      it 'belongs_to tenant' do
        user_tenant = User.reflect_on_association(:tenant)
        expect(user_tenant.macro).to eq(:belongs_to)
      end
    end

    describe 'callbacks' do
      it 'calls the callback action' do
        expect_any_instance_of(User).to receive(:create_tenant!)
        user
      end
    end

    describe '#access_token_valid?' do
      it 'returns false when access_token is expired' do
        user.update(kylas_access_token_expires_at: 2.hours.ago)

        expect(user.access_token_valid?).to be(false)
      end

      it 'returns true when access_token is not expired' do
        expect(user.access_token_valid?).to be(true)
      end
    end

    describe '#update_tokens_details!' do
      it 'returns nil when response is blank' do
        expect(user.update_tokens_details!).to be_nil
      end

      it 'update the user token details and return true' do
        response = {
          access_token: 'fd4e1d45-ee00-449c-833a-a339acbeb2f7:123122:124122',
          refresh_token: '3b504775-b06f-4ab8-a116-f6f1cbac564e:123122:124122',
          expires_in: 863_99
        }
        expect(user.update_tokens_details!(response)).to be(true)

        expect(user.kylas_access_token).to eq(response[:access_token])
        expect(user.kylas_refresh_token).to eq(response[:refresh_token])
      end
    end

    describe '#update_users_and_tenants_details' do
      it 'does not call Kylas UserDetails/TenantDetails services if access/refresh tokens are blank' do
        user.update(kylas_access_token: nil)
        user.update_users_and_tenants_details
        expect(KylasEngine::UserDetails).not_to receive(:new)
        expect(KylasEngine::TenantDetails).not_to receive(:new)
      end

      context 'when kylas_access_token is present' do
        it 'calls UserDetails and TenantDetails service and updates kylas_user_id and kylas_tenant_id' do
          stub_user_details_request(body: user_stub_response)
          stub_tenant_details_request(body: tenant_stub_response)
          parsed_user_details_response = JSON.parse(user_stub_response)
          parsed_tenant_details_response = JSON.parse(tenant_stub_response)
          user.update_users_and_tenants_details
          expect(user.kylas_user_id).to eq(parsed_user_details_response['id'])
          expect(user.tenant.kylas_tenant_id).to eq(parsed_tenant_details_response['id'])
          expect(user.tenant.timezone).to eq(parsed_tenant_details_response['timezone'])
        end
      end
    end

    describe '#fetch_and_save_kylas_user_id' do
      context 'when update returns true' do
        it 'calls UserDetails service and updates kylas_user_id' do
          stub_user_details_request(body: user_stub_response)
          parsed_user_details_response = JSON.parse(user_stub_response)
          user.send(:fetch_and_save_kylas_user_id)
          expect(user.kylas_user_id).to eq(parsed_user_details_response['id'])
        end
      end

      context 'when update returns false' do
        before do
          expect_any_instance_of(User).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
        end

        it 'logs exception on logger' do
          expect(Rails.logger).to receive(:error).twice
          stub_user_details_request(body: user_stub_response)
          user.send(:fetch_and_save_kylas_user_id)
        end
      end

      context 'when kylas user service returns 500 error status code' do
        it 'does not update user' do
          expect_any_instance_of(User).not_to receive(:update!)
          stub_user_details_request(status: 500)
          user.send(:fetch_and_save_kylas_user_id)
        end
      end
    end

    describe '#fetch_and_save_kylas_tenant_id' do
      context 'when update returns true' do
        it 'calls TenantDetails service and updates kylas_tenant_id' do
          stub_tenant_details_request(body: tenant_stub_response)
          parsed_tenant_details_response = JSON.parse(tenant_stub_response)
          user.send(:fetch_and_save_kylas_tenant_id)
          expect(user.tenant.kylas_tenant_id).to eq(parsed_tenant_details_response['id'])
          expect(user.tenant.timezone).to eq(parsed_tenant_details_response['timezone'])
        end
      end

      context 'when update returns false' do
        before do
          expect_any_instance_of(Tenant).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
        end

        it 'logs exception on logger' do
          expect(Rails.logger).to receive(:error).twice
          stub_tenant_details_request(body: tenant_stub_response)
          user.send(:fetch_and_save_kylas_tenant_id)
        end
      end

      context 'when kylas user service returns 500 error status code' do
        it 'does not update user tenant id' do
          expect_any_instance_of(Tenant).not_to receive(:update!)
          stub_tenant_details_request(status: 500)
          user.send(:fetch_and_save_kylas_tenant_id)
        end
      end
    end

    describe '#fetch_access_token' do
      it 'does not call Kylas GetAccessToken service if old access_token is valid' do
        expect(KylasEngine::GetAccessToken).not_to receive(:new)
        expect(user.fetch_access_token).to eq(user.kylas_access_token)
      end

      context 'when old access_token is invalid' do
        before do
          user.update(kylas_access_token_expires_at: 1.hour.ago)
        end

        context 'with call Kylas GetAccessToken service for fetching new tokens' do
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

          it 'should not update user tokens details if response success is false' do
            stub_oauth_token_request(status: 404)
            expect_any_instance_of(User).not_to receive(:update_tokens_details!)
            user.fetch_access_token
          end

          it 'should update user tokens details if response success is true' do
            user.update(kylas_refresh_token: SecureRandom.uuid)
            response = {
              success: true,
              access_token: 'fd4e1d45-ee00-449c-833a-a339acbeb2f7:123122:124122',
              refresh_token: '3b504775-b06f-4ab8-a116-f6f1cbac564e:123122:124122',
              expires_in: 863_99
            }
            stub_oauth_token_request(body: response.to_json)
            expect_any_instance_of(User).to receive(:update_tokens_details!).and_call_original
            user.fetch_access_token
            expect(user.kylas_access_token).to eq(response[:access_token])
            expect(user.kylas_refresh_token).to eq(response[:refresh_token])
          end
        end
      end
    end

    describe '#active_for_authentication?' do
      context 'when user is active' do
        it 'does return true value' do
          expect(user.active_for_authentication?).to eq(true)
        end
      end
    end

    describe '#inactive_message' do
      context 'when user is not active but confirmed' do
        it 'returns deactivated user warning message' do
          user.active = false
          expect(user.inactive_message).to eq('Sorry, this account has been deactivated.')
        end
      end

      context 'when user active' do
        it 'does call super' do
          expect(user.inactive_message).to eq(:inactive)
        end
      end
    end

    describe '#has_no_password?' do
      context 'when no password is present on user' do
        it 'does return true' do
          user.encrypted_password = nil
          expect(user.has_no_password?).to eq(true)
        end
      end

      context 'when password is present on user' do
        it 'does return false' do
          expect(user.has_no_password?).to eq(false)
        end
      end
    end

    describe '#deactivate' do
      context 'when user is active' do
        it 'changes active to false' do
          expect(user.active).to eq(true)
          user.deactivate
          expect(user.active).to eq(false)
        end
      end
    end

    describe '#activate' do
      context 'when user is not active' do
        it 'changes active to true' do
          user.active = false
          user.activate
          expect(user.active).to eq(true)
        end
      end
    end

    describe '#create_tenant!' do
      context 'when we create new user' do
        it 'does create new tenant and makes user as tenant user' do
          user = create(:user, create_tenant: true)
          expect(user.is_tenant?).to eq(true)
          expect(user.tenant).not_to be_nil
        end
      end
    end

    describe '#attempt_set_password' do
      it 'does store password on user' do
        parameters = { password: 'test@123', password_confirmation: 'test@123' }
        user.attempt_set_password(parameters)
        expect(user.password).to eq(parameters[:password])
      end
    end
  end
end
