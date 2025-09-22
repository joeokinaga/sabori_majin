# frozen_string_literal: true

require 'faker'
include LazyScoreCalculator

Task.destroy_all
User.destroy_all

user_count = 1
users = user_count.times.map do |i|
  User.create!(
    name: "User#{i + 1}",
    email: "user#{i + 1}@example.com",
    password: "password",
    password_confirmation: "password"
  )
end

min_duration = 10.minutes
max_duration = 3.hours
start_date = 1.year.ago.to_date
end_date = 1.month.from_now.to_date

users.each do |user|
  (start_date..end_date).to_a.each do |day|
    daily_tasks = []
    i = 0
    3.times do
      i += 1
      loop do
        planned_start_at = Faker::Time.between_dates(from: day, to: day, period: :day)
        duration = rand(min_duration..max_duration)
        planned_finish_at = planned_start_at + duration

        overlap_in_db = user.tasks.where(
          'planned_start_at < ? AND planned_finish_at > ?',
          planned_finish_at,
          planned_start_at
        ).exists?

        overlap_in_memory = daily_tasks.any? do |t|
          t.planned_start_at < planned_finish_at && t.planned_finish_at > planned_start_at
        end

        next if overlap_in_db || overlap_in_memory

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
          title: "#{user.name}_#{day}_0#{i}",
          planned_start_at: planned_start_at,
          planned_finish_at: planned_finish_at,
          started_at: started_at,
          finished_at: finished_at,
          status: status
        )
        break
      end
    end

    unless daily_tasks.any?(&:done?)
      daily_tasks.sample.status = :done
    end

    daily_tasks.each do |task|
      task.save!(validate: false)
    end
  end
  puts "大量タスク作成完了: #{user.tasks.count} tasks for #{user.name}"
end
