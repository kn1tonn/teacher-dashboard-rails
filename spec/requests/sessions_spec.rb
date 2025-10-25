# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  it "renders sign in page with Google OAuth button" do
    get new_user_session_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sign in with Google")
    expect(response.body).to include('name="user[email]"')
  end
end
