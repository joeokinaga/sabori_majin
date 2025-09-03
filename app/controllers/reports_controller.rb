class ReportsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_user_tasks, only: [ :daily, :weekly, :monthly, :yearly, :all ]

  def daily
    @tasks_today = @user_tasks.where(planned_start_at: Date.today.all_day)
    if @tasks_today.empty?
      redirect_to new_task_path, notice: "今日のタスクを登録しろぼけなす"
    end
    @completation_rate_today = calc_completation_rate(@tasks_today)
    @total_time_today = calc_total_time(@tasks_today)
    @total_error_today = calc_task_time_error(@tasks_today)
    @total_planned_working_time = calc_planned_working_time(@tasks_today)
  end

  def weekly
    @tasks_week  = @user_tasks.where(planned_start_at: Date.today.all_week)
    if @tasks_week.empty?
      redirect_to new_task_path, notice: "今週のタスクを登録しろぼけなす"
    end
    @completation_rate_week = calc_completation_rate(@tasks_week)
    @total_time_week = calc_total_time(@tasks_week)
    @total_time_week_per_day_hours = calc_total_time_week(@tasks_week).values.map do |s|
      value = s.is_a?(Array) ? s.first : s
      (value / 3600.0).round(1)
    end
    @total_error_week = calc_task_time_error(@tasks_week)
  end

  def monthly
    @tasks_month = @user_tasks.where(planned_start_at: Date.today.all_month)
    if @tasks_month.empty?
      redirect_to new_task_path, notice: "今月のタスクを登録しろぼけなす"
    end
    @completation_rate_month = calc_completation_rate(@tasks_month)
    @total_time_month = calc_total_time(@tasks_month)
    @total_time_month_per_week_hours = calc_total_time_month(@tasks_month).values.map do |s|
      value = s.is_a?(Array) ? s.first : s
      (value / 3600.0).round(1)
    end
    @total_error_month = calc_task_time_error(@tasks_month)
  end

  def yearly
    @tasks_year  = @user_tasks.where(planned_start_at: Date.today.all_year)
    if @tasks_year.empty?
      redirect_to new_task_path, notice: "今年のタスクを登録しろぼけなす"
    end
    @completation_rate_year = calc_completation_rate(@tasks_year)
    @total_time_year = calc_total_time(@tasks_year)
    @total_time_year_per_month_hours = calc_total_time_year(@tasks_year).values.map do |s|
      value = s.is_a?(Array) ? s.first : s
      (value / 3600.0).round(1)
    end
    @total_error_year = calc_task_time_error(@tasks_year)
  end

  def all
    @tasks_all   = @user_tasks
    if @tasks_all.empty?
      redirect_to new_task_path, notice: "タスクを登録しろぼけなす"
    end
    @completation_rate_all = calc_completation_rate(@tasks_all)
    @total_time_all = calc_total_time(@tasks_all)
    @total_error_all = calc_task_time_error(@tasks_all)
  end

  private
    def set_user_tasks
      @user_tasks = (current_user || User.first).tasks
    end

    def calc_completation_rate(tasks)
      total = tasks.count
      return 0 if total.zero?
      completed = tasks.where(status: :done).count
      ((completed.to_f / total) * 100).round(1)
    end
    def calc_total_time(tasks)
      tasks.sum do |task|
        next 0 unless task.started_at && task.finished_at
        task.finished_at - task.started_at
      end
    end
    def calc_total_time_week(tasks)
      # 曜日をキーとし、初期値を0.0としたハッシュを用意
      weekly_totals = {
        "日" => 0.0, "月" => 0.0, "火" => 0.0, "水" => 0.0,
        "木" => 0.0, "金" => 0.0, "土" => 0.0
      }

      # Time#wday (0=日曜) の返り値と日本語の曜日を対応させる配列
      wday_map = [ "日", "月", "火", "水", "木", "金", "土" ]

      tasks.each do |task|
        # 開始・終了時刻がないタスクはスキップ
        next unless task.started_at && task.finished_at

        # 曜日のインデックスを取得 (0が日曜日)
        day_index = task.finished_at.wday
        # インデックスを日本語の曜日に変換
        day_key = wday_map[day_index]

        # 計算した時間を対応する曜日に加算
        duration = task.finished_at - task.started_at
        weekly_totals[day_key] += duration
      end
      # 集計結果のハッシュを返す
      weekly_totals
    end
    def calc_total_time_month(tasks)
      # 月の週ごとの合計時間を格納するハッシュ（多くの月が5週にまたがるため第5週まで用意）
      monthly_totals = {
        "第1週" => 0.0, "第2週" => 0.0, "第3週" => 0.0, "第4週" => 0.0, "第5週" => 0.0
      }

      tasks.each do |task|
        # 開始・終了時刻がないタスクはスキップ
        next unless task.started_at && task.finished_at

        # タスクの終了日から、それが月の何日目かを取得
        day_of_month = task.finished_at.day

        # 日付から、その月における週番号を計算
        # (例: 1日～7日 → 1週目, 8日～14日 → 2週目...)
        week_number = (day_of_month - 1) / 7 + 1

        # 対応する週のキーを作成 (例: "第1週")
        week_key = "第#{week_number}週"

        # 計算した時間を対応する週に加算
        duration = task.finished_at - task.started_at
        # 存在しない週のキー（例: 第6週）へのアクセスを防ぐ
        monthly_totals[week_key] += duration if monthly_totals.key?(week_key)
      end

      # 集計結果のハッシュを返す
      monthly_totals
    end
    def calc_total_time_year(tasks)
      # 1年を月ごとに集計するためのハッシュを初期化
      yearly_totals = {
        "1月" => 0.0, "2月" => 0.0, "3月" => 0.0, "4月" => 0.0,
        "5月" => 0.0, "6月" => 0.0, "7月" => 0.0, "8月" => 0.0,
        "9月" => 0.0, "10月" => 0.0, "11月" => 0.0, "12月" => 0.0
      }

      tasks.each do |task|
        # 開始・終了時刻がないタスクはスキップ
        next unless task.started_at && task.finished_at

        # タスクの終了日から「月」を取得 (1～12の数値が返る)
        month_number = task.finished_at.month

        # 対応する月のキーを作成 (例: "1月")
        month_key = "#{month_number}月"

        # 計算した時間を対応する月に加算
        duration = task.finished_at - task.started_at
        yearly_totals[month_key] += duration
      end

      # 集計結果のハッシュを返す
      yearly_totals
    end
    def calc_task_time_error(tasks)
      tasks.sum do |task|
        next 0 unless task.started_at && task.finished_at && task.planned_start_at && task.planned_finish_at
        start_error  = (task.started_at - task.planned_start_at).abs
        finish_error = (task.finished_at - task.planned_finish_at).abs
        start_error + finish_error
      end
    end

    def calc_planned_working_time(tasks)
      tasks.sum do |task|
        next 0 unless task.planned_start_at && task.planned_finish_at
        task.planned_finish_at - task.planned_start_at
      end
    end
end
