class TasksController < ApplicationController
    before_action :authenticate_user!

    def index 
      @tasks = current_user.tasks.where(planned_start_at: Date.current.all_day).order(planned_start_at: :asc)
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
        render :new
      end
    end

    def edit
    end

    def update
    end

    def destroy
    end

    private
        def task_params
        params.require(:task).permit(:title, :content, :planned_start_at, :planned_finish_at)
        end
end
