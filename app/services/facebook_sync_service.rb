# frozen_string_literal: true

class FacebookSyncService
  def initialize(page_id, access_token)
    @page_id = page_id
    @facebook_service = FacebookService.new(access_token)
  end

  def sync_recent_posts(limit = 25)
    Rails.logger.info "Starting Facebook sync for page #{@page_id}"

    posts_data = @facebook_service.fetch_page_posts(@page_id, limit)
    synced_count = 0

    posts_data['data'].each do |post_data|
      Post.add_from_facebook_data(post_data)
      synced_count += 1
    end

    Rails.logger.info "Synced #{synced_count} posts from Facebook"
    synced_count
  rescue StandardError => e
    Rails.logger.error "Facebook sync failed: #{e.message}"
    raise e
  end
end
