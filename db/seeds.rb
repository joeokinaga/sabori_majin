# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# 既存ユーザーを削除（重複防止）
User.destroy_all
Task.destroy_all

# テストユーザーを作成
user = User.create!(
  name:  "Example User",
  email: "example@railstutorial.org",
  password: "foobar",
  password_confirmation: "foobar"
)

statuses = [ :unstarted, :working, :stopped, :done ]

# 今日のタスクを作成
user.tasks.create!(
  title: "今日やること1",
  content: "テスト用タスクの内容1",
  status: :done,
  planned_start_at: Date.today.beginning_of_day,
  planned_finish_at: Date.today.end_of_day,
  started_at: Date.today.beginning_of_day + rand(0..2).hours,       # 適当に開始
  finished_at: Date.today.beginning_of_day + rand(3..8).hours      # 適当に終了
)

user.tasks.create!(
  title: "今日やること2",
  content: "テスト用タスクの内容2",
  status: :unstarted,
  planned_start_at: Date.today.beginning_of_day,
  planned_finish_at: Date.today.end_of_day,
  started_at: Date.today.beginning_of_day + rand(1..3).hours,
  finished_at: Date.today.beginning_of_day + rand(4..9).hours
)

# 明日のタスク
user.tasks.create!(
  title: "明日やること",
  content: "明日のタスク内容",
  status: :unstarted,
  planned_start_at: Date.tomorrow.beginning_of_day,
  planned_finish_at: Date.tomorrow.end_of_day,
  started_at: Date.tomorrow.beginning_of_day + rand(0..2).hours,
  finished_at: Date.tomorrow.beginning_of_day + rand(3..8).hours
)

# 50個のタスクを作成
50.times do |i|
  planned_date = Date.today + i.days
  start_time = planned_date.beginning_of_day + rand(0..3).hours
  end_time = planned_date.beginning_of_day + rand(4..10).hours

  user.tasks.create!(
    title: "タスク#{i + 1}",
    content: "テスト用タスクの内容#{i + 1}",
    status: statuses.sample,
    planned_start_at: planned_date.beginning_of_day,
    planned_finish_at: planned_date.end_of_day,
    started_at: start_time,
    finished_at: end_time
  )
end

puts "Seed finished! User: #{user.email}, Tasks: #{user.tasks.count}"
