# frozen_string_literal: true

module Teacher
  class MemosController < BaseController
    before_action :load_submission

    def create
      memo = @submission.memos.build(memo_params.merge(user: current_user, visibility: :teacher_only))

      if memo.save
        redirect_to teacher_submission_path(@submission), notice: "Memo added for staff only."
      else
        redirect_to teacher_submission_path(@submission), alert: memo.errors.full_messages.to_sentence
      end
    end

    private

    def memo_params
      params.require(:memo).permit(:body)
    end

    def load_submission
      @submission = Submission.find(params[:submission_id])
    end
  end
end
