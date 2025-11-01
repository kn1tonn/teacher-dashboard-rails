class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  has_one_attached :asset

  validates :file, presence: true

  before_validation :sync_filename_from_asset

  private

  def sync_filename_from_asset
    return unless asset.attached?

    self.file = asset.filename.to_s
  end
end
