# frozen_string_literal: true

require "ostruct"

class DashboardsController < ApplicationController
  helper DashboardHelper
  before_action :authenticate_user!

  def show
    if current_user.teacher?
      @dashboard_role = :teacher
      load_teacher_dashboard
    else
      @dashboard_role = :student
      @tasks = Task.where(active: true).order(:due_on, :title)
      @submissions = current_user.submissions.includes(:task, :feedback, memos: :user).order(updated_at: :desc)
      @submissions_by_task = @submissions.index_by(&:task_id)
      @submissions_with_feedback = @submissions.select { |submission| submission.feedback.present? }
      @memo = Memo.new
    end
  end

  private

  def load_teacher_dashboard
    @status_filter = params[:status]
    @task_filter = params[:task_id]
    @timeframe = params[:timeframe]

    scope = Submission.includes(:user, :task)
    scope = scope.where(status: @status_filter) if @status_filter.present?
    scope = scope.where(task_id: @task_filter) if @task_filter.present?

    if @timeframe.present?
      case @timeframe
      when "this_week"
        scope = scope.where(updated_at: Time.current.beginning_of_week..Time.current.end_of_week)
      when "last_week"
        last_week = 1.week.ago
        scope = scope.where(updated_at: last_week.beginning_of_week..last_week.end_of_week)
      end
    end

    @recent_submissions = scope.order(updated_at: :desc).limit(10)
    @tasks = Task.order(:title)
    all_submissions = Submission.where(updated_at: Time.current.beginning_of_week..Time.current.end_of_week)

    @kpis = {
      weekly_submissions: all_submissions.count,
      ai_pending: Submission.where(status: :ai_checking).count,
      reviews_pending: Submission.where(status: :ai_checked).count
    }

    @status_counts = Submission.group(:status).count
    @students_snapshot = User.student
                              .includes(:submissions)
                              .map do |student|
      OpenStruct.new(
        student: student,
        latest_submission: student.submissions.order(updated_at: :desc).first,
        pending_count: student.submissions.where(status: %i[ai_checking ai_checked]).count
      )
    end
  end
end
