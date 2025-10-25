# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations", type: :request do
  it "renders sign up page with Google and email options" do
    get new_user_registration_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sign up with Google")
    expect(response.body).to include('name="user[name]"')
    expect(response.body).to include('name="user[email]"')
  end
end
