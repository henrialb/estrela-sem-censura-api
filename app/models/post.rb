# frozen_string_literal: true

class Post < ApplicationRecord
  FACEBOOK_PAGE_ID = 'estrelamadora'

  has_many :comments, dependent: :destroy

  validates :facebook_id, :permalink_url, presence: true
  validates :facebook_id, uniqueness: true
  validates :permalink_url, format: {
    with: %r{\Ahttps://www\.facebook\.com/#{FACEBOOK_PAGE_ID}}o,
    message: "must be a valid Facebook URL for the page #{FACEBOOK_PAGE_ID}"
  }

  scope :recent, -> { order(created_at: :desc) }

  # This method is used to add a new post manually using the post URL.
  def self.add_from_url(url)
    post_data = {
      'facebook_id' => extract_facebook_id(url),
      'permalink_url' => url
    }

    add_from_facebook_data(post_data)
  end

  def self.add_from_facebook_data(post_data)
    find_or_create_by(facebook_id: post_data['facebook_id']) do |post|
      post.permalink_url = post_data['permalink_url']
    end
  end

  def self.extract_facebook_id(url)
    uri = URI.parse(url)

    # Validate the URL structure to ensure it is a Facebook post URL for the specific page we want.
    if uri.host != 'www.facebook.com' || !uri.path.start_with?("/#{FACEBOOK_PAGE_ID}/posts/")
      raise ArgumentError, "Invalid Facebook post URL for page #{FACEBOOK_PAGE_ID}"
    end

    path_segments = uri.path.split('/')
    post_index = path_segments.index('posts')

    return nil unless post_index && path_segments.size > post_index + 1

    path_segments[post_index + 1]
  end
end
