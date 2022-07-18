class CreateKylasEngineTenants < ActiveRecord::Migration[7.0]
  def change
    create_table :kylas_engine_tenants do |t|
      t.timestamps
    end

    add_reference :kylas_engine_users, :tenant, references: :kylas_engine_tenants, index: true
    add_foreign_key :kylas_engine_users, :kylas_engine_tenants, column: :tenant_id
  end
end
