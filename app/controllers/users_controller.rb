class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :set_user_tasks, only: [:show]

  def show
    @user = current_user
    @tasks_all = @user_tasks
    @tasks_week  = @user_tasks.where(planned_start_at: Date.today.all_week)

    @done_task_all = count_by_status(@tasks_all,"done")
    @done_task_week = count_by_status(@tasks_week,"done")

    @skip_task_all = count_by_status(@tasks_all,"unstarted")
    @skip_task_week = count_by_status(@tasks_week,"unstarted")

  end

  private
    def set_user_tasks
      @user_tasks = (current_user || User.first).tasks.where("planned_start_at <= ?", Time.current)
    end

    def count_by_status(tasks,target_status)
      tasks.where(status:target_status).count
    end

end
