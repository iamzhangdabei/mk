class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|

      t.timestamps
    end
  end
end
