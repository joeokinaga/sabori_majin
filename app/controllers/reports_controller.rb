class ReportsController < ApplicationController
  def show
    before_action :authenticate_user!
    todays_tasks = current_user.tasks.where(planned_start_at: Date.today.all_day)
    tasks_count = todays_tasks.count
    if tasks_count.zero?
      @completation_rate = 0
    else
      completed_tasks_count = todays_tasks.where(status: "done").count
      @completation_rate = ((completed_tasks_count.to_f / tasks_count) * 100).round(1)
    end
  end
end
