# Implementation Roadmap (MVP v0.9)

This roadmap breaks down the specification-driven build into incremental milestones. Each phase is intended to be merged independently with passing CI and visible functionality/stubs where applicable.

## Phase 0 – Project Bootstrap
- Confirm Rails 8.1 stack runs locally (`docker compose up`, `bin/setup`) and document any gaps.
- Add baseline gems/tools from spec (Devise, OmniAuth Google, Pundit, RSpec, FactoryBot, Faker, Sidekiq).
- Configure TailwindCSS (already present via `tailwindcss-rails`) with base layout components.
- Set up shared layout, navigation shell, and placeholder dashboard routes.

## Phase 1 – Authentication & Authorization
- Install Devise User model with enum `role` (`student`, `teacher`) and Google OAuth option (placeholder credentials, environment variables).
- Implement role-based dashboards controller skeleton (`DashboardsController#show`) redirecting to teacher/student views.
- Integrate Pundit policies with base `ApplicationPolicy`; add Submission policy skeleton matching spec.
- Seed sample teacher/student accounts for local testing.

## Phase 2 – Core Domain Models & Persistence
- Create models/migrations: `Task`, `Submission`, `Feedback`, `Memo`, `Attachment`, `Notification`.
- Define enums (`task_type`, `status`, `visibility`) and validations per spec.
- Configure associations and dependent behaviors (e.g., `Submission has_one :feedback`).
- Add Active Storage (if using) or carrierwave equivalent for `Attachment#file`.
- Seed initial tasks/submissions for smoke testing.

## Phase 3 – Student Experience
- Build student dashboard (ERB + Tailwind) with “This Week’s Tasks”, submission status pills, submission form (content or URL).
- Implement `SubmissionsController#create` with validations and status transition (`not_submitted -> submitted`).
- Add ability for students to view feedback history and create personal memos (visibility `student_self`).
- Write request/system specs covering submission creation and visibility rules.

## Phase 4 – Teacher Workflow
- Implement teacher dashboards: KPI cards (placeholder data), filters (status, week, task type) using Turbo/search params.
- Create teacher-facing lists: students index, submissions index with sort/filter, submission detail (content, AI results, status updates).
- Add `FeedbacksController` for teacher review, publishing flow (`ai_checked -> teacher_reviewed -> returned`) with rich-text (ActionText).
- Enable teacher memos tied to submissions (`visibility: teacher_only`) with timeline UI component.
- Cover with policy/request/system specs, especially transitions.

## Phase 5 – Background Jobs & AI Flow
- Configure Sidekiq/ActiveJob; create stubbed AI processing job performing transitions (`submitted -> ai_checking -> ai_checked`).
- Add deadline reminder job scanning active tasks and enqueuing notifications.
- Provide admin UI or rake tasks to trigger jobs in development.
- Write job specs and integration tests for status transitions.

## Phase 6 – Notifications & API
- Build `NotificationsController#index/update` with in-app notification UI (read/unread).
- Implement notification triggers for feedback publication and status changes.
- Expose `/api/submissions` endpoint with filtering per spec (JBuilder or Rails responders).
- Add API authentication strategy (session-based or token) and request specs.

## Phase 7 – UX Polish & Accessibility
- Apply Tailwind styling for tables, status pills, responsive layouts, keyboard nav (optional).
- Ensure i18n keys for Japanese default, English fallback.
- Review accessibility (landmarks, labels, contrast) and add linting if needed.

## Phase 8 – Observability & Non-Functional
- Integrate structured logging format (JSON) and add audit trails for key transitions (e.g., using `audited` gem or custom model).
- Validate security hardening (CSRF, MIME type checks for attachments).
- Add basic performance monitoring hooks or documentation for future setup (Sentry placeholders, metrics).

## Phase 9 – QA & Release Prep
- Expand RSpec coverage (models, policies, systems) ensuring core flows: submit → AI → review → publish.
- Provide seed scripts/fixtures for demo environments.
- Update README with setup, job workers, OAuth configuration, and deployment steps (Docker/Kamal).
- Prepare initial production checklist (ENV vars, background workers, storage).

### Notes & Dependencies
- OAuth/AI integrations can start as stubs; document follow-up tasks once credentials/services are available.
- Attachment storage strategy (Active Storage + S3) may require environment-specific configuration before production rollout.
- Monitor spec changes; update this roadmap accordingly.

