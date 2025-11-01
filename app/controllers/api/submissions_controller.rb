# frozen_string_literal: true

module Api
  class SubmissionsController < BaseController
    def index
      submissions = Submission.includes(:user, :task).order(updated_at: :desc)
      submissions = submissions.where(status: params[:status]) if params[:status].present?
      submissions = submissions.where(task_id: params[:task_id]) if params[:task_id].present?

      render json: submissions.map { |submission| submission_payload(submission) }
    end

    private

    def submission_payload(submission)
      {
        id: submission.id,
        status: submission.status,
        ai_score: submission.ai_score,
        updated_at: submission.updated_at,
        user: {
          id: submission.user.id,
          name: submission.user.name
        },
        task: {
          id: submission.task.id,
          title: submission.task.title
        }
      }
    end
  end
end
