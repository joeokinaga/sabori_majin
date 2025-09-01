class Task < ApplicationRecord
    belongs_to :user
     enum :status,  unstarted: 0, working: 1, stopped: 2, done: 3
end
