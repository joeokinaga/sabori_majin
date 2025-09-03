class TasksController < ApplicationController
    before_action :authenticate_user!

    def index 
      # @tasks = current_user.tasks.where(planned_start_at: Date.current.all_day).order(planned_start_at: :asc)
      @tasks = current_user.tasks
                           .where(planned_start_at: Date.current.all_day)
                           .order(planned_start_at: :asc)
                          #  .where('planned_finish_at > ?', Time.zone.now)
    end

    def show
      @task = current_user.tasks.find(params[:id])
    end

    def new
      @task = current_user.tasks.build
    end

    def create
      date = params[:task][:planned_date]
      start_hour = params[:task][:start_hour]
      start_minute = params[:task][:start_minute]
      finish_hour = params[:task][:finish_hour]
      finish_minute = params[:task][:finish_minute]
      
      planned_start_at = Time.zone.parse("#{date} #{start_hour}:#{start_minute}")
      planned_finish_at = Time.zone.parse("#{date} #{finish_hour}:#{finish_minute}")
      
      @task = current_user.tasks.build(task_params)
      @task.planned_start_at = planned_start_at
      @task.planned_finish_at = planned_finish_at
      
      if @task.save
        redirect_to tasks_path, notice: "タスクを作成しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @task = current_user.tasks.find(params[:id])
    end

    def update
      date         = params[:task][:planned_date]
      start_hour   = params[:task][:start_hour]
      start_minute = params[:task][:start_minute]
      finish_hour  = params[:task][:finish_hour]
      finish_minute= params[:task][:finish_minute]
    
      planned_start_at =
        if date.present? && start_hour.present? && start_minute.present?
          Time.zone.parse("#{date} #{start_hour}:#{start_minute}")
        else
          nil
        end
    
      planned_finish_at =
        if date.present? && finish_hour.present? && finish_minute.present?
          Time.zone.parse("#{date} #{finish_hour}:#{finish_minute}")
        else
          nil
        end
    
      @task = current_user.tasks.find(params[:id])
      if @task.update(task_params.merge(
        planned_start_at: planned_start_at,
        planned_finish_at: planned_finish_at
      ))
        redirect_to tasks_path, notice: "タスクを更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @task = current_user.tasks.find(params[:id])
      @task.destroy
      redirect_to tasks_path, alert: "タスクを削除しました"
    end

    def start
      @task = current_user.tasks.find(params[:id])
      @task.working!
      redirect_to @task
    end
    
    def give_up
      @task = current_user.tasks.find(params[:id])
      @task.stopped!
      redirect_to @task
    end
    
    def finish
      @task = current_user.tasks.find(params[:id])
      @task.done!
      redirect_to @task
    end

    private
        def task_params
        params.require(:task).permit(:title, :content, :planned_start_at, :planned_finish_at)
        end
end
