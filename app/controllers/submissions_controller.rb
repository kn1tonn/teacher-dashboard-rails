# frozen_string_literal: true

class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def create
    @task = Task.find(submission_params[:task_id])
    @submission = current_user.submissions.find_or_initialize_by(task: @task)
    @submission.assign_attributes(filtered_submission_attributes)
    @submission.status = :submitted
    @submission.submitted_at = Time.current

    if @submission.save
      redirect_to dashboard_path, notice: "Submission saved."
    else
      redirect_to dashboard_path, alert: @submission.errors.full_messages.to_sentence
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:task_id, :content, :content_url)
  end

  def filtered_submission_attributes
    submission_params.except(:task_id).transform_values do |value|
      value.is_a?(String) ? value.strip.presence : value
    end
  end

  def ensure_student!
    return if current_user.student?

    redirect_to dashboard_path, alert: "Only students can submit assignments."
  end
end
