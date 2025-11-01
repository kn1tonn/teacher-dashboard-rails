# frozen_string_literal: true

module Teacher
  class SubmissionsController < BaseController
    before_action :load_submission, only: %i[show update]

    def index
      @status_filter = params[:status]
      @task_filter = params[:task_id]
      @week_filter = params[:week]

      @submissions = Submission.includes(:user, :task)
                               .order(updated_at: :desc)

      @submissions = @submissions.where(status: @status_filter) if @status_filter.present?
      @submissions = @submissions.where(task_id: @task_filter) if @task_filter.present?

      if @week_filter.present?
        range = week_range(@week_filter)
        @submissions = @submissions.where(updated_at: range) if range
      end

      @tasks = Task.order(:title)
    end

    def show
      @feedback = @submission.feedback || @submission.build_feedback
      @teacher_memos = @submission.memos.teacher_only.includes(:user).order(created_at: :desc)
      @memo = Memo.new
    end

    def update
      new_status = params.require(:submission).permit(:status)[:status]

      unless @submission.allowed_transition?(new_status)
        redirect_to teacher_submission_path(@submission), alert: "Invalid status transition." and return
      end

      previous_status = @submission.status
      @submission.update!(status: new_status)
      notify_student_of_status_change(new_status) if new_status != previous_status
      redirect_to teacher_submission_path(@submission), notice: "Submission status updated."
    end

    private

    def load_submission
      @submission = Submission.includes(:user, :task, :feedback, :attachments, memos: :user).find(params[:id])
    end

    def week_range(value)
      week_start = Date.parse(value) rescue nil
      return unless week_start

      week_start.beginning_of_week..week_start.end_of_week.end_of_day
    end

    def notify_student_of_status_change(new_status)
      Notification.create!(
        user: @submission.user,
        kind: :status_changed,
        payload: {
          submission_id: @submission.id,
          task_id: @submission.task_id,
          task_title: @submission.task.title,
          status: new_status
        }
      )
    end
  end
end
