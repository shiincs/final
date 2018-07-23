class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :user_name, :string
    add_column :users, :user_access_token, :string
    add_column :users, :user_password, :string
    add_column :users, :user_image, :string
    add_column :users, :user_contents, :text
    add_column :users, :git_skill_1, :string
    add_column :users, :git_skill_2, :string
    add_column :users, :git_skill_3, :string
    add_column :users, :birth, :string
    add_column :users, :address, :string
    add_column :users, :tel, :string
    add_column :users, :exp, :integer ,default: 0
  end
end
