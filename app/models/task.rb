class Task < ApplicationRecord
   belongs_to :user
   enum :status,  unstarted: 0, working: 1, stopped: 2, done: 3

   validates :title, presence: true
   validates :planned_start_at, presence: true
   validates :planned_finish_at, presence: true
end
