class AddKylasTenantIdToTenants < ActiveRecord::Migration[7.0]
  def change
    add_column :kylas_engine_tenants, :kylas_api_key, :string
    add_column :kylas_engine_tenants, :webhook_api_key, :string
    add_column :kylas_engine_tenants, :kylas_tenant_id, :string
    add_column :kylas_engine_tenants, :timezone, :string, default: 'Asia/Calcutta'
  end
end
