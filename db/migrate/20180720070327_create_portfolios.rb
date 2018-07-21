class CreatePortfolios < ActiveRecord::Migration[5.0]
  def change
    create_table :portfolios do |t|
      t.string :portfolio_title
      t.string :portfolio_contents
      t.string :portfolio_file
      t.string :portfolio_start
      t.string :portfolio_end
      t.string :user_id
      
      t.timestamps
    end
  end
end
