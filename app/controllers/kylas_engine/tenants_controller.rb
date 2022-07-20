# frozen_string_literal: true

module KylasEngine
  class TenantsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_tenant

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
  end
end
