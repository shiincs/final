class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      
      t.string            :project_title
      t.string            :image_path
      
      t.integer           :master_id
      t.integer           :project_people
      t.integer           :project_complete, default: 1
      
      t.datetime          :project_start
      t.datetime          :project_end
      
      t.text              :project_contents
      

      t.timestamps
    end
  end
end
