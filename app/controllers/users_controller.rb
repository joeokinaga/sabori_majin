class UsersController < ApplicationController
  include LazyScoreCalculator
  before_action :authenticate_user!, only: [:show]
  before_action :set_user_tasks, only: [:show]

  def show
    @user = current_user
    @tasks_all = @user_tasks
    @tasks_week  = @user_tasks.where(planned_start_at: Date.today.all_week)

    #完了したタスクの数
    @done_task_all = count_by_status(@tasks_all,"done")
    @done_task_week = count_by_status(@tasks_week,"done")

    #サボりスコア
    @lazy_score_all = sum_lazy_score(@tasks_all)
    @lazy_score_week = sum_lazy_score(@tasks_week)
  end

  private
    def set_user_tasks
      @user_tasks = (current_user || User.first).tasks.where("planned_start_at <= ?", Time.current)
    end

    def count_by_status(tasks,target_status)
      tasks.where(status:target_status).count
    end
end
