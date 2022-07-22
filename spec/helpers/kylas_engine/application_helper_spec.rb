# frozen_string_literal: true

require 'rails_helper'

describe KylasEngine::ApplicationHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }

  describe '#active_class' do
    context 'when controller name matches with passed controller name' do
      it 'returns active' do
        expect(helper.active_class('test')).to eq('active')
      end
    end

    context 'when controller name does not matches with passed controller name' do
      it 'returns empty string' do
        expect(helper.active_class('dashboards')).to eq('')
      end
    end
  end

  describe '#create_avatar_name' do
    context 'when current user is blank' do
      it 'does return nil' do
        expect(helper.create_avatar_name).to eq(nil)
      end
    end

    context 'when current user is present' do
      before do
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'when current user name is present' do
        it 'return avatar name using current user name' do
          expect(helper.create_avatar_name).to eq(user.name[0])
        end
      end

      context 'when current user name is not present' do
        it 'return avatar name using email' do
          user.name = nil
          expect(helper.create_avatar_name).to eq(user.email[0])
        end
      end
    end
  end
end
