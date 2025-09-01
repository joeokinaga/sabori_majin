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
      @task = current_user.tasks.build(task_params)
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
