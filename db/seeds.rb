# frozen_string_literal: true

require 'faker'
include LazyScoreCalculator

# --- 既存データ削除 ---
Task.destroy_all
User.destroy_all

# --- ユーザー作成 ---
user_count = 1
users = user_count.times.map do |i|
  User.create!(
    name: "User#{i + 1}",
    email: "user#{i + 1}@example.com",
    password: "password",
    password_confirmation: "password"
  )
end

# --- 全てのユーザーに大量タスク（今年まで、1日3タスク以上） ---
min_duration = 10.minutes
max_duration = 3.hours
start_date = 1.year.ago.to_date
end_date = Date.today

users.each do |user|
  (start_date..end_date).to_a.each do |day|
    daily_tasks = []
    3.times do # 1日3タスク
      loop do
        planned_start_at = Faker::Time.between_dates(from: day, to: day, period: :day)
        duration = rand(min_duration..max_duration)
        planned_finish_at = planned_start_at + duration

        # DB上の既存タスクと重複チェック
        overlap = user.tasks.where(
          'planned_start_at < ? AND planned_finish_at > ?',
          planned_finish_at,
          planned_start_at
        ).exists?
        next if overlap

        status = [:unstarted, :stopped, :done].sample
        if status == :unstarted
          started_at = nil
          finished_at = nil
        else
          started_at = planned_start_at + rand(-5..15).minutes
          finished_at = started_at + rand((duration * 0.5).to_i..duration.to_i).seconds
        end
        

        daily_tasks << Task.new(
          user: user,
          title: Faker::Lorem.sentence(word_count: 3),
          planned_start_at: planned_start_at,
          planned_finish_at: planned_finish_at,
          started_at: started_at,
          finished_at: finished_at,
          status: status
        )
        break
      end
    end

    # その日のタスクの中に'done'がない場合、一つを強制的に'done'にする
    unless daily_tasks.any? { |t| t.status == 'done' }
      daily_tasks.sample.status = :done
    end

    daily_tasks.each do |task|
      task.save!(validate: false)
    end
  end
  puts "大量タスク作成完了: #{user.tasks.count} tasks for #{user.name}"
end