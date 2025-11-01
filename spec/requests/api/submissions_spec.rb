# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Submissions", type: :request do
  let(:token) { "development-token" }
  let(:headers) { { "Authorization" => "Token token=#{token}" } }
  let!(:submissions) do
    task = create(:task, title: "API Task")
    Array.new(2) do |i|
      user = create(:user, email: "api-user-#{i}-#{SecureRandom.hex(4)}@example.com")
      create(:submission, task: task, user: user, status: :ai_checked)
    end
  end

  describe "GET /api/submissions" do
    it "requires authentication" do
      get api_submissions_path
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns submissions with filtering" do
      get api_submissions_path, params: { status: :ai_checked }, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      returned_ids = json.map { |payload| payload["id"] }

      expect(returned_ids).to include(*submissions.map(&:id))
      expect(json).to all(include("status" => "ai_checked"))
    end
  end
end
