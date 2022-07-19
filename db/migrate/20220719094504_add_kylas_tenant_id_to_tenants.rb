class AddKylasTenantIdToTenants < ActiveRecord::Migration[7.0]
  def up
    add_column :kylas_engine_tenants, :kylas_api_key, :string
    add_column :kylas_engine_tenants, :webhook_api_key, :string
    add_column :kylas_engine_tenants, :kylas_tenant_id, :bigint
    add_column :kylas_engine_tenants, :timezone, :string, default: 'Asia/Calcutta'

    remove_column :kylas_engine_users, :kylas_user_id, :string
    add_column :kylas_engine_users, :kylas_user_id, :bigint
  end

  def down
    remove_column :kylas_engine_tenants, :kylas_api_key, :string
    remove_column :kylas_engine_tenants, :webhook_api_key, :string
    remove_column :kylas_engine_tenants, :kylas_tenant_id, :bigint
    remove_column :kylas_engine_tenants, :timezone, :string, default: 'Asia/Calcutta'

    add_column :kylas_engine_users, :kylas_user_id, :string
    remove_column :kylas_engine_users, :kylas_user_id, :bigint
  end
end
