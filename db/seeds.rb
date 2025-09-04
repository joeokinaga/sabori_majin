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
                                 .map { |t| [ t.started_at, t.finished_at ] }

  loop do
    start_time = day_start + rand(0..20).hours
    duration   = rand(1..3).hours
    # 計画上の終了時刻と、実際の終了時刻（1時間遅れ）を先に定義する
    planned_finish_time = start_time + duration
    actual_finish_time  = planned_finish_time + 1.hour

    # 重複チェックでは「実際の終了時刻」を使用する
    overlap = existing_intervals.any? do |existing_start, existing_end|
      start_time < existing_end && existing_start < actual_finish_time
    end

    next if overlap # 重なっていたら再生成

    # タスク作成
    task = user.tasks.create!(
      title: "タスク#{i + 1}",
      content: "テスト用タスクの内容#{i + 1}",
      status: statuses.sample,
      planned_start_at: start_time,
      planned_finish_at: planned_finish_time,  # 計画上の終了時刻
      started_at: start_time,
      finished_at: actual_finish_time          # 実際の終了時刻
    )

    # 作成したタスクを既存配列に追加
    existing_intervals << [ task.started_at, task.finished_at ]
    break
  end
end

now = Time.current.in_time_zone("Asia/Tokyo")
#ptをカウントするために一時的に削除
# Task.destroy_all

#未着手なので5pt
Task.create!(
  title: "未着手で遅延",
  status: :unstarted,
  planned_start_at: Time.current - 60.minutes,
  planned_finish_at: Time.current - 50.minutes,
  user_id: user.id
)

#未完了、開始遅れ、所要時間短い 4pt
Task.create!(
  title: "停止したタスク",
  status: :stopped,
  planned_start_at: Time.current - 40.minutes,
  planned_finish_at: Time.current - 30.minutes,
  started_at: Time.current - 35.minutes,
  finished_at: Time.current - 32.minutes,
  user_id: user.id
)

#開始遅れ、所長時間短い 2pt
Task.create!(
  title: "開始遅れタスク",
  status: :done,
  planned_start_at: Time.current - 20.minutes,
  planned_finish_at: Time.current - 10.minutes,
  started_at: Time.current - 15.minutes,
  finished_at: Time.current - 12.minutes,
  user_id: user.id
)



# --- ユーザー作成 ---
users = [
  { name: "Alice",   email: "alice@example.com",   password: "password" },
  { name: "Bob",     email: "bob@example.com",     password: "password" },
  { name: "Charlie", email: "charlie@example.com", password: "password" }
]

users.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.name     = attrs[:name]
    user.password = attrs[:password]
  end
end

# ユーザー取得
alice   = User.find_by(email: "alice@example.com")
bob     = User.find_by(email: "bob@example.com")
charlie = User.find_by(email: "charlie@example.com")

# --- 確認用タスク作成（enumに合わせる） ---

# Alice → 遅刻して開始、途中で止めた
alice.tasks.create!(
  title: "Aliceの停止タスク",
  content: "テスト用タスク",
  status: :stopped,   # Enumにある値
  planned_start_at: now - 5.hours,
  planned_finish_at: now - 4.hours + 30.minutes,
  started_at: now - 4.hours + 10.minutes,
  finished_at: now - 4.hours + 25.minutes
)

# Bob → 予定通り開始、早く終わった
bob.tasks.create!(
  title: "Bobの完了タスク",
  content: "テスト用タスク",
  status: :done,      # Enumに合わせて :done に変更
  planned_start_at: now - 3.hours,
  planned_finish_at: now - 2.hours + 30.minutes,
  started_at: now - 3.hours,
  finished_at: now - 2.hours
)

# Charlie → 未開始
charlie.tasks.create!(
  title: "Charlieの未開始タスク",
  content: "テスト用タスク",
  status: :unstarted, # Enumにある値
  planned_start_at: now - 2.hours,
  planned_finish_at: now - 1.hours + 50.minutes
)

puts "Seed finished! User: #{user.email}, Tasks: #{user.tasks.count}"
