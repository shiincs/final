class CreatePortfolioCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :portfolio_categories do |t|
      t.integer :portfolio_id
      t.integer :category_id
      t.timestamps
    end
  end
end
