# frozen_string_literal: true

# OAuth
module KylasEngine
  class KylasAuthController < ApplicationController
    before_action :kylas_auth_request?
    before_action :authenticate_user!

    def authenticate
      authorization_code = params[:code]

      if authorization_code.present?
        response = KylasEngine::ExchangeCode.new(authorization_code: authorization_code).call
        if response[:success]
          current_user.update_tokens_details!(response)
          current_user.update_users_and_tenants_details
          session.delete(:previous_url) if auth_request?(session[:previous_url])
          flash[:success] = t('kylas_auth.successfully_installed')
        else
          flash[:alert] = t('kylas_auth.facing_problem')
        end
      else
        flash[:alert] = t('something_went_wrong')
      end

      redirect_to dashboard_help_path
    end

    private

    def kylas_auth_request?
      session[:previous_url] = request.fullpath if auth_request?(request.fullpath)
    end

    def auth_request?(url)
      url&.include?('kylas-engine/kylas-auth?code=')
    end
  end
end
