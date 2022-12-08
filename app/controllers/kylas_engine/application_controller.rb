# frozen_string_literal: true

module KylasEngine
  class ApplicationController < ActionController::Base
    helper_method :current_tenant

    before_action :store_location, :validate_iframe_user

    def validate_iframe_user
      session[:tenantId] = params[:tenantId] if params[:tenantId]
      session[:userId] = params[:userId] if params[:userId]

      return true if session[:tenantId].blank? && session[:userId].blank?
      return true if current_user.blank?

      if((session[:userId] && current_user.kylas_user_id != session[:userId].to_i) || (session[:tenantId] && current_user.tenant.kylas_tenant_id != session[:tenantId].to_i))
        flash.clear
        flash.keep[:danger] = 'Signed out because your kylas user and marketplace app user mismatched'
        sign_out(current_user)
      end
    end

    def store_location
      if session[:previous_url].blank? || session[:previous_url] == '/'
        session[:previous_url] = request.fullpath
        session[:previous_url] = request.fullpath if request.fullpath.include? 'code'
      end
      return session[:previous_url]
    end

    def current_tenant
      return unless current_user.present?

      current_user.tenant
    end

    def after_sign_in_path_for(resource)
      unless request.url.include?('sign_in')
        session[:tenantId] = nil
        session[:userId] = nil
      end
      return session.delete(:previous_url) if session[:previous_url].present?

      custom_dashboard_path
    end

    def after_sign_out_path_for(resource)
      session[:previous_url] = nil

      kylas_engine.new_user_session_path
    end

    private

    def authenticate_tenant
      return true if current_user.is_tenant?

      flash[:alert] = t('dont_have_permission')
      redirect_to custom_dashboard_path
    end

    def custom_dashboard_path
      Rails.application.routes.url_helpers.root_path
    rescue NoMethodError
      kylas_engine.dashboard_help_path
    end
  end
end
