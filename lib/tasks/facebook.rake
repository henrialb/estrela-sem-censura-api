# frozen_string_literal: true

namespace :facebook do
  desc "Sync recent posts from Facebook"
  task sync: :environment do
    service = FacebookSyncService.new(
      Rails.application.credentials.facebook[:page_id],
      Rails.application.credentials.facebook[:page_access_token]
    )

    count = service.sync_recent_posts
    puts "Synced #{count} posts successfully!"
  end
end
