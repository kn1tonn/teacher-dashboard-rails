# frozen_string_literal: true

if Rails.env.test?
  puts "Skipping seed data in test environment."
  return
end

puts "Seeding default users..."

teacher = User.find_or_initialize_by(email: "teacher@example.com")
teacher.attributes = {
  name: "Teacher Sample",
  password: "Password1!",
  role: :teacher
}
teacher.save!

student = User.find_or_initialize_by(email: "student@example.com")
student.attributes = {
  name: "Student Sample",
  password: "Password1!",
  role: :student
}
student.save!

puts "Seeded teacher (#{teacher.email}) and student (#{student.email})."

puts "Seeding tasks..."

task_definitions = [
  {
    title: "Weekly Diary Reflection",
    description: "Write about your study highlights and challenges for the week.",
    task_type: :diary,
    due_on: 1.week.from_now.to_date
  },
  {
    title: "Shadowing Practice - Unit 3",
    description: "Record yourself shadowing the provided dialogue and submit the audio link.",
    task_type: :shadowing,
    due_on: (Date.current + 10.days)
  }
]

tasks = task_definitions.map do |attrs|
  Task.find_or_initialize_by(title: attrs[:title]).tap do |task|
    task.assign_attributes(attrs.merge(active: true))
    task.save!
  end
end

puts "Seeded #{tasks.size} tasks."

puts "Seeding submissions..."

diary_task = tasks.find { |task| task.title.include?("Diary") }
shadowing_task = tasks.find { |task| task.title.include?("Shadowing") }

diary_submission = Submission.find_or_initialize_by(user: student, task: diary_task)
diary_submission.assign_attributes(
  status: :returned,
  content: "This week I focused on phrasal verbs and practiced speaking with classmates.",
  submitted_at: 2.days.ago,
  ai_score: 85,
  ai_summary: "Strong vocabulary usage with minor tense issues."
)
diary_submission.save!

shadowing_submission = Submission.find_or_initialize_by(user: student, task: shadowing_task)
shadowing_submission.assign_attributes(
  status: :ai_checked,
  content_url: "https://example.com/submissions/student-shadowing-unit3.mp3",
  submitted_at: 1.day.ago,
  ai_score: 72,
  ai_summary: "Good rhythm; improve intonation on questions."
)
shadowing_submission.save!

puts "Seeded submissions for #{student.email}."

puts "Seeding feedback and memos..."

feedback = Feedback.find_or_initialize_by(submission: diary_submission)
feedback.assign_attributes(
  teacher_comment: "Great reflection! Let's focus on past perfect usage in next week's diary.",
  published_at: Time.current
)
feedback.save!

Memo.find_or_create_by!(user: teacher, submission: diary_submission, visibility: :teacher_only) do |memo|
  memo.body = "Student is progressing well. Introduce advanced connecting phrases."
end

Memo.find_or_create_by!(user: student, submission: diary_submission, visibility: :student_self) do |memo|
  memo.body = "Remember to review feedback before next submission."
end

puts "Seeded feedback and memos."

puts "Seeding notifications..."

Notification.find_or_create_by!(
  user: student,
  kind: :feedback_published,
  payload: {
    submission_id: diary_submission.id,
    task_title: diary_task.title
  }
) do |notification|
  notification.read_at = nil
end

Notification.find_or_create_by!(
  user: student,
  kind: :deadline_reminder,
  payload: {
    task_id: shadowing_task.id,
    due_on: shadowing_task.due_on
  }
) do |notification|
  notification.read_at = nil
end

puts "Seeded notifications."
