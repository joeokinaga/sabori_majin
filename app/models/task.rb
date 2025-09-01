class Task < ApplicationRecord
    belongs_to :user
    enum status: {
        unstarted: "unstarted",
        working:   "working",
        stopped:   "stopped",
        done:      "done"
    }, _prefix: true
end
