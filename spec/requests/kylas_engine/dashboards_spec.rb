# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KylasEngine::DashboardsController, type: :request do
  let(:user) { create(:user) }
  let(:request_url) { get '/kylas-engine/dashboard/help' }

  shared_examples :unauthenticated_user do
    context 'when user is not logged in' do
      it 'redirects to login path' do
        expect(request_url).to redirect_to('/kylas-engine/users/sign_in')
      end
    end
  end

  describe '#help' do
    it_behaves_like :unauthenticated_user

    context 'when request made to help' do
      it 'returns correct url and response' do
        execute_with_resource_sign_in(user) do
          request_url
        end
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('text/html; charset=utf-8')
        expect(response.media_type).to eq('text/html')
      end
    end
  end
end
