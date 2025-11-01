# frozen_string_literal: true

module DashboardHelper
  STATUS_BADGE_STYLES = {
    not_submitted: "bg-slate-200 text-slate-700",
    submitted: "bg-sky-100 text-sky-800",
    ai_checking: "bg-violet-100 text-violet-800",
    ai_checked: "bg-indigo-100 text-indigo-800",
    teacher_reviewed: "bg-emerald-100 text-emerald-800",
    returned: "bg-amber-100 text-amber-800"
  }.freeze

  def submission_status_badge(status)
    status_key = status.to_sym
    classes = STATUS_BADGE_STYLES.fetch(status_key, "bg-slate-200 text-slate-700")
    content_tag(:span,
                status.to_s.humanize,
                class: "inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold #{classes}")
  end
end
