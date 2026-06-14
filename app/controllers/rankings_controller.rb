class RankingsController < ApplicationController
  include LazyScoreCalculator
  before_action :authenticate_user!, only: [:show]
  def show
    @period = params[:period] || "all"

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

    @total_users = @all_users_with_rank.size
    # percentile = @user_rank.to_f / @total_users
    # if percentile <= 0.25
    #   @user_message = ai_message(:fail)
    # elsif percentile <= 0.8
    #   @user_message = ai_message(:normal)
    # else
    #   @user_message = ai_message(:excellent)
    # end
  end
  
  private

  def ai_message(status)
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_access_token
    )
  
    prompt = case status
             when :excellent
               "「EXCELLENT」というカテゴリのために、
               褒めてめちゃくちゃユーモアを込めた日本語メッセージを短い1文作ってください。
               かなりネタに走ってください。くだらなくても構いません。
               出力はそのセリフだけ。例：鳥肌凄すぎて、鳥になりそう"

             when :normal
               "「NORMAL」というカテゴリのために、サボったことを皮肉や煽りを交えながら、
               不安を煽る日本語メッセージを1文を作ってください。
               口調は少しカジュアルで、挑発的にしてください。
               出力はそのセリフだけ。例：まだ頑張れるでしょ？ちょっと甘えてない？"
             when :fail
               "「FAIL」というカテゴリのために、皮肉や罵倒を交えた、
               日本語メッセージを1つ作ってください。
               お前、君、など直接的な呼びかけを含めてもOKです。
               出力はそのセリフだけ。例：お前ってやつはとことんダメなやつだな"
             else
               "応援のメッセージを作ってください。日本語で1文。"
             end
  
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.9,
      }
    )
  
    response.dig("choices", 0, "message", "content")
  end
  
  
end
