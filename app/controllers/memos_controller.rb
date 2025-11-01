# frozen_string_literal: true

class MemosController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def create
    submission = current_user.submissions.find(memo_params[:submission_id])
    memo = submission.memos.build(user: current_user, visibility: :student_self, body: memo_params[:body])

    if memo.save
      redirect_to dashboard_path(anchor: "feedback-history"), notice: "Memo added."
    else
      redirect_to dashboard_path(anchor: "feedback-history"), alert: memo.errors.full_messages.to_sentence
    end
  end

  private

  def memo_params
    params.require(:memo).permit(:body, :submission_id)
  end

  def ensure_student!
    return if current_user.student?

    redirect_to dashboard_path, alert: "Only students can create personal memos."
  end

  def render_not_found
    head :not_found
  end
end
