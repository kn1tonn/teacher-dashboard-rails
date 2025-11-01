class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :omniauthable, omniauth_providers: %i[google_oauth2]

  enum :role, { student: 0, teacher: 1 }

  has_many :submissions, dependent: :destroy
  has_many :memos, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :name, presence: true
  validates :role, presence: true

  def self.from_omniauth(auth)
    find_or_initialize_by(provider: auth.provider, uid: auth.uid).tap do |user|
      user.email = auth.info.email
      user.name = auth.info.name.presence || auth.info.email
      user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
      user.save!
    end
  end
end
