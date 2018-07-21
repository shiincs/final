class CreatePortfolioSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :portfolio_skills do |t|
      t.integer :portfolio_id
      t.integer :skill_id
      t.timestamps
    end
  end
end
