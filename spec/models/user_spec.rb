require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it "is valid with default attributes" do
    expect(user).to be_valid
  end

  it "requires a name" do
    user.name = nil

    expect(user).not_to be_valid
    expect(user.errors[:name]).to include("can't be blank")
  end

  it "defines the expected roles" do
    expect(described_class.roles.keys).to contain_exactly("student", "teacher")
  end

  describe ".from_omniauth" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "123456789",
        info: OmniAuth::AuthHash::InfoHash.new(
          email: "teacher@example.com",
          name: "Sample Teacher"
        )
      )
    end

    it "creates a user when one does not exist" do
      expect { described_class.from_omniauth(auth_hash) }
        .to change(described_class, :count).by(1)
    end

    it "returns the existing user when provider/uid already stored" do
      existing_user = create(:user, provider: "google_oauth2", uid: "123456789")

      expect(described_class.from_omniauth(auth_hash)).to eq(existing_user)
    end
  end
end
