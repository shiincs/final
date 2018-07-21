class CreateUserComments < ActiveRecord::Migration[5.0]
  def change
    create_table :user_comments do |t|
      t.string :comment_contents
      t.string :date
      t.integer :reply_user_id
      t.integer :profile_user_id
      t.timestamps
    end
  end
end
