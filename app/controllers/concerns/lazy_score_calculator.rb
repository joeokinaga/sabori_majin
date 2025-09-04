module LazyScoreCalculator
    extend ActiveSupport::Concern
    def sum_lazy_score(tasks)
        tasks.sum do |task|
          calc_lazy_score(task)
        end
      end
    def calc_lazy_score(task)
        if task.status != "unstarted" || Time.current > task.planned_start_at + 3.minutes
            if task.status == "unstarted"
                return 5
            elsif task.status == "working"
                return 0
            else
                lazy_pt = 0

                if task.status == "stopped"
                    lazy_pt += 2
                end

                if task.started_at > task.planned_start_at + 3.minutes
                    lazy_pt += 2
                elsif task.started_at < task.planned_start_at - 3.minutes
                    lazy_pt += 1
                end

                if (task.planned_finish_at - task.planned_start_at) * 0.8 > (task.finished_at - task.started_at)
                    lazy_pt += 1
                end

                return lazy_pt

            end
        else
            return 0
        end
    end
end