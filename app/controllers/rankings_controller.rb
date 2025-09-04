class RankingsController < ApplicationController
  include LazyScoreCalculator
  before_action :authenticate_user!, only: [:show]
  def show
    # 期間を取得（デフォルトは1日）
    @period = params[:period] || "1day"

    now = Time.current.in_time_zone("Asia/Tokyo")

    @all_users = User.all

    @all_users.each do |user|
      tasks = case @period
      when "1day"
        user.tasks.where(planned_start_at: now.beginning_of_day..now.end_of_day)
      when "1week"
        user.tasks.where(planned_start_at: (now - 6.days).beginning_of_day..now.end_of_day)
      when "1month"
        user.tasks.where(planned_start_at: (now - 1.month).beginning_of_day..now.end_of_day)
      when "1year"
        user.tasks.where(planned_start_at: (now - 1.year).beginning_of_day..now.end_of_day)
      when "all"
        user.tasks
      else
        user.tasks
      end

      user.update(lazy_score: sum_lazy_score(tasks))
    end

    @all_users = @all_users.order(lazy_score: :desc)
    
    @all_users_with_rank = []

    rank = 0
    prev_score = nil
    @all_users.order(lazy_score: :desc).each_with_index do |user, i|
      if user.lazy_score != prev_score
        rank = i + 1
        prev_score = user.lazy_score
      end
      @all_users_with_rank << { user: user, rank: rank }
    end

    @user_rank = @all_users_with_rank.find { |ur| ur[:user].id == current_user.id }[:rank]

  end
end
