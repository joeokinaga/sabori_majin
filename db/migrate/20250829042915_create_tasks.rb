class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :content
      t.boolean :is_done
      t.datetime :planned_start_at
      t.datetime :planned_finish_at
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end
