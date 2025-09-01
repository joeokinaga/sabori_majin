class ChangeStatusToIntegerInTasks < ActiveRecord::Migration[8.0]
  def up
    # 文字列から整数に変換するため、一時カラムを作る方法もあるが
    # 既存データがなければシンプルに change_column で OK
    change_column :tasks, :status, :integer, default: 0, null: false
  end

  def down
    change_column :tasks, :status, :string
  end
end
