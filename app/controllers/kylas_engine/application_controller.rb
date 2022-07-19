# frozen_string_literal: true

module KylasEngine
  class ApplicationController < ActionController::Base
    helper_method :current_tenant

    def current_tenant
      return unless current_user.present?

      current_user.tenant
    end

    def after_sign_in_path_for(resource)
      return session.delete(:previous_url) if session[:previous_url].present?

      "/kylas-engine#{dashboard_help_path}"
    end

    def after_sign_out_path_for(resource)
      "/kylas-engine#{new_user_session_path}"
    end
  end
end
