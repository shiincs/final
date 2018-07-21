class CreateUserProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :user_projects do |t|
      t.integer :user_id
      t.integer :project_id
      
      t.boolean :authorized_member, default:false
      t.timestamps
    end
  end
end
