class CreateChats < ActiveRecord::Migration[5.0]
  def change
    create_table :chats do |t|
      t.references    :user       #
      t.references    :project  # 어느 방에서 하는가?
      t.text          :message 
      t.timestamps
    end
  end
end
