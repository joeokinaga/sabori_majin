class Task < ApplicationRecord
   belongs_to :user
   enum :status,  unstarted: 0, working: 1, stopped: 2, done: 3

   validates :title, presence: true
   validates :planned_start_at, presence: true
   validates :planned_finish_at, presence: true
   validate :finish_after_start
   validate :no_overlap, if: -> { planned_start_at.present? && planned_finish_at.present? }
#    validate :planned_start_at_cannot_be_in_the_past

   private

    def finish_after_start
        return if planned_start_at.blank? || planned_finish_at.blank?
        if planned_finish_at <= planned_start_at
            errors.add(:planned_finish_at, "Finishing time must be after starting time")
        end
    end

    def no_overlap
        overlap = Task
                    .where(user_id: user_id)               # 同じユーザー
                    .where.not(id: id)                     # 自分自身は除外（更新時用）
                    .where(
                        "(planned_start_at < ? AND planned_finish_at > ?)",
                        planned_finish_at, planned_start_at
                    )
        if overlap.exists?
            errors.add(:base, "It overlaps with another task's time")
        end
    end

    def planned_start_at_cannot_be_in_the_past
        if planned_start_at.present? && planned_start_at < Time.zone.now
          errors.add(:planned_start_at, "は現在時刻以降を指定してください")
        end
    end
end
