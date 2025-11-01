# frozen_string_literal: true

module Teacher
  class FeedbacksController < BaseController
    before_action :load_submission

    def create
      feedback = @submission.build_feedback
      update_feedback(feedback)
    end

    def update
      feedback = @submission.feedback || @submission.build_feedback
      update_feedback(feedback)
    end

    private

    def load_submission
      @submission = Submission.find(params[:submission_id])
    end

    def feedback_params
      params.require(:feedback).permit(:teacher_comment, :published)
    end

    def update_feedback(feedback)
      feedback.teacher_comment = feedback_params[:teacher_comment]
      feedback.published_at = feedback_params[:published] == "1" ? Time.current : nil

      if feedback.save
        maybe_transition_submission(feedback)
        notify_student_of_feedback(feedback)
        redirect_to teacher_submission_path(@submission), notice: "Feedback saved."
      else
        redirect_to teacher_submission_path(@submission), alert: feedback.errors.full_messages.to_sentence
      end
    end

    def maybe_transition_submission(feedback)
      return unless feedback.published_at.present?

      if @submission.allowed_transition?("teacher_reviewed") && @submission.status != "teacher_reviewed"
        @submission.update!(status: :teacher_reviewed)
      end

      if @submission.allowed_transition?("returned")
        @submission.update!(status: :returned)
      end
    end

    def notify_student_of_feedback(feedback)
      return unless feedback.published_at.present?

      Notification.create!(
        user: @submission.user,
        kind: :feedback_published,
        payload: {
          submission_id: @submission.id,
          task_id: @submission.task_id,
          task_title: @submission.task.title
        }
      )
    end
  end
end
