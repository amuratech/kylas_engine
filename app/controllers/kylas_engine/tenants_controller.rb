# frozen_string_literal: true

module KylasEngine
  class TenantsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_tenant
    before_action :validate_api_key, only: :update

    def edit
      @tenant = current_tenant
    end

    def update
      if current_tenant.update(tenant_params)
        flash[:success] = t('tenants.api_key_updated')
      else
        flash[:danger] = t('tenants.failed_to_update')
      end

      redirect_to edit_tenant_path(current_tenant)
    end

    private

    def tenant_params
      params.require(:tenant).permit(:kylas_api_key)
    end

    # Checks if the api key entered by user is belongs to the current tenant or not
    def validate_api_key
      # Allowing to save empty kylas api key
      return true if params.dig(:tenant, :kylas_api_key).blank?

      # Check if the api key entered by user is already used by someone else
      tenant = KylasEngine::Tenant.where.not(id: current_tenant.id)
                                  .where(kylas_api_key: params.dig(:tenant, :kylas_api_key)).first
      if tenant.present?
        flash[:danger] = t('tenants.invalid_api_key')
        redirect_to edit_tenant_path(current_tenant) and return false
      end

      update_users_and_tenants_details

      response = KylasEngine::TenantDetails.new(user: current_user)
                                           .fetch_details_using_api_key(new_kylas_api_key: params.dig(:tenant, :kylas_api_key), tenant: current_tenant)

      if response[:success] && response.dig(:data, 'id') == current_tenant.kylas_tenant_id.to_i
        true
      else
        flash[:danger] = response[:message] || t('tenants.please_install_application')
        redirect_to edit_tenant_path(current_tenant) and return false
      end
    end

    # Update kylas user id and tenant id if not already present
    def update_users_and_tenants_details
      if current_user.kylas_user_id.blank? || current_tenant.kylas_tenant_id.blank?
        current_user.update_users_and_tenants_details
      end
    end
  end
end
