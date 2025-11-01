# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubmissionPolicy, type: :policy do
  subject(:policy) { described_class.new(user, submission) }

  let(:submission) { instance_double("Submission", user_id: owner.id) }
  let(:owner) { create(:user, email: "policy-owner-#{SecureRandom.hex(4)}@example.com") }

  context "when user is a teacher" do
    let(:user) { create(:user, :teacher, email: "policy-teacher-#{SecureRandom.hex(4)}@example.com") }

    it "permits show" do
      expect(policy).to be_show
    end

    it "permits update" do
      expect(policy).to be_update
    end

    it "forbids create" do
      expect(policy).not_to be_create
    end
  end

  context "when user is the owner (student)" do
    let(:user) { owner }

    it "permits show" do
      expect(policy).to be_show
    end

    it "permits create" do
      expect(policy).to be_create
    end

    it "forbids update" do
      expect(policy).not_to be_update
    end
  end

  context "when user is nil" do
    let(:user) { nil }

    it "denies access to show" do
      expect(policy).not_to be_show
    end
  end
end
