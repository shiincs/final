class CreateGithubSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :github_skills do |t|
      t.integer :user_id
      t.integer :skill_id
      t.integer :skill_byte
      t.timestamps
    end
  end
end
