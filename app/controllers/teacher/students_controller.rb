# frozen_string_literal: true

module Teacher
  class StudentsController < BaseController
    def index
      @students = User.student
                       .includes(:submissions)
                       .order(:name)
                       .map do |student|
        latest_submission = student.submissions.max_by(&:updated_at)
        OpenStruct.new(
          student: student,
          submission_count: student.submissions.count,
          last_submission_at: latest_submission&.updated_at,
          pending_count: student.submissions.where(status: %i[submitted ai_checking ai_checked]).count
        )
      end
    end

    def show
      @student = User.student.find(params[:id])
      @submissions = @student.submissions.includes(:task, :feedback, :attachments, memos: :user).order(updated_at: :desc)
    end
  end
end
