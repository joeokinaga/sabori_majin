class ReportsController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_user_tasks, only: [ :show ]
  def show
    @tasks_today = @user_tasks.where(planned_start_at: Date.today.all_day)
    @tasks_week  = @user_tasks.where(planned_start_at: Date.today.all_week)
    @tasks_month = @user_tasks.where(planned_start_at: Date.today.all_month)
    @tasks_year  = @user_tasks.where(planned_start_at: Date.today.all_year)
    @tasks_all   = @user_tasks

    @completation_rate_today = calc_completation_rate(@tasks_today)
    @completation_rate_week = calc_completation_rate(@tasks_week)
    @completation_rate_month = calc_completation_rate(@tasks_month)
    @completation_rate_year = calc_completation_rate(@tasks_year)
    @completation_rate_all = calc_completation_rate(@tasks_all)

    @total_time_today = calc_total_time(@tasks_today)
    @total_time_week = calc_total_time(@tasks_week)
    @total_time_month = calc_total_time(@tasks_month)
    @total_time_year = calc_total_time(@tasks_year)
    @total_time_all = calc_total_time(@tasks_all)

    @total_error_today = calc_task_time_error(@tasks_today)
    @total_error_week = calc_task_time_error(@tasks_week)
    @total_error_month = calc_task_time_error(@tasks_month)
    @total_error_year = calc_task_time_error(@tasks_year)
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
    def calc_task_time_error(tasks)
      tasks.sum do |task|
        next 0 unless task.started_at && task.finished_at && task.planned_start_at && task.planned_finish_at
        start_error  = (task.started_at - task.planned_start_at).abs
        finish_error = (task.finished_at - task.planned_finish_at).abs
        start_error + finish_error
      end
    end
end
