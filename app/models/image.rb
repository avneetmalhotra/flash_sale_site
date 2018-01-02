class Image < ApplicationRecord
  belongs_to :deal
  has_attached_file :avatar, styles: PAPERCLIP_STYLES_HASH

  validates_attachment :avatar, presence: true,
    content_type: { content_type: PAPERCLIP_VALID_CONTENT_TYPES },
    size: { less_than: 5.megabytes }
end
