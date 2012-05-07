class AddUsersColumns < ActiveRecord::Migration
  def up
   add_column :users, :login, :string
   add_column :users, :api_key, :string
   add_column :users, :auth_url, :string
  end

  def down
  end
end
