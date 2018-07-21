class AddImpressionsCountToProject < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :impressions_count, :int
  end
end
