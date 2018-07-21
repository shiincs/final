class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :message_contents
      t.integer :receive_user_id
      t.integer :send_user_id
      
      
      t.timestamps
    end
  end
end
