# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb
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

# 今日のタスクを作成
user.tasks.create!(
  title: "今日やること1",
  content: "テスト用タスクの内容1",
  status: :done,   # シンボルで指定
  planned_start_at: Date.today.beginning_of_day,
  planned_finish_at: Date.today.end_of_day
)

user.tasks.create!(
  title: "今日やること2",
  content: "テスト用タスクの内容2",
  status: :unstarted,  # シンボルで指定
  planned_start_at: Date.today.beginning_of_day,
  planned_finish_at: Date.today.end_of_day
)

# 明日のタスクも作る
user.tasks.create!(
  title: "明日やること",
  content: "明日のタスク内容",
  status: :unstarted,  # シンボルで指定
  planned_start_at: Date.tomorrow.beginning_of_day,
  planned_finish_at: Date.tomorrow.end_of_day
)

puts "Seed finished! User: #{user.email}, Tasks: #{user.tasks.count}"
