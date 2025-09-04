class UsersController < ApplicationController
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

    def sum_lazy_score(tasks)
      tasks.sum do |task|
        calc_lazy_score(task)
      end
    end
    def calc_lazy_score(task)
      if task.status != "unstarted" || Time.current > task.planned_start_at + 3.minutes
        if task.status == "unstarted"
          return 5
        else
          lazy_pt = 0

          if task.status == "stopped"
            lazy_pt += 2
          end

          if task.started_at > task.planned_start_at + 3.minutes
            lazy_pt += 2
          elsif task.started_at < task.planned_start_at - 3.minutes
            lazy_pt += 1
          end

          if (task.planned_finish_at - task.planned_start_at) * 0.8 > (task.finished_at - task.started_at)
            lazy_pt += 1
          end

          return lazy_pt

        end
      else
        return 0
      end
    end
end
