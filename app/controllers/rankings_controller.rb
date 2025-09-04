class RankingsController < ApplicationController
  include LazyScoreCalculator
  before_action :authenticate_user!, only: [:show]
  def show
    @all_users = User.all
    @all_users.each do |user|
      tasks = user.tasks.where("planned_start_at <= ?", Time.current)
      user.update(lazy_score: sum_lazy_score(tasks))
    end
    @all_users = @all_users.order(lazy_score: :desc)
  end
end
