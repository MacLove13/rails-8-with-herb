class EncryptUserSensitiveAttributes < ActiveRecord::Migration[8.1]
  def change
    change_column :users, :email_address, :text, null: false
    change_column :users, :name, :text
  end
end
