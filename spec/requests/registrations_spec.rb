# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :request do
  describe '#create' do
    def create_request(params: {})
      post "/#{kylas_engine_path}/users", params: params
    end

    context 'when parameter missing' do
      it 'does not create user' do
        parameters = { user: { name: 'test' } }
        expect { create_request(params: parameters) }.not_to change(KylasEngine::User, :count)
        expect(response.status).to eq(200)
      end
    end

    context 'when parameters are correct' do
      it 'creates user' do
        parameters = { user: { email: 'test1@example.com', password: 'amura@123', name: 'test' }}
        expect { create_request(params: parameters) }.to change(KylasEngine::User, :count).by(1)
        expect(response.status).to eq(302)
        expect(flash.notice).to eq('A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.')
        expect(response).to redirect_to('/kylas-engine/users/sign_in')
        created_user = KylasEngine::User.first
        expect(created_user.name).to eq('test')
        expect(created_user.is_tenant?).to eq(true)
        expect(created_user.tenant_id).not_to be_nil
      end
    end
  end
end
