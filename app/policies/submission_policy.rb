# frozen_string_literal: true

class SubmissionPolicy < ApplicationPolicy
  def show?
    user&.teacher? || record.user_id == user&.id
  end

  def update?
    user&.teacher?
  end

  def create?
    user&.student?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if user.teacher?

      scope.where(user_id: user.id)
    end
  end
end
