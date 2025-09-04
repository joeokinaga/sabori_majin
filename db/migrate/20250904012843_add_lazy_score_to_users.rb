class AddLazyScoreToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :lazy_score, :integer, default: 0, null: false
  end
end
