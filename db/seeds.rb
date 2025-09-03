# db/seeds.rb

# --- 既存ユーザー・タスクを削除 ---
User.destroy_all
Task.destroy_all

# --- テストユーザー作成 ---
user = User.create!(
  name:  "Example User",
  email: "han@gmail.com",
  password: "hanhan",
  password_confirmation: "hanhan"
)

statuses = %i[unstarted working stopped done]

# --- 固定タスク（今日・明日） ---
def create_task(user, title, content, status, planned_date, start_hour, duration_hours)
  start_time = planned_date.beginning_of_day + start_hour.hours
  end_time   = start_time + duration_hours.hours

  user.tasks.create!(
    title: title,
    content: content,
    status: status,
    planned_start_at: start_time,
    planned_finish_at: end_time,
    started_at: start_time,
    finished_at: end_time
  )
end

# 今日の固定タスク
create_task(user, "今日やること1", "テスト用タスクの内容1", :done, Date.today, 0, 3)
create_task(user, "今日やること2", "テスト用タスクの内容2", :unstarted, Date.today, 4, 3)

# 明日の固定タスク
create_task(user, "明日やること", "明日のタスク内容", :unstarted, Date.tomorrow, 1, 2)

# --- ランダム50個のタスク作成（重複なし） ---
50.times do |i|
  planned_date = Date.today + i.days
  day_start = planned_date.beginning_of_day
  day_end   = planned_date.end_of_day

  # 既存タスクの時間帯を取得（配列で保持）
  existing_intervals = user.tasks.where(planned_start_at: day_start..day_end)
                                 .map { |t| [t.started_at, t.finished_at] }

  loop do
    start_time = day_start + rand(0..20).hours
    duration   = rand(1..3).hours
    end_time   = start_time + duration

    # 重複チェック
    overlap = existing_intervals.any? do |existing_start, existing_end|
      start_time < existing_end && existing_start < end_time
    end

    next if overlap # 重なっていたら再生成

    # タスク作成
    task = user.tasks.create!(
      title: "タスク#{i + 1}",
      content: "テスト用タスクの内容#{i + 1}",
      status: statuses.sample,
      planned_start_at: start_time,
      planned_finish_at: end_time,
      started_at: start_time,
      finished_at: end_time
    )

    # 作成したタスクを既存配列に追加
    existing_intervals << [task.started_at, task.finished_at]
    break
  end
end

puts "Seed finished! User: #{user.email}, Tasks: #{user.tasks.count}"
