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

      root_path
    end
  end
end
