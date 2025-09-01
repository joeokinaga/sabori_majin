class ChangeTasksColumns < ActiveRecord::Migration[8.0]
  def change
    rename_column :tasks, :is_done, :status
    change_column :tasks, :status, :string
    change_column :tasks, :content, :text
    add_column :tasks, :title, :string
  end
end
