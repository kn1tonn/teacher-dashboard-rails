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
