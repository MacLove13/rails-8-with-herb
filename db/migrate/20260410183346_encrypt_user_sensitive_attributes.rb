class EncryptUserSensitiveAttributes < ActiveRecord::Migration[8.1]
  def up
    change_column :users, :email_address, :text, null: false
    change_column :users, :name, :text

    # Re-encrypt existing records (no-op on fresh databases, safe on populated ones)
    User.reset_column_information
    User.find_each(&:save!)
  end

  def down
    change_column :users, :email_address, :string, null: false
    change_column :users, :name, :string
  end
end
