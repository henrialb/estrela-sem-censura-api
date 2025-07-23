class User < ApplicationRecord
  has_many :comments, dependent: :destroy

  validates :name, :facebook_id, presence: true
  validates :facebook_id, uniqueness: true
end
